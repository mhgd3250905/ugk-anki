import 'package:drift/drift.dart';

/// 集合元信息（只有一行，id = 1）
@DataClassName('MetaRow')
class CollectionMeta extends Table {
  IntColumn get id => integer()();
  IntColumn get createdMs => integer()();
  IntColumn get nextNewPos => integer()();
  IntColumn get lastUnburyDay => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 卡组设置（preset），参数存成 JSON
@DataClassName('DeckConfigRow')
class DeckConfigs extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get configJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 卡组
@DataClassName('DeckRow')
class Decks extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().unique()();
  IntColumn get configId => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 笔记类型，字段和模板存成 JSON
@DataClassName('NoteTypeRow')
class NoteTypes extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get kind => integer()();
  TextColumn get fieldsJson => text()();
  TextColumn get templatesJson => text()();
  TextColumn get css => text()();
  IntColumn get sortFieldIdx => integer()();
  IntColumn get mtimeMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 笔记
@DataClassName('NoteRow')
@TableIndex(name: 'idx_notes_checksum', columns: {#checksum})
class Notes extends Table {
  IntColumn get id => integer()();
  TextColumn get guid => text().unique()();
  IntColumn get noteTypeId => integer()();
  TextColumn get fields => text()();
  TextColumn get sortField => text()();
  IntColumn get checksum => integer()();
  TextColumn get tags => text()();
  IntColumn get mtimeMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 卡片
@DataClassName('CardRow')
@TableIndex(name: 'idx_cards_deck_queue_due', columns: {#deckId, #queue, #due})
@TableIndex(name: 'idx_cards_note', columns: {#noteId})
class Cards extends Table {
  IntColumn get id => integer()();
  IntColumn get noteId => integer()();
  IntColumn get deckId => integer()();
  IntColumn get ord => integer()();
  IntColumn get type => integer()();
  IntColumn get queue => integer()();
  IntColumn get due => integer()();
  IntColumn get ivl => integer()();
  IntColumn get ease => integer()();
  IntColumn get reps => integer()();
  IntColumn get lapses => integer()();
  IntColumn get left => integer()();
  IntColumn get flags => integer()();
  IntColumn get mtimeMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 复习日志
@DataClassName('RevlogRow')
@TableIndex(name: 'idx_revlog_card', columns: {#cardId})
class Revlog extends Table {
  IntColumn get id => integer()();
  IntColumn get cardId => integer()();
  IntColumn get button => integer()();
  IntColumn get ivl => integer()();
  IntColumn get lastIvl => integer()();
  IntColumn get factor => integer()();
  IntColumn get timeTakenMs => integer()();
  IntColumn get type => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 每个卡组每天已学的新卡数、复习数
@DataClassName('DayCountRow')
class DeckDayCounts extends Table {
  IntColumn get deckId => integer()();
  IntColumn get day => integer()();
  IntColumn get newDone => integer()();
  IntColumn get reviewDone => integer()();

  @override
  Set<Column> get primaryKey => {deckId, day};
}
