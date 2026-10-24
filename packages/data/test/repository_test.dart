import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';
import 'package:ugk_data/ugk_data.dart';

/// 2026-10-24 12:00 上海时间
const t0 = 1792814400000;
const sh = 480;
const minute = 60000;
const day = 86400000;

void main() {
  late UgkDatabase db;
  late UgkRepository repo;

  setUp(() async {
    db = UgkDatabase(NativeDatabase.memory());
    repo = UgkRepository(db);
    await repo.initIfEmpty(nowMs: t0);
  });

  tearDown(() => db.close());

  group('初始化', () {
    test('内置卡组、preset、笔记类型', () async {
      final decks = await repo.decks();
      expect(decks.map((d) => d.name), ['Default']);
      expect(decks.single.id, kDefaultDeckId);
      expect((await repo.noteTypes()).map((t) => t.name), [
        'Basic',
        'Basic (and reversed card)',
        'Cloze',
      ]);
      final p = await repo.presetForDeck(kDefaultDeckId);
      expect(p.newPerDay, 20);
      expect(p.learnSteps, [1.0, 10.0]);
      expect(await repo.createdMs(), t0);
    });

    test('重复初始化不报错、不重复插入', () async {
      await repo.initIfEmpty(nowMs: t0 + day);
      expect((await repo.decks()).length, 1);
      expect(await repo.createdMs(), t0);
    });

    test('today 按上海 04:00 分界', () async {
      expect(await repo.today(nowMs: t0, utcOffsetMinutes: sh), 0);
      // 次日 03:59 仍是第 0 天，04:00 是第 1 天
      expect(
        await repo.today(
          nowMs: t0 + 15 * 3600000 + 59 * minute,
          utcOffsetMinutes: sh,
        ),
        0,
      );
      expect(
        await repo.today(nowMs: t0 + 16 * 3600000, utcOffsetMinutes: sh),
        1,
      );
    });
  });

  group('卡组与 preset', () {
    test('新建卡组：id 取时间戳，按名字排序，自动补上级，重名报错', () async {
      final id = await repo.createDeck(' English :: Dance ', nowMs: t0 + 5000);
      expect(id, t0 + 5000);
      expect((await repo.decks()).map((d) => d.name), [
        'Default',
        'English',
        'English::Dance',
      ]);
      expect(
        () => repo.createDeck('English', nowMs: t0 + 6000),
        throwsStateError,
      );
      expect(await repo.ensureDeck('English', nowMs: t0 + 7000), isNot(id));
      expect(await repo.ensureDeck('English::Dance', nowMs: t0 + 7000), id);
      expect(
        () => repo.createDeck('English::Dance', nowMs: t0 + 6000),
        throwsStateError,
      );
    });

    test('补齐旧数据里缺失的上级卡组', () async {
      await repo.db
          .into(repo.db.decks)
          .insert(
            DecksCompanion.insert(
              id: const Value(99),
              name: 'A::B::C',
              configId: kDefaultConfigId,
            ),
          );
      expect(await repo.ensureParentDecks(nowMs: t0), 2);
      expect(await repo.ensureParentDecks(nowMs: t0), 0);
      expect((await repo.decks()).map((d) => d.name), [
        'A',
        'A::B',
        'A::B::C',
        'Default',
      ]);
    });

    test('同一毫秒建两个卡组，id 递增', () async {
      final a = await repo.createDeck('A', nowMs: t0);
      final b = await repo.createDeck('B', nowMs: t0);
      expect(b, a + 1);
    });

    test('preset 保存后读回一致', () async {
      const p = DeckPreset(
        learnSteps: [1, 10, 60],
        newPerDay: 5,
        easyMultiplier: 1.5,
        leechAction: LeechAction.suspend,
        buryNewSiblings: false,
      );
      await repo.savePreset(kDefaultConfigId, p);
      final back = await repo.presetForDeck(kDefaultDeckId);
      expect(back.learnSteps, [1.0, 10.0, 60.0]);
      expect(back.newPerDay, 5);
      expect(back.easyMultiplier, 1.5);
      expect(back.leechAction, LeechAction.suspend);
      expect(back.buryNewSiblings, false);
      expect(back.reviewsPerDay, 200);
    });

    test('presetFromJson 缺键用默认值', () {
      final p = presetFromJson('{"newPerDay": 7}');
      expect(p.newPerDay, 7);
      expect(p.initialEase, 2500);
      expect(p.relearnSteps, [10.0]);
    });
  });

  group('添加笔记', () {
    test('Basic (and reversed) 生成两张新卡', () async {
      final ids = await repo.addNote(
        noteTypeId: kBasicReversedTypeId,
        deckId: kDefaultDeckId,
        fields: ['hello', '你好'],
        tags: ['dance', 'en'],
        nowMs: t0 + 1000,
      );
      expect(ids, [t0 + 1000, t0 + 1001]);
      final c0 = await repo.card(ids[0]);
      final c1 = await repo.card(ids[1]);
      expect(c0.ord, 0);
      expect(c1.ord, 1);
      expect(c0.noteId, c1.noteId);
      expect(c0.noteId, t0 + 1000);
      expect(c0.type, CardType.newCard);
      expect(c0.queue, CardQueue.newCard);
      expect(c0.due, 1);
      expect(c1.due, 1);
      expect(c0.ease, 0);
      expect(await repo.noteTags(c0.noteId), ' dance en ');
    });

    test('渲染正反面', () async {
      final ids = await repo.addNote(
        noteTypeId: kBasicReversedTypeId,
        deckId: kDefaultDeckId,
        fields: ['hello', '你好'],
        nowMs: t0,
      );
      final r0 = await repo.render(ids[0]);
      expect(r0.question, 'hello');
      expect(r0.answer, 'hello<hr id=answer>你好');
      final r1 = await repo.render(ids[1]);
      expect(r1.question, '你好');
      expect(r1.answer, '你好<hr id=answer>hello');
    });

    test('Cloze 按编号生成卡片', () async {
      final ids = await repo.addNote(
        noteTypeId: kClozeTypeId,
        deckId: kDefaultDeckId,
        fields: ['{{c1::Paris}} is in {{c2::France}}', ''],
        nowMs: t0,
      );
      expect(ids.length, 2);
      expect((await repo.card(ids[1])).ord, 1);
      final r = await repo.render(ids[1]);
      expect(r.question, 'Paris is in <span class="cloze">[...]</span>');
      expect(r.answer, 'Paris is in <span class="cloze">France</span><br>');
    });

    test('新卡位置每条笔记加 1', () async {
      final a = await repo.addNote(
        noteTypeId: kBasicTypeId,
        deckId: kDefaultDeckId,
        fields: ['a', '1'],
        nowMs: t0,
      );
      final b = await repo.addNote(
        noteTypeId: kBasicTypeId,
        deckId: kDefaultDeckId,
        fields: ['b', '2'],
        nowMs: t0,
      );
      expect((await repo.card(a.single)).due, 1);
      expect((await repo.card(b.single)).due, 2);
      expect(b.single, a.single + 1);
    });

    test('不会生成卡片时报错且不写入', () async {
      expect(
        () => repo.addNote(
          noteTypeId: kBasicTypeId,
          deckId: kDefaultDeckId,
          fields: ['', 'x'],
          nowMs: t0,
        ),
        throwsStateError,
      );
      expect(await repo.cardsOfDeck(kDefaultDeckId), isEmpty);
    });
  });

  group('评分', () {
    test('新卡 Good → 学习中，兄弟卡被 bury，计数 +1', () async {
      final ids = await repo.addNote(
        noteTypeId: kBasicReversedTypeId,
        deckId: kDefaultDeckId,
        fields: ['hello', '你好'],
        nowMs: t0 + 1000,
      );
      final res = await repo.answer(
        cardId: ids[0],
        rating: Rating.good,
        nowMs: t0 + minute,
        utcOffsetMinutes: sh,
        timeTakenMs: 5000,
      );
      expect(res.card.type, CardType.learn);
      expect(res.card.queue, CardQueue.learn);
      expect(res.card.due, t0 + minute + 10 * minute);
      expect(res.card.left, 1);
      expect(res.card.reps, 1);
      expect(await repo.card(ids[0]), res.card);
      expect((await repo.card(ids[1])).queue, CardQueue.schedBuried);
      expect(await repo.doneToday(kDefaultDeckId, 0), (1, 0));

      final log = await repo.revlogOf(ids[0]);
      expect(log, [
        RevlogEntry(
          id: t0 + minute,
          cardId: ids[0],
          button: 3,
          ivl: -600,
          lastIvl: 0,
          factor: 0,
          timeTakenMs: 5000,
          type: RevlogType.learn,
        ),
      ]);
    });

    test('学习两步后毕业，用时封顶 60 秒', () async {
      final id = (await repo.addNote(
        noteTypeId: kBasicTypeId,
        deckId: kDefaultDeckId,
        fields: ['a', 'b'],
        nowMs: t0,
      )).single;
      await repo.answer(
        cardId: id,
        rating: Rating.good,
        nowMs: t0 + minute,
        utcOffsetMinutes: sh,
        timeTakenMs: 1000,
      );
      final res = await repo.answer(
        cardId: id,
        rating: Rating.good,
        nowMs: t0 + 11 * minute,
        utcOffsetMinutes: sh,
        timeTakenMs: 70000,
      );
      expect(res.card.type, CardType.review);
      expect(res.card.queue, CardQueue.review);
      expect(res.card.ivl, 1);
      expect(res.card.due, 1);
      expect(res.card.ease, 2500);
      expect(res.revlog.lastIvl, -600);
      expect(res.revlog.timeTakenMs, 60000);
      expect((await repo.revlogOf(id)).length, 2);
      // 同一张卡只算一次新卡
      expect(await repo.doneToday(kDefaultDeckId, 0), (1, 0));
    });

    test('新卡 Easy 直接毕业（带 fuzz）', () async {
      final id = (await repo.addNote(
        noteTypeId: kBasicTypeId,
        deckId: kDefaultDeckId,
        fields: ['a', 'b'],
        nowMs: t0 + 3000,
      )).single;
      final res = await repo.answer(
        cardId: id,
        rating: Rating.easy,
        nowMs: t0 + 5000,
        utcOffsetMinutes: sh,
        timeTakenMs: 1000,
      );
      expect(res.card.type, CardType.review);
      expect(res.card.ivl, 3);
      expect(res.card.due, 3);
    });

    test('复习卡忘记 → 重学，触发 leech 加标签，计入复习数', () async {
      final ids = await repo.addNote(
        noteTypeId: kBasicReversedTypeId,
        deckId: kDefaultDeckId,
        fields: ['hello', '你好'],
        nowMs: t0 + 1000,
      );
      await repo.answer(
        cardId: ids[0],
        rating: Rating.good,
        nowMs: t0 + minute,
        utcOffsetMinutes: sh,
        timeTakenMs: 1000,
      );
      await repo.answer(
        cardId: ids[0],
        rating: Rating.good,
        nowMs: t0 + 11 * minute,
        utcOffsetMinutes: sh,
        timeTakenMs: 1000,
      );
      await repo.savePreset(
        kDefaultConfigId,
        const DeckPreset(leechThreshold: 1),
      );
      final res = await repo.answer(
        cardId: ids[0],
        rating: Rating.again,
        nowMs: t0 + day + 3600000,
        utcOffsetMinutes: sh,
        timeTakenMs: 3000,
      );
      expect(res.card.type, CardType.relearn);
      expect(res.card.queue, CardQueue.learn);
      expect(res.card.lapses, 1);
      expect(res.card.ease, 2300);
      expect(res.card.ivl, 1);
      expect(res.leechTriggered, true);
      expect(res.revlog.type, RevlogType.review);
      expect(res.revlog.lastIvl, 1);
      expect(res.revlog.ivl, -600);
      expect(await repo.noteTags(res.card.noteId), ' leech ');
      expect(await repo.doneToday(kDefaultDeckId, 1), (0, 1));
    });
  });

  group('今日队列', () {
    test('每日新卡上限', () async {
      await repo.savePreset(kDefaultConfigId, const DeckPreset(newPerDay: 2));
      for (final w in ['a', 'b', 'c']) {
        await repo.addNote(
          noteTypeId: kBasicTypeId,
          deckId: kDefaultDeckId,
          fields: [w, w],
          nowMs: t0,
        );
      }
      var q = await repo.todayQueue(
        deckId: kDefaultDeckId,
        nowMs: t0 + minute,
        utcOffsetMinutes: sh,
      );
      expect(q.newCount, 2);
      expect(q.main.first.due, 1);
      await repo.answer(
        cardId: q.main.first.id,
        rating: Rating.good,
        nowMs: t0 + minute,
        utcOffsetMinutes: sh,
        timeTakenMs: 1000,
      );
      q = await repo.todayQueue(
        deckId: kDefaultDeckId,
        nowMs: t0 + 2 * minute,
        utcOffsetMinutes: sh,
      );
      expect(q.newCount, 1);
      expect(q.learnCount, 1);
      expect(q.reviewCount, 0);
    });

    test('第二天自动解除 bury，毕业卡进入复习', () async {
      final ids = await repo.addNote(
        noteTypeId: kBasicReversedTypeId,
        deckId: kDefaultDeckId,
        fields: ['hello', '你好'],
        nowMs: t0 + 1000,
      );
      await repo.answer(
        cardId: ids[0],
        rating: Rating.good,
        nowMs: t0 + minute,
        utcOffsetMinutes: sh,
        timeTakenMs: 1000,
      );
      await repo.answer(
        cardId: ids[0],
        rating: Rating.good,
        nowMs: t0 + 11 * minute,
        utcOffsetMinutes: sh,
        timeTakenMs: 1000,
      );
      var q = await repo.todayQueue(
        deckId: kDefaultDeckId,
        nowMs: t0 + 12 * minute,
        utcOffsetMinutes: sh,
      );
      expect((q.newCount, q.learnCount, q.reviewCount), (0, 0, 0));
      q = await repo.todayQueue(
        deckId: kDefaultDeckId,
        nowMs: t0 + day,
        utcOffsetMinutes: sh,
      );
      expect((q.newCount, q.learnCount, q.reviewCount), (1, 0, 1));
      expect((await repo.card(ids[1])).queue, CardQueue.newCard);
    });

    test('队列只含本卡组', () async {
      final other = await repo.createDeck('Other', nowMs: t0);
      await repo.addNote(
        noteTypeId: kBasicTypeId,
        deckId: other,
        fields: ['x', 'y'],
        nowMs: t0,
      );
      final q = await repo.todayQueue(
        deckId: kDefaultDeckId,
        nowMs: t0,
        utcOffsetMinutes: sh,
      );
      expect(q.main, isEmpty);
      final q2 = await repo.todayQueue(
        deckId: other,
        nowMs: t0,
        utcOffsetMinutes: sh,
      );
      expect(q2.newCount, 1);
    });
  });
}
