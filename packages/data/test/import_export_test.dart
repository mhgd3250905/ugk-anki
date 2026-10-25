import 'package:drift/native.dart';
import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';
import 'package:ugk_data/ugk_data.dart';

const t0 = 1792814400000;

void main() {
  group('parseCsv', () {
    test('逗号 + 引号 + 引号内换行和逗号', () {
      final t = parseCsv('a,"b, c"\n"line1\nline2","say ""hi"""\n');
      expect(t.delimiter, ',');
      expect(t.rows, [
        ['a', 'b, c'],
        ['line1\nline2', 'say "hi"'],
      ]);
    });

    test('自动识别 tab 和分号；去 BOM；跳过空行；CRLF', () {
      expect(parseCsv('\uFEFFx\ty\r\n\r\nz\tw').rows, [
        ['x', 'y'],
        ['z', 'w'],
      ]);
      final semi = parseCsv('a;b;c\n1;2;3');
      expect(semi.delimiter, ';');
      expect(semi.columnCount, 3);
    });

    test('Anki 文件头', () {
      final t = parseCsv(
        '#separator:Pipe\n#html:true\n#tags column:3\n#deck column:4\nq|a|t1 t2|D\n',
      );
      expect(t.delimiter, '|');
      expect(t.html, true);
      expect(t.tagsColumn, 2);
      expect(t.deckColumn, 3);
      expect(t.notetypeColumn, isNull);
      expect(t.rows.single, ['q', 'a', 't1 t2', 'D']);
    });

    test('writeCsv 再 parseCsv 原样还原', () {
      final rows = [
        ['a\tb', 'c"d', 'e\nf'],
        ['', 'x', 'y'],
      ];
      final back = parseCsv(writeCsv(rows, header: ['#separator:tab']));
      expect(back.rows, rows);
    });

    test('plainToHtml', () {
      expect(plainToHtml('a<b>&\nc'), 'a&lt;b&gt;&amp;<br>c');
    });
  });

  group('导入导出', () {
    late UgkDatabase db;
    late UgkRepository repo;

    setUp(() async {
      db = UgkDatabase(NativeDatabase.memory());
      repo = UgkRepository(db);
      await repo.initIfEmpty(nowMs: t0);
    });

    tearDown(() => db.close());

    test('按列映射导入 Basic；纯文本转义；标签列 + 额外标签', () async {
      final t = parseCsv('hello,你好,街舞 邀约\n<b>x</b>,y,\n');
      final r = await repo.importCsv(
        t,
        const ImportOptions(
          noteTypeId: kBasicTypeId,
          deckId: kDefaultDeckId,
          fieldColumns: [0, 1],
          tagsColumn: 2,
          extraTags: ['导入'],
        ),
        nowMs: t0,
      );
      expect((r.notes, r.cards, r.duplicates, r.empty), (2, 2, 0, 0));
      final cards = await repo.cardsOfDeck(kDefaultDeckId);
      expect(cards.length, 2);
      expect(await repo.noteTags(cards.first.noteId), ' 街舞 邀约 导入 ');
      final second = await repo.render(cards.last.id);
      expect(second.question, contains('&lt;b&gt;x&lt;/b&gt;'));
    });

    test('跳过表头行', () async {
      final r = await repo.importCsv(
        parseCsv('front,back\nq,a\n'),
        const ImportOptions(
          noteTypeId: kBasicTypeId,
          deckId: kDefaultDeckId,
          fieldColumns: [0, 1],
          skipFirstRow: true,
        ),
        nowMs: t0,
      );
      expect(r.notes, 1);
      final c = (await repo.cardsOfDeck(kDefaultDeckId)).single;
      expect((await repo.render(c.id)).question, contains('q'));
    });

    test('允许 HTML 时原样保留', () async {
      await repo.importCsv(
        parseCsv('<b>x</b>,y'),
        const ImportOptions(
          noteTypeId: kBasicTypeId,
          deckId: kDefaultDeckId,
          fieldColumns: [0, 1],
          allowHtml: true,
        ),
        nowMs: t0,
      );
      final c = (await repo.cardsOfDeck(kDefaultDeckId)).single;
      expect((await repo.render(c.id)).question, contains('<b>x</b>'));
    });

    test('重复跳过 / 照样导入；空第一字段计入 empty', () async {
      const opts = ImportOptions(
        noteTypeId: kBasicTypeId,
        deckId: kDefaultDeckId,
        fieldColumns: [0, 1],
      );
      final t = parseCsv('a,1\na,2\n,3\nb,4');
      final r1 = await repo.importCsv(t, opts, nowMs: t0);
      expect((r1.notes, r1.duplicates, r1.empty), (2, 1, 1));
      final r2 = await repo.importCsv(t, opts, nowMs: t0 + 1000);
      expect((r2.notes, r2.duplicates, r2.empty), (0, 3, 1));
      final r3 = await repo.importCsv(
        parseCsv('a,9'),
        const ImportOptions(
          noteTypeId: kBasicTypeId,
          deckId: kDefaultDeckId,
          fieldColumns: [0, 1],
          duplicates: DuplicateMode.add,
        ),
        nowMs: t0 + 2000,
      );
      expect(r3.notes, 1);
    });

    test('字段列为 null 时留空；Cloze 无挖空跳过', () async {
      final r = await repo.importCsv(
        parseCsv('{{c1::Paris}} is big,x\nno cloze,y'),
        const ImportOptions(
          noteTypeId: kClozeTypeId,
          deckId: kDefaultDeckId,
          fieldColumns: [0, null],
        ),
        nowMs: t0,
      );
      expect((r.notes, r.cards, r.empty), (1, 1, 1));
    });

    test('导出 → 新库导入：类型、卡组（含新建）、字段、标签都还原', () async {
      final dance = await repo.createDeck('English::Dance', nowMs: t0);
      await repo.addNote(
        noteTypeId: kBasicReversedTypeId,
        deckId: dance,
        fields: ['Q\tq', 'A "a"'],
        tags: ['街舞'],
        nowMs: t0,
      );
      await repo.addNote(
        noteTypeId: kClozeTypeId,
        deckId: kDefaultDeckId,
        fields: ['{{c1::x}} y', 'extra'],
        nowMs: t0 + 1,
      );
      final all = await repo.exportCsv();
      expect(
        all,
        startsWith('#separator:tab\n#html:true\n#notetype column:1\n'),
      );
      final onlyDance = await repo.exportCsv(deckId: dance);
      expect(parseCsv(onlyDance).rows.length, 1);

      final db2 = UgkDatabase(NativeDatabase.memory());
      final repo2 = UgkRepository(db2);
      await repo2.initIfEmpty(nowMs: t0);
      final t = parseCsv(all);
      final r = await repo2.importCsv(
        t,
        ImportOptions(
          noteTypeId: kBasicTypeId,
          deckId: kDefaultDeckId,
          fieldColumns: const [],
          allowHtml: t.html ?? false,
        ),
        nowMs: t0 + 10,
      );
      expect((r.notes, r.cards), (2, 3));
      final d2 = (await repo2.decks()).firstWhere(
        (d) => d.name == 'English::Dance',
      );
      final cards = await repo2.cardsOfDeck(d2.id);
      expect(cards.length, 2);
      final rendered = await repo2.render(cards.first.id);
      expect(rendered.question, contains('Q\tq'));
      expect(await repo2.noteTags(cards.first.noteId), ' 街舞 ');
      await db2.close();
    });

    test('备份 → 恢复：覆盖新内容、复习记录还在', () async {
      final ids = await repo.addNote(
        noteTypeId: kBasicTypeId,
        deckId: kDefaultDeckId,
        fields: ['a', 'b'],
        nowMs: t0,
      );
      await repo.answer(
        cardId: ids.single,
        rating: Rating.good,
        nowMs: t0,
        utcOffsetMinutes: 480,
        timeTakenMs: 1000,
      );
      final backup = await repo.backupJson(nowMs: t0);

      await repo.createDeck('later', nowMs: t0 + 5);
      await repo.addNote(
        noteTypeId: kBasicTypeId,
        deckId: kDefaultDeckId,
        fields: ['c', 'd'],
        nowMs: t0 + 5,
      );
      await repo.restoreJson(backup);

      expect((await repo.decks()).map((d) => d.name), ['Default']);
      final cards = await repo.cardsOfDeck(kDefaultDeckId);
      expect(cards.single.reps, 1);
      expect((await repo.revlogOf(cards.single.id)).length, 1);
      // 恢复后还能继续加笔记（id、nextNewPos 正常）
      await repo.addNote(
        noteTypeId: kBasicTypeId,
        deckId: kDefaultDeckId,
        fields: ['e', 'f'],
        nowMs: t0 + 6,
      );
      expect((await repo.cardsOfDeck(kDefaultDeckId)).length, 2);
    });

    test('坏备份抛 FormatException，库不变', () async {
      for (final bad in [
        'not json',
        '{"magic":"x"}',
        '{"magic":"ugk-anki-backup","version":1,"schemaVersion":99,"tables":{}}',
        '{"magic":"ugk-anki-backup","version":1,"schemaVersion":1,"tables":{}}',
      ]) {
        await expectLater(repo.restoreJson(bad), throwsFormatException);
      }
      expect((await repo.decks()).single.name, 'Default');
    });
  });
}
