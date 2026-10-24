import 'dart:math';

import 'package:drift/drift.dart';
import 'package:ugk_core/ugk_core.dart';

import 'codecs.dart';
import 'database.dart';

/// 内置 id
const int kDefaultConfigId = 1;
const int kDefaultDeckId = 1;
const int kBasicTypeId = 1;
const int kBasicReversedTypeId = 2;
const int kClozeTypeId = 3;

/// 每日分界小时（本期固定 4 点）
const int kRolloverHour = 4;

/// 仓库：App 只通过它读写数据
/// 规范化卡组名：按 `::` 分层，每层 trim，去掉空层
String normalizeDeckName(String name) =>
    name.split('::').map((p) => p.trim()).where((p) => p.isNotEmpty).join('::');

class UgkRepository {
  /// 用数据库创建仓库
  UgkRepository(this.db);

  /// 底层数据库
  final UgkDatabase db;

  /// 空库时写入内置数据；已初始化则什么都不做
  Future<void> initIfEmpty({required int nowMs}) async {
    final meta = await db.select(db.collectionMeta).getSingleOrNull();
    if (meta != null) return;
    await db.transaction(() async {
      await db
          .into(db.collectionMeta)
          .insert(
            CollectionMetaCompanion.insert(
              id: const Value(1),
              createdMs: nowMs,
              nextNewPos: 1,
              lastUnburyDay: 0,
            ),
          );
      await db
          .into(db.deckConfigs)
          .insert(
            DeckConfigsCompanion.insert(
              id: const Value(kDefaultConfigId),
              name: 'Default',
              configJson: presetToJson(const DeckPreset()),
            ),
          );
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: const Value(kDefaultDeckId),
              name: 'Default',
              configId: kDefaultConfigId,
            ),
          );
      for (final t in [
        basicNoteType(kBasicTypeId),
        basicReversedNoteType(kBasicReversedTypeId),
        clozeNoteType(kClozeTypeId),
      ]) {
        await db
            .into(db.noteTypes)
            .insert(
              NoteTypesCompanion.insert(
                id: Value(t.id),
                name: t.name,
                kind: t.kind.index,
                fieldsJson: fieldsToJson(t.fields),
                templatesJson: templatesToJson(t.templates),
                css: t.css,
                sortFieldIdx: t.sortFieldIdx,
                mtimeMs: nowMs,
              ),
            );
      }
    });
  }

  /// 集合创建时间
  Future<int> createdMs() async =>
      (await db.select(db.collectionMeta).getSingle()).createdMs;

  /// 当前 day number
  Future<int> today({
    required int nowMs,
    required int utcOffsetMinutes,
  }) async => dayNumber(
    nowMs: nowMs,
    collectionCreatedMs: await createdMs(),
    utcOffsetMinutes: utcOffsetMinutes,
    rolloverHour: kRolloverHour,
  );

  /// 所有卡组，按 name 升序
  Future<List<DeckRow>> decks() =>
      (db.select(db.decks)..orderBy([(d) => OrderingTerm.asc(d.name)])).get();

  /// 新建卡组，返回 id；重名抛 StateError。
  /// 名字按 `::` 分层，每层去掉首尾空格；缺少的上级卡组会一起建出来（与 Anki 一致）。
  Future<int> createDeck(
    String name, {
    required int nowMs,
    int configId = kDefaultConfigId,
  }) {
    return db.transaction(() async {
      final norm = normalizeDeckName(name);
      if (norm.isEmpty) throw ArgumentError('卡组名不能为空');
      if (await _deckId(norm) != null) throw StateError('卡组已存在: $norm');
      final id = await _insertDeck(norm, nowMs, configId);
      await _ensureParents(norm, nowMs, configId);
      return id;
    });
  }

  /// 按名字找卡组，没有就新建（含上级），返回 id
  Future<int> ensureDeck(String name, {required int nowMs}) {
    return db.transaction(() async {
      final norm = normalizeDeckName(name);
      if (norm.isEmpty) throw ArgumentError('卡组名不能为空');
      final existing = await _deckId(norm);
      if (existing != null) return existing;
      final id = await _insertDeck(norm, nowMs, kDefaultConfigId);
      await _ensureParents(norm, nowMs, kDefaultConfigId);
      return id;
    });
  }

  /// 补齐所有缺失的上级卡组（修复旧数据）。返回补建的数量。
  Future<int> ensureParentDecks({required int nowMs}) {
    return db.transaction(() async {
      var added = 0;
      for (final d in await decks()) {
        added += await _ensureParents(d.name, nowMs, d.configId);
      }
      return added;
    });
  }

  Future<int?> _deckId(String name) async => (await (db.select(
    db.decks,
  )..where((d) => d.name.equals(name))).getSingleOrNull())?.id;

  Future<int> _insertDeck(String name, int nowMs, int configId) async {
    final maxId = await _maxId(db.decks, db.decks.id);
    final id = max(nowMs, maxId + 1);
    await db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(id: Value(id), name: name, configId: configId),
        );
    return id;
  }

  Future<int> _ensureParents(String name, int nowMs, int configId) async {
    final parts = name.split('::');
    var added = 0;
    for (var i = 1; i < parts.length; i++) {
      final parent = parts.take(i).join('::');
      if (await _deckId(parent) == null) {
        await _insertDeck(parent, nowMs, configId);
        added++;
      }
    }
    return added;
  }

  /// 卡组使用的 preset
  Future<DeckPreset> presetForDeck(int deckId) async {
    final deck = await (db.select(
      db.decks,
    )..where((d) => d.id.equals(deckId))).getSingle();
    final cfg = await (db.select(
      db.deckConfigs,
    )..where((c) => c.id.equals(deck.configId))).getSingle();
    return presetFromJson(cfg.configJson);
  }

  /// 保存 preset
  Future<void> savePreset(int configId, DeckPreset preset) async {
    await (db.update(db.deckConfigs)..where((c) => c.id.equals(configId)))
        .write(DeckConfigsCompanion(configJson: Value(presetToJson(preset))));
  }

  /// 读笔记类型
  Future<NoteType> noteType(int id) async => _toNoteType(
    await (db.select(db.noteTypes)..where((t) => t.id.equals(id))).getSingle(),
  );

  /// 所有笔记类型，按 id 升序
  Future<List<NoteType>> noteTypes() async => [
    for (final r in await (db.select(
      db.noteTypes,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get())
      _toNoteType(r),
  ];

  /// 添加笔记并生成卡片，返回新卡片 id（按 ord 升序）；一张卡都生成不了时抛 StateError
  Future<List<int>> addNote({
    required int noteTypeId,
    required int deckId,
    required List<String> fields,
    List<String> tags = const [],
    required int nowMs,
  }) {
    return db.transaction(() async {
      final type = await noteType(noteTypeId);
      final ords = generateCardOrds(type, fields);
      if (ords.isEmpty) throw StateError('这条笔记不会生成任何卡片');
      final meta = await db.select(db.collectionMeta).getSingle();
      final noteId = max(nowMs, await _maxId(db.notes, db.notes.id) + 1);
      await db
          .into(db.notes)
          .insert(
            NotesCompanion.insert(
              id: Value(noteId),
              guid: guidFromInt(noteId),
              noteTypeId: noteTypeId,
              fields: joinFields(fields),
              sortField: sortFieldValue(type, fields),
              checksum: fieldChecksum(fields[0]),
              tags: joinTags(tags),
              mtimeMs: nowMs,
            ),
          );
      var cardId = max(nowMs, await _maxId(db.cards, db.cards.id) + 1);
      final ids = <int>[];
      for (final ord in ords) {
        await db
            .into(db.cards)
            .insert(
              CardsCompanion.insert(
                id: Value(cardId),
                noteId: noteId,
                deckId: deckId,
                ord: ord,
                type: CardType.newCard.index,
                queue: CardQueue.newCard.dbValue,
                due: meta.nextNewPos,
                ivl: 0,
                ease: 0,
                reps: 0,
                lapses: 0,
                left: 0,
                flags: 0,
                mtimeMs: nowMs,
              ),
            );
        ids.add(cardId);
        cardId++;
      }
      await db
          .update(db.collectionMeta)
          .write(
            CollectionMetaCompanion(nextNewPos: Value(meta.nextNewPos + 1)),
          );
      return ids;
    });
  }

  /// 读卡片
  Future<Card> card(int id) async => _toCard(
    await (db.select(db.cards)..where((c) => c.id.equals(id))).getSingle(),
  );

  /// 卡组里的所有卡片，按 id 升序（只含本卡组，不含子卡组）
  Future<List<Card>> cardsOfDeck(int deckId) async => [
    for (final r
        in await (db.select(db.cards)
              ..where((c) => c.deckId.equals(deckId))
              ..orderBy([(c) => OrderingTerm.asc(c.id)]))
            .get())
      _toCard(r),
  ];

  /// 读笔记的 tags 字符串
  Future<String> noteTags(int noteId) async => (await (db.select(
    db.notes,
  )..where((n) => n.id.equals(noteId))).getSingle()).tags;

  /// 渲染卡片正反面
  Future<RenderedCard> render(int cardId) async {
    final c = await card(cardId);
    final note = await (db.select(
      db.notes,
    )..where((n) => n.id.equals(c.noteId))).getSingle();
    final type = await noteType(note.noteTypeId);
    return renderCard(type, splitFields(note.fields), c.ord);
  }

  /// 今日已学数 (newDone, reviewDone)
  Future<(int, int)> doneToday(int deckId, int today) async {
    final r =
        await (db.select(db.deckDayCounts)
              ..where((x) => x.deckId.equals(deckId) & x.day.equals(today)))
            .getSingleOrNull();
    return (r?.newDone ?? 0, r?.reviewDone ?? 0);
  }

  /// 今日队列（会先做跨天解除 bury）
  Future<StudyQueue> todayQueue({
    required int deckId,
    required int nowMs,
    required int utcOffsetMinutes,
  }) async {
    final day = await today(nowMs: nowMs, utcOffsetMinutes: utcOffsetMinutes);
    await _unburyIfNewDay(day);
    final (newDone, reviewDone) = await doneToday(deckId, day);
    return buildQueue(
      cards: await cardsOfDeck(deckId),
      today: day,
      preset: await presetForDeck(deckId),
      newDoneToday: newDone,
      reviewsDoneToday: reviewDone,
      seed: day,
    );
  }

  /// 评分：更新卡片、写复习日志、计数、leech 标签、bury 兄弟卡，全部在一个事务里
  Future<AnswerResult> answer({
    required int cardId,
    required Rating rating,
    required int nowMs,
    required int utcOffsetMinutes,
    required int timeTakenMs,
  }) {
    return db.transaction(() async {
      final old = await card(cardId);
      final preset = await presetForDeck(old.deckId);
      final day = await today(nowMs: nowMs, utcOffsetMinutes: utcOffsetMinutes);
      final result = answerCard(
        old,
        rating,
        nowMs: nowMs,
        today: day,
        preset: preset,
        timeTakenMs: timeTakenMs,
      );
      await _writeCard(result.card);
      final r = result.revlog;
      await db
          .into(db.revlog)
          .insert(
            RevlogCompanion.insert(
              id: Value(r.id),
              cardId: r.cardId,
              button: r.button,
              ivl: r.ivl,
              lastIvl: r.lastIvl,
              factor: r.factor,
              timeTakenMs: r.timeTakenMs,
              type: r.type.index,
            ),
          );

      final (newDone, reviewDone) = await doneToday(old.deckId, day);
      final isNew = old.type == CardType.newCard;
      final isReview =
          old.queue == CardQueue.review || old.queue == CardQueue.dayLearn;
      await db
          .into(db.deckDayCounts)
          .insertOnConflictUpdate(
            DeckDayCountsCompanion.insert(
              deckId: old.deckId,
              day: day,
              newDone: newDone + (isNew ? 1 : 0),
              reviewDone: reviewDone + (!isNew && isReview ? 1 : 0),
            ),
          );

      if (result.leechTriggered) {
        final tags = await noteTags(old.noteId);
        await (db.update(
          db.notes,
        )..where((n) => n.id.equals(old.noteId))).write(
          NotesCompanion(
            tags: Value(addTag(tags, 'leech')),
            mtimeMs: Value(nowMs),
          ),
        );
      }

      final siblings =
          await (db.select(db.cards)..where(
                (c) => c.noteId.equals(old.noteId) & c.id.equals(cardId).not(),
              ))
              .get();
      for (final s in siblings) {
        final q = CardQueue.fromDb(s.queue);
        final buryNew = preset.buryNewSiblings && q == CardQueue.newCard;
        final buryReview =
            preset.buryReviewSiblings && q == CardQueue.review && s.due <= day;
        if (buryNew || buryReview) {
          await (db.update(db.cards)..where((c) => c.id.equals(s.id))).write(
            CardsCompanion(
              queue: Value(CardQueue.schedBuried.dbValue),
              mtimeMs: Value(nowMs),
            ),
          );
        }
      }
      return result;
    });
  }

  /// 卡片的复习日志，按 id 升序
  Future<List<RevlogEntry>> revlogOf(int cardId) async => [
    for (final r
        in await (db.select(db.revlog)
              ..where((x) => x.cardId.equals(cardId))
              ..orderBy([(x) => OrderingTerm.asc(x.id)]))
            .get())
      RevlogEntry(
        id: r.id,
        cardId: r.cardId,
        button: r.button,
        ivl: r.ivl,
        lastIvl: r.lastIvl,
        factor: r.factor,
        timeTakenMs: r.timeTakenMs,
        type: RevlogType.values[r.type],
      ),
  ];

  Future<void> _unburyIfNewDay(int day) async {
    final meta = await db.select(db.collectionMeta).getSingle();
    if (meta.lastUnburyDay >= day) return;
    await db.transaction(() async {
      final buried =
          await (db.select(db.cards)..where(
                (c) => c.queue.isIn([
                  CardQueue.schedBuried.dbValue,
                  CardQueue.userBuried.dbValue,
                ]),
              ))
              .get();
      for (final b in buried) {
        final q = switch (CardType.values[b.type]) {
          CardType.newCard => CardQueue.newCard,
          CardType.review => CardQueue.review,
          CardType.learn || CardType.relearn =>
            b.due > 1000000000 ? CardQueue.learn : CardQueue.dayLearn,
        };
        await (db.update(db.cards)..where((c) => c.id.equals(b.id))).write(
          CardsCompanion(queue: Value(q.dbValue)),
        );
      }
      await db
          .update(db.collectionMeta)
          .write(CollectionMetaCompanion(lastUnburyDay: Value(day)));
    });
  }

  Future<void> _writeCard(Card c) async {
    await (db.update(db.cards)..where((x) => x.id.equals(c.id))).write(
      CardsCompanion(
        deckId: Value(c.deckId),
        ord: Value(c.ord),
        type: Value(c.type.index),
        queue: Value(c.queue.dbValue),
        due: Value(c.due),
        ivl: Value(c.ivl),
        ease: Value(c.ease),
        reps: Value(c.reps),
        lapses: Value(c.lapses),
        left: Value(c.left),
        flags: Value(c.flags),
        mtimeMs: Value(c.mtimeMs),
      ),
    );
  }

  Future<int> _maxId(TableInfo table, Expression<int> idCol) async {
    final maxExpr = idCol.max();
    final row = await (db.selectOnly(table)..addColumns([maxExpr])).getSingle();
    return row.read(maxExpr) ?? 0;
  }

  NoteType _toNoteType(NoteTypeRow r) => NoteType(
    id: r.id,
    name: r.name,
    kind: NoteKind.values[r.kind],
    fields: fieldsFromJson(r.fieldsJson),
    templates: templatesFromJson(r.templatesJson),
    css: r.css,
    sortFieldIdx: r.sortFieldIdx,
  );

  Card _toCard(CardRow r) => Card(
    id: r.id,
    noteId: r.noteId,
    deckId: r.deckId,
    ord: r.ord,
    type: CardType.values[r.type],
    queue: CardQueue.fromDb(r.queue),
    due: r.due,
    ivl: r.ivl,
    ease: r.ease,
    reps: r.reps,
    lapses: r.lapses,
    left: r.left,
    flags: r.flags,
    mtimeMs: r.mtimeMs,
  );
}
