import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ugk_core/ugk_core.dart';

import 'csv_codec.dart';
import 'repository.dart';

/// 重复笔记的处理方式（重复 = 同一笔记类型、第一个字段去 HTML 后相同）
enum DuplicateMode {
  /// 跳过
  skip,

  /// 照样导入
  add,
}

/// 导入设置
class ImportOptions {
  const ImportOptions({
    required this.noteTypeId,
    required this.deckId,
    required this.fieldColumns,
    this.tagsColumn,
    this.allowHtml = false,
    this.duplicates = DuplicateMode.skip,
    this.extraTags = const [],
    this.skipFirstRow = false,
  });

  /// 默认笔记类型（文件里有 notetype 列且能对上名字时以文件为准）
  final int noteTypeId;

  /// 默认卡组（文件里有 deck 列时以文件为准，不存在就新建）
  final int deckId;

  /// 第 i 个字段取第几列（0 起）；null = 留空
  final List<int?> fieldColumns;

  /// 标签列（0 起）；null = 没有
  final int? tagsColumn;

  /// false 时把单元格当纯文本：转义 & < > 并把换行变 <br>
  final bool allowHtml;

  final DuplicateMode duplicates;

  /// 给每条导入的笔记额外加的标签
  final List<String> extraTags;

  /// 第一行是表头，不导入
  final bool skipFirstRow;
}

/// 导入结果
class ImportResult {
  const ImportResult({
    required this.notes,
    required this.cards,
    required this.duplicates,
    required this.empty,
  });

  /// 新增笔记数
  final int notes;

  /// 新增卡片数
  final int cards;

  /// 因重复跳过的行
  final int duplicates;

  /// 生成不了卡片而跳过的行（例如第一个字段为空）
  final int empty;
}

/// 备份文件格式标记
const kBackupMagic = 'ugk-anki-backup';

/// 备份格式版本
const kBackupVersion = 1;

/// 按依赖顺序排列的表名（恢复时按这个顺序插入）
const _backupTables = [
  'collection_meta',
  'deck_configs',
  'decks',
  'note_types',
  'notes',
  'cards',
  'revlog',
  'deck_day_counts',
];

/// CSV 导入导出、整库备份恢复
extension ImportExport on UgkRepository {
  /// 按设置导入 CSV 表
  Future<ImportResult> importCsv(
    CsvTable table,
    ImportOptions o, {
    required int nowMs,
  }) {
    return db.transaction(() async {
      final types = {for (final t in await noteTypes()) t.id: t};
      final typesByName = {
        for (final t in types.values) t.name.toLowerCase(): t,
      };
      final deckIds = <String, int>{};
      final special = {
        o.tagsColumn ?? table.tagsColumn,
        table.notetypeColumn,
        table.deckColumn,
      }.whereType<int>().toSet();
      final tagsCol = o.tagsColumn ?? table.tagsColumn;
      final seen = <int, Set<String>>{};

      Future<Set<String>> existing(int typeId) async {
        final cached = seen[typeId];
        if (cached != null) return cached;
        final rows = await (db.select(
          db.notes,
        )..where((n) => n.noteTypeId.equals(typeId))).get();
        return seen[typeId] = {
          for (final r in rows) stripHtml(splitFields(r.fields).first).trim(),
        };
      }

      String cell(List<String> row, int? i) =>
          i == null || i >= row.length ? '' : row[i];

      var notes = 0, cards = 0, dups = 0, empty = 0;
      var clock = nowMs;
      for (final row in table.rows.skip(o.skipFirstRow ? 1 : 0)) {
        // 笔记类型
        var type = types[o.noteTypeId]!;
        var byFileType = false;
        if (table.notetypeColumn != null) {
          final t =
              typesByName[cell(row, table.notetypeColumn).trim().toLowerCase()];
          if (t != null) {
            type = t;
            byFileType = true;
          }
        }
        // 字段
        List<String> fields;
        if (byFileType || table.notetypeColumn != null) {
          final cols = [
            for (var i = 0; i < row.length; i++)
              if (!special.contains(i)) row[i],
          ];
          fields = [
            for (var i = 0; i < type.fields.length; i++)
              i < cols.length ? cols[i] : '',
          ];
        } else {
          fields = [
            for (var i = 0; i < type.fields.length; i++)
              cell(row, i < o.fieldColumns.length ? o.fieldColumns[i] : null),
          ];
        }
        if (!o.allowHtml) fields = [for (final f in fields) plainToHtml(f)];
        // 卡组
        var deckId = o.deckId;
        if (table.deckColumn != null) {
          final name = cell(row, table.deckColumn).trim();
          if (name.isNotEmpty) {
            deckId = deckIds[name] ??= await ensureDeck(name, nowMs: clock);
          }
        }
        // 重复
        final key = stripHtml(fields.first).trim();
        final have = await existing(type.id);
        if (o.duplicates == DuplicateMode.skip &&
            key.isNotEmpty &&
            have.contains(key)) {
          dups++;
          continue;
        }
        final tags = [...parseTags(cell(row, tagsCol)), ...o.extraTags];
        try {
          final ids = await addNote(
            noteTypeId: type.id,
            deckId: deckId,
            fields: fields,
            tags: tags,
            nowMs: clock,
          );
          notes++;
          cards += ids.length;
          have.add(key);
          clock++;
        } on StateError {
          empty++;
        }
      }
      return ImportResult(
        notes: notes,
        cards: cards,
        duplicates: dups,
        empty: empty,
      );
    });
  }

  /// 导出笔记为 Anki 兼容的 TSV（含 notetype / deck / tags 列，可原样导回）。
  /// [deckId] 为 null 时导出全部；否则包含其子卡组。
  Future<String> exportCsv({int? deckId}) async {
    final allDecks = await decks();
    final deckName = {for (final d in allDecks) d.id: d.name};
    Set<int>? wanted;
    if (deckId != null) {
      final root = deckName[deckId]!;
      wanted = {
        for (final d in allDecks)
          if (d.name == root || d.name.startsWith('$root::')) d.id,
      };
    }
    final cardRows =
        await (db.select(db.cards)..orderBy([
              (c) => OrderingTerm.asc(c.noteId),
              (c) => OrderingTerm.asc(c.ord),
            ]))
            .get();
    final noteDeck = <int, int>{};
    for (final c in cardRows) {
      if (wanted != null && !wanted.contains(c.deckId)) continue;
      noteDeck.putIfAbsent(c.noteId, () => c.deckId);
    }
    final types = {for (final t in await noteTypes()) t.id: t};
    final noteRows =
        await (db.select(db.notes)
              ..where((n) => n.id.isIn(noteDeck.keys))
              ..orderBy([(n) => OrderingTerm.asc(n.id)]))
            .get();
    final width = noteRows.fold<int>(
      1,
      (m, n) =>
          splitFields(n.fields).length > m ? splitFields(n.fields).length : m,
    );
    final rows = [
      for (final n in noteRows)
        [
          types[n.noteTypeId]?.name ?? '',
          deckName[noteDeck[n.id]] ?? '',
          ...() {
            final f = splitFields(n.fields);
            return [for (var i = 0; i < width; i++) i < f.length ? f[i] : ''];
          }(),
          n.tags.trim(),
        ],
    ];
    return writeCsv(
      rows,
      header: [
        '#separator:tab',
        '#html:true',
        '#notetype column:1',
        '#deck column:2',
        '#tags column:${width + 3}',
      ],
    );
  }

  /// 整库备份成 JSON 字符串
  Future<String> backupJson({required int nowMs}) async {
    final tables = <String, List<Map<String, Object?>>>{};
    for (final t in _backupTables) {
      final rows = await db.customSelect('SELECT * FROM $t').get();
      tables[t] = [for (final r in rows) r.data];
    }
    return jsonEncode({
      'magic': kBackupMagic,
      'version': kBackupVersion,
      'schemaVersion': db.schemaVersion,
      'createdMs': nowMs,
      'tables': tables,
    });
  }

  /// 用备份覆盖整个库。格式不对时抛 FormatException，库保持原样。
  Future<void> restoreJson(String json) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      throw const FormatException('不是有效的备份文件');
    }
    if (decoded is! Map ||
        decoded['magic'] != kBackupMagic ||
        decoded['version'] != kBackupVersion) {
      throw const FormatException('这不是本应用的备份文件');
    }
    if (decoded['schemaVersion'] != db.schemaVersion) {
      throw const FormatException('这个备份来自不兼容的版本，无法恢复');
    }
    final tables = decoded['tables'];
    if (tables is! Map || !_backupTables.every(tables.containsKey)) {
      throw const FormatException('备份文件不完整，可能已损坏');
    }
    await db.transaction(() async {
      for (final t in _backupTables.reversed) {
        await db.customStatement('DELETE FROM $t');
      }
      for (final t in _backupTables) {
        for (final row in (tables[t] as List).cast<Map>()) {
          final cols = row.keys.cast<String>().toList();
          await db.customStatement(
            'INSERT INTO $t (${cols.join(', ')}) '
            'VALUES (${List.filled(cols.length, '?').join(', ')})',
            [for (final c in cols) row[c]],
          );
        }
      }
    });
    db.notifyUpdates({for (final t in db.allTables) TableUpdate.onTable(t)});
  }
}
