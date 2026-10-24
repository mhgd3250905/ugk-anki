// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CollectionMetaTable extends CollectionMeta
    with TableInfo<$CollectionMetaTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdMsMeta = const VerificationMeta(
    'createdMs',
  );
  @override
  late final GeneratedColumn<int> createdMs = GeneratedColumn<int>(
    'created_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextNewPosMeta = const VerificationMeta(
    'nextNewPos',
  );
  @override
  late final GeneratedColumn<int> nextNewPos = GeneratedColumn<int>(
    'next_new_pos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUnburyDayMeta = const VerificationMeta(
    'lastUnburyDay',
  );
  @override
  late final GeneratedColumn<int> lastUnburyDay = GeneratedColumn<int>(
    'last_unbury_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdMs,
    nextNewPos,
    lastUnburyDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_ms')) {
      context.handle(
        _createdMsMeta,
        createdMs.isAcceptableOrUnknown(data['created_ms']!, _createdMsMeta),
      );
    } else if (isInserting) {
      context.missing(_createdMsMeta);
    }
    if (data.containsKey('next_new_pos')) {
      context.handle(
        _nextNewPosMeta,
        nextNewPos.isAcceptableOrUnknown(
          data['next_new_pos']!,
          _nextNewPosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextNewPosMeta);
    }
    if (data.containsKey('last_unbury_day')) {
      context.handle(
        _lastUnburyDayMeta,
        lastUnburyDay.isAcceptableOrUnknown(
          data['last_unbury_day']!,
          _lastUnburyDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUnburyDayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_ms'],
      )!,
      nextNewPos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_new_pos'],
      )!,
      lastUnburyDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_unbury_day'],
      )!,
    );
  }

  @override
  $CollectionMetaTable createAlias(String alias) {
    return $CollectionMetaTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final int id;
  final int createdMs;
  final int nextNewPos;
  final int lastUnburyDay;
  const MetaRow({
    required this.id,
    required this.createdMs,
    required this.nextNewPos,
    required this.lastUnburyDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_ms'] = Variable<int>(createdMs);
    map['next_new_pos'] = Variable<int>(nextNewPos);
    map['last_unbury_day'] = Variable<int>(lastUnburyDay);
    return map;
  }

  CollectionMetaCompanion toCompanion(bool nullToAbsent) {
    return CollectionMetaCompanion(
      id: Value(id),
      createdMs: Value(createdMs),
      nextNewPos: Value(nextNewPos),
      lastUnburyDay: Value(lastUnburyDay),
    );
  }

  factory MetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(
      id: serializer.fromJson<int>(json['id']),
      createdMs: serializer.fromJson<int>(json['createdMs']),
      nextNewPos: serializer.fromJson<int>(json['nextNewPos']),
      lastUnburyDay: serializer.fromJson<int>(json['lastUnburyDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdMs': serializer.toJson<int>(createdMs),
      'nextNewPos': serializer.toJson<int>(nextNewPos),
      'lastUnburyDay': serializer.toJson<int>(lastUnburyDay),
    };
  }

  MetaRow copyWith({
    int? id,
    int? createdMs,
    int? nextNewPos,
    int? lastUnburyDay,
  }) => MetaRow(
    id: id ?? this.id,
    createdMs: createdMs ?? this.createdMs,
    nextNewPos: nextNewPos ?? this.nextNewPos,
    lastUnburyDay: lastUnburyDay ?? this.lastUnburyDay,
  );
  MetaRow copyWithCompanion(CollectionMetaCompanion data) {
    return MetaRow(
      id: data.id.present ? data.id.value : this.id,
      createdMs: data.createdMs.present ? data.createdMs.value : this.createdMs,
      nextNewPos: data.nextNewPos.present
          ? data.nextNewPos.value
          : this.nextNewPos,
      lastUnburyDay: data.lastUnburyDay.present
          ? data.lastUnburyDay.value
          : this.lastUnburyDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('id: $id, ')
          ..write('createdMs: $createdMs, ')
          ..write('nextNewPos: $nextNewPos, ')
          ..write('lastUnburyDay: $lastUnburyDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdMs, nextNewPos, lastUnburyDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaRow &&
          other.id == this.id &&
          other.createdMs == this.createdMs &&
          other.nextNewPos == this.nextNewPos &&
          other.lastUnburyDay == this.lastUnburyDay);
}

class CollectionMetaCompanion extends UpdateCompanion<MetaRow> {
  final Value<int> id;
  final Value<int> createdMs;
  final Value<int> nextNewPos;
  final Value<int> lastUnburyDay;
  const CollectionMetaCompanion({
    this.id = const Value.absent(),
    this.createdMs = const Value.absent(),
    this.nextNewPos = const Value.absent(),
    this.lastUnburyDay = const Value.absent(),
  });
  CollectionMetaCompanion.insert({
    this.id = const Value.absent(),
    required int createdMs,
    required int nextNewPos,
    required int lastUnburyDay,
  }) : createdMs = Value(createdMs),
       nextNewPos = Value(nextNewPos),
       lastUnburyDay = Value(lastUnburyDay);
  static Insertable<MetaRow> custom({
    Expression<int>? id,
    Expression<int>? createdMs,
    Expression<int>? nextNewPos,
    Expression<int>? lastUnburyDay,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdMs != null) 'created_ms': createdMs,
      if (nextNewPos != null) 'next_new_pos': nextNewPos,
      if (lastUnburyDay != null) 'last_unbury_day': lastUnburyDay,
    });
  }

  CollectionMetaCompanion copyWith({
    Value<int>? id,
    Value<int>? createdMs,
    Value<int>? nextNewPos,
    Value<int>? lastUnburyDay,
  }) {
    return CollectionMetaCompanion(
      id: id ?? this.id,
      createdMs: createdMs ?? this.createdMs,
      nextNewPos: nextNewPos ?? this.nextNewPos,
      lastUnburyDay: lastUnburyDay ?? this.lastUnburyDay,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdMs.present) {
      map['created_ms'] = Variable<int>(createdMs.value);
    }
    if (nextNewPos.present) {
      map['next_new_pos'] = Variable<int>(nextNewPos.value);
    }
    if (lastUnburyDay.present) {
      map['last_unbury_day'] = Variable<int>(lastUnburyDay.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionMetaCompanion(')
          ..write('id: $id, ')
          ..write('createdMs: $createdMs, ')
          ..write('nextNewPos: $nextNewPos, ')
          ..write('lastUnburyDay: $lastUnburyDay')
          ..write(')'))
        .toString();
  }
}

class $DeckConfigsTable extends DeckConfigs
    with TableInfo<$DeckConfigsTable, DeckConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeckConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, configJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckConfigRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeckConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckConfigRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
    );
  }

  @override
  $DeckConfigsTable createAlias(String alias) {
    return $DeckConfigsTable(attachedDatabase, alias);
  }
}

class DeckConfigRow extends DataClass implements Insertable<DeckConfigRow> {
  final int id;
  final String name;
  final String configJson;
  const DeckConfigRow({
    required this.id,
    required this.name,
    required this.configJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['config_json'] = Variable<String>(configJson);
    return map;
  }

  DeckConfigsCompanion toCompanion(bool nullToAbsent) {
    return DeckConfigsCompanion(
      id: Value(id),
      name: Value(name),
      configJson: Value(configJson),
    );
  }

  factory DeckConfigRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckConfigRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      configJson: serializer.fromJson<String>(json['configJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'configJson': serializer.toJson<String>(configJson),
    };
  }

  DeckConfigRow copyWith({int? id, String? name, String? configJson}) =>
      DeckConfigRow(
        id: id ?? this.id,
        name: name ?? this.name,
        configJson: configJson ?? this.configJson,
      );
  DeckConfigRow copyWithCompanion(DeckConfigsCompanion data) {
    return DeckConfigRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckConfigRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('configJson: $configJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, configJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckConfigRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.configJson == this.configJson);
}

class DeckConfigsCompanion extends UpdateCompanion<DeckConfigRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> configJson;
  const DeckConfigsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.configJson = const Value.absent(),
  });
  DeckConfigsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String configJson,
  }) : name = Value(name),
       configJson = Value(configJson);
  static Insertable<DeckConfigRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? configJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (configJson != null) 'config_json': configJson,
    });
  }

  DeckConfigsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? configJson,
  }) {
    return DeckConfigsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      configJson: configJson ?? this.configJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckConfigsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('configJson: $configJson')
          ..write(')'))
        .toString();
  }
}

class $DecksTable extends Decks with TableInfo<$DecksTable, DeckRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _configIdMeta = const VerificationMeta(
    'configId',
  );
  @override
  late final GeneratedColumn<int> configId = GeneratedColumn<int>(
    'config_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, configId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('config_id')) {
      context.handle(
        _configIdMeta,
        configId.isAcceptableOrUnknown(data['config_id']!, _configIdMeta),
      );
    } else if (isInserting) {
      context.missing(_configIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeckRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      configId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}config_id'],
      )!,
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }
}

class DeckRow extends DataClass implements Insertable<DeckRow> {
  final int id;
  final String name;
  final int configId;
  const DeckRow({required this.id, required this.name, required this.configId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['config_id'] = Variable<int>(configId);
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      id: Value(id),
      name: Value(name),
      configId: Value(configId),
    );
  }

  factory DeckRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      configId: serializer.fromJson<int>(json['configId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'configId': serializer.toJson<int>(configId),
    };
  }

  DeckRow copyWith({int? id, String? name, int? configId}) => DeckRow(
    id: id ?? this.id,
    name: name ?? this.name,
    configId: configId ?? this.configId,
  );
  DeckRow copyWithCompanion(DecksCompanion data) {
    return DeckRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      configId: data.configId.present ? data.configId.value : this.configId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('configId: $configId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, configId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.configId == this.configId);
}

class DecksCompanion extends UpdateCompanion<DeckRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> configId;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.configId = const Value.absent(),
  });
  DecksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int configId,
  }) : name = Value(name),
       configId = Value(configId);
  static Insertable<DeckRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? configId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (configId != null) 'config_id': configId,
    });
  }

  DecksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? configId,
  }) {
    return DecksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      configId: configId ?? this.configId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (configId.present) {
      map['config_id'] = Variable<int>(configId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('configId: $configId')
          ..write(')'))
        .toString();
  }
}

class $NoteTypesTable extends NoteTypes
    with TableInfo<$NoteTypesTable, NoteTypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<int> kind = GeneratedColumn<int>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldsJsonMeta = const VerificationMeta(
    'fieldsJson',
  );
  @override
  late final GeneratedColumn<String> fieldsJson = GeneratedColumn<String>(
    'fields_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templatesJsonMeta = const VerificationMeta(
    'templatesJson',
  );
  @override
  late final GeneratedColumn<String> templatesJson = GeneratedColumn<String>(
    'templates_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cssMeta = const VerificationMeta('css');
  @override
  late final GeneratedColumn<String> css = GeneratedColumn<String>(
    'css',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortFieldIdxMeta = const VerificationMeta(
    'sortFieldIdx',
  );
  @override
  late final GeneratedColumn<int> sortFieldIdx = GeneratedColumn<int>(
    'sort_field_idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mtimeMsMeta = const VerificationMeta(
    'mtimeMs',
  );
  @override
  late final GeneratedColumn<int> mtimeMs = GeneratedColumn<int>(
    'mtime_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    fieldsJson,
    templatesJson,
    css,
    sortFieldIdx,
    mtimeMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteTypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('fields_json')) {
      context.handle(
        _fieldsJsonMeta,
        fieldsJson.isAcceptableOrUnknown(data['fields_json']!, _fieldsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldsJsonMeta);
    }
    if (data.containsKey('templates_json')) {
      context.handle(
        _templatesJsonMeta,
        templatesJson.isAcceptableOrUnknown(
          data['templates_json']!,
          _templatesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templatesJsonMeta);
    }
    if (data.containsKey('css')) {
      context.handle(
        _cssMeta,
        css.isAcceptableOrUnknown(data['css']!, _cssMeta),
      );
    } else if (isInserting) {
      context.missing(_cssMeta);
    }
    if (data.containsKey('sort_field_idx')) {
      context.handle(
        _sortFieldIdxMeta,
        sortFieldIdx.isAcceptableOrUnknown(
          data['sort_field_idx']!,
          _sortFieldIdxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sortFieldIdxMeta);
    }
    if (data.containsKey('mtime_ms')) {
      context.handle(
        _mtimeMsMeta,
        mtimeMs.isAcceptableOrUnknown(data['mtime_ms']!, _mtimeMsMeta),
      );
    } else if (isInserting) {
      context.missing(_mtimeMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteTypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteTypeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kind'],
      )!,
      fieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields_json'],
      )!,
      templatesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}templates_json'],
      )!,
      css: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}css'],
      )!,
      sortFieldIdx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_field_idx'],
      )!,
      mtimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mtime_ms'],
      )!,
    );
  }

  @override
  $NoteTypesTable createAlias(String alias) {
    return $NoteTypesTable(attachedDatabase, alias);
  }
}

class NoteTypeRow extends DataClass implements Insertable<NoteTypeRow> {
  final int id;
  final String name;
  final int kind;
  final String fieldsJson;
  final String templatesJson;
  final String css;
  final int sortFieldIdx;
  final int mtimeMs;
  const NoteTypeRow({
    required this.id,
    required this.name,
    required this.kind,
    required this.fieldsJson,
    required this.templatesJson,
    required this.css,
    required this.sortFieldIdx,
    required this.mtimeMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<int>(kind);
    map['fields_json'] = Variable<String>(fieldsJson);
    map['templates_json'] = Variable<String>(templatesJson);
    map['css'] = Variable<String>(css);
    map['sort_field_idx'] = Variable<int>(sortFieldIdx);
    map['mtime_ms'] = Variable<int>(mtimeMs);
    return map;
  }

  NoteTypesCompanion toCompanion(bool nullToAbsent) {
    return NoteTypesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      fieldsJson: Value(fieldsJson),
      templatesJson: Value(templatesJson),
      css: Value(css),
      sortFieldIdx: Value(sortFieldIdx),
      mtimeMs: Value(mtimeMs),
    );
  }

  factory NoteTypeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteTypeRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<int>(json['kind']),
      fieldsJson: serializer.fromJson<String>(json['fieldsJson']),
      templatesJson: serializer.fromJson<String>(json['templatesJson']),
      css: serializer.fromJson<String>(json['css']),
      sortFieldIdx: serializer.fromJson<int>(json['sortFieldIdx']),
      mtimeMs: serializer.fromJson<int>(json['mtimeMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<int>(kind),
      'fieldsJson': serializer.toJson<String>(fieldsJson),
      'templatesJson': serializer.toJson<String>(templatesJson),
      'css': serializer.toJson<String>(css),
      'sortFieldIdx': serializer.toJson<int>(sortFieldIdx),
      'mtimeMs': serializer.toJson<int>(mtimeMs),
    };
  }

  NoteTypeRow copyWith({
    int? id,
    String? name,
    int? kind,
    String? fieldsJson,
    String? templatesJson,
    String? css,
    int? sortFieldIdx,
    int? mtimeMs,
  }) => NoteTypeRow(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    fieldsJson: fieldsJson ?? this.fieldsJson,
    templatesJson: templatesJson ?? this.templatesJson,
    css: css ?? this.css,
    sortFieldIdx: sortFieldIdx ?? this.sortFieldIdx,
    mtimeMs: mtimeMs ?? this.mtimeMs,
  );
  NoteTypeRow copyWithCompanion(NoteTypesCompanion data) {
    return NoteTypeRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      fieldsJson: data.fieldsJson.present
          ? data.fieldsJson.value
          : this.fieldsJson,
      templatesJson: data.templatesJson.present
          ? data.templatesJson.value
          : this.templatesJson,
      css: data.css.present ? data.css.value : this.css,
      sortFieldIdx: data.sortFieldIdx.present
          ? data.sortFieldIdx.value
          : this.sortFieldIdx,
      mtimeMs: data.mtimeMs.present ? data.mtimeMs.value : this.mtimeMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteTypeRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('templatesJson: $templatesJson, ')
          ..write('css: $css, ')
          ..write('sortFieldIdx: $sortFieldIdx, ')
          ..write('mtimeMs: $mtimeMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    fieldsJson,
    templatesJson,
    css,
    sortFieldIdx,
    mtimeMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteTypeRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.fieldsJson == this.fieldsJson &&
          other.templatesJson == this.templatesJson &&
          other.css == this.css &&
          other.sortFieldIdx == this.sortFieldIdx &&
          other.mtimeMs == this.mtimeMs);
}

class NoteTypesCompanion extends UpdateCompanion<NoteTypeRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> kind;
  final Value<String> fieldsJson;
  final Value<String> templatesJson;
  final Value<String> css;
  final Value<int> sortFieldIdx;
  final Value<int> mtimeMs;
  const NoteTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.fieldsJson = const Value.absent(),
    this.templatesJson = const Value.absent(),
    this.css = const Value.absent(),
    this.sortFieldIdx = const Value.absent(),
    this.mtimeMs = const Value.absent(),
  });
  NoteTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int kind,
    required String fieldsJson,
    required String templatesJson,
    required String css,
    required int sortFieldIdx,
    required int mtimeMs,
  }) : name = Value(name),
       kind = Value(kind),
       fieldsJson = Value(fieldsJson),
       templatesJson = Value(templatesJson),
       css = Value(css),
       sortFieldIdx = Value(sortFieldIdx),
       mtimeMs = Value(mtimeMs);
  static Insertable<NoteTypeRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? kind,
    Expression<String>? fieldsJson,
    Expression<String>? templatesJson,
    Expression<String>? css,
    Expression<int>? sortFieldIdx,
    Expression<int>? mtimeMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (fieldsJson != null) 'fields_json': fieldsJson,
      if (templatesJson != null) 'templates_json': templatesJson,
      if (css != null) 'css': css,
      if (sortFieldIdx != null) 'sort_field_idx': sortFieldIdx,
      if (mtimeMs != null) 'mtime_ms': mtimeMs,
    });
  }

  NoteTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? kind,
    Value<String>? fieldsJson,
    Value<String>? templatesJson,
    Value<String>? css,
    Value<int>? sortFieldIdx,
    Value<int>? mtimeMs,
  }) {
    return NoteTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      fieldsJson: fieldsJson ?? this.fieldsJson,
      templatesJson: templatesJson ?? this.templatesJson,
      css: css ?? this.css,
      sortFieldIdx: sortFieldIdx ?? this.sortFieldIdx,
      mtimeMs: mtimeMs ?? this.mtimeMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(kind.value);
    }
    if (fieldsJson.present) {
      map['fields_json'] = Variable<String>(fieldsJson.value);
    }
    if (templatesJson.present) {
      map['templates_json'] = Variable<String>(templatesJson.value);
    }
    if (css.present) {
      map['css'] = Variable<String>(css.value);
    }
    if (sortFieldIdx.present) {
      map['sort_field_idx'] = Variable<int>(sortFieldIdx.value);
    }
    if (mtimeMs.present) {
      map['mtime_ms'] = Variable<int>(mtimeMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('templatesJson: $templatesJson, ')
          ..write('css: $css, ')
          ..write('sortFieldIdx: $sortFieldIdx, ')
          ..write('mtimeMs: $mtimeMs')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guidMeta = const VerificationMeta('guid');
  @override
  late final GeneratedColumn<String> guid = GeneratedColumn<String>(
    'guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _noteTypeIdMeta = const VerificationMeta(
    'noteTypeId',
  );
  @override
  late final GeneratedColumn<int> noteTypeId = GeneratedColumn<int>(
    'note_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldsMeta = const VerificationMeta('fields');
  @override
  late final GeneratedColumn<String> fields = GeneratedColumn<String>(
    'fields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortFieldMeta = const VerificationMeta(
    'sortField',
  );
  @override
  late final GeneratedColumn<String> sortField = GeneratedColumn<String>(
    'sort_field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<int> checksum = GeneratedColumn<int>(
    'checksum',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mtimeMsMeta = const VerificationMeta(
    'mtimeMs',
  );
  @override
  late final GeneratedColumn<int> mtimeMs = GeneratedColumn<int>(
    'mtime_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    guid,
    noteTypeId,
    fields,
    sortField,
    checksum,
    tags,
    mtimeMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    } else if (isInserting) {
      context.missing(_guidMeta);
    }
    if (data.containsKey('note_type_id')) {
      context.handle(
        _noteTypeIdMeta,
        noteTypeId.isAcceptableOrUnknown(
          data['note_type_id']!,
          _noteTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_noteTypeIdMeta);
    }
    if (data.containsKey('fields')) {
      context.handle(
        _fieldsMeta,
        fields.isAcceptableOrUnknown(data['fields']!, _fieldsMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldsMeta);
    }
    if (data.containsKey('sort_field')) {
      context.handle(
        _sortFieldMeta,
        sortField.isAcceptableOrUnknown(data['sort_field']!, _sortFieldMeta),
      );
    } else if (isInserting) {
      context.missing(_sortFieldMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('mtime_ms')) {
      context.handle(
        _mtimeMsMeta,
        mtimeMs.isAcceptableOrUnknown(data['mtime_ms']!, _mtimeMsMeta),
      );
    } else if (isInserting) {
      context.missing(_mtimeMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      noteTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_type_id'],
      )!,
      fields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields'],
      )!,
      sortField: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_field'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}checksum'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      mtimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mtime_ms'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final int id;
  final String guid;
  final int noteTypeId;
  final String fields;
  final String sortField;
  final int checksum;
  final String tags;
  final int mtimeMs;
  const NoteRow({
    required this.id,
    required this.guid,
    required this.noteTypeId,
    required this.fields,
    required this.sortField,
    required this.checksum,
    required this.tags,
    required this.mtimeMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['guid'] = Variable<String>(guid);
    map['note_type_id'] = Variable<int>(noteTypeId);
    map['fields'] = Variable<String>(fields);
    map['sort_field'] = Variable<String>(sortField);
    map['checksum'] = Variable<int>(checksum);
    map['tags'] = Variable<String>(tags);
    map['mtime_ms'] = Variable<int>(mtimeMs);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      guid: Value(guid),
      noteTypeId: Value(noteTypeId),
      fields: Value(fields),
      sortField: Value(sortField),
      checksum: Value(checksum),
      tags: Value(tags),
      mtimeMs: Value(mtimeMs),
    );
  }

  factory NoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<int>(json['id']),
      guid: serializer.fromJson<String>(json['guid']),
      noteTypeId: serializer.fromJson<int>(json['noteTypeId']),
      fields: serializer.fromJson<String>(json['fields']),
      sortField: serializer.fromJson<String>(json['sortField']),
      checksum: serializer.fromJson<int>(json['checksum']),
      tags: serializer.fromJson<String>(json['tags']),
      mtimeMs: serializer.fromJson<int>(json['mtimeMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'guid': serializer.toJson<String>(guid),
      'noteTypeId': serializer.toJson<int>(noteTypeId),
      'fields': serializer.toJson<String>(fields),
      'sortField': serializer.toJson<String>(sortField),
      'checksum': serializer.toJson<int>(checksum),
      'tags': serializer.toJson<String>(tags),
      'mtimeMs': serializer.toJson<int>(mtimeMs),
    };
  }

  NoteRow copyWith({
    int? id,
    String? guid,
    int? noteTypeId,
    String? fields,
    String? sortField,
    int? checksum,
    String? tags,
    int? mtimeMs,
  }) => NoteRow(
    id: id ?? this.id,
    guid: guid ?? this.guid,
    noteTypeId: noteTypeId ?? this.noteTypeId,
    fields: fields ?? this.fields,
    sortField: sortField ?? this.sortField,
    checksum: checksum ?? this.checksum,
    tags: tags ?? this.tags,
    mtimeMs: mtimeMs ?? this.mtimeMs,
  );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      guid: data.guid.present ? data.guid.value : this.guid,
      noteTypeId: data.noteTypeId.present
          ? data.noteTypeId.value
          : this.noteTypeId,
      fields: data.fields.present ? data.fields.value : this.fields,
      sortField: data.sortField.present ? data.sortField.value : this.sortField,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      tags: data.tags.present ? data.tags.value : this.tags,
      mtimeMs: data.mtimeMs.present ? data.mtimeMs.value : this.mtimeMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('guid: $guid, ')
          ..write('noteTypeId: $noteTypeId, ')
          ..write('fields: $fields, ')
          ..write('sortField: $sortField, ')
          ..write('checksum: $checksum, ')
          ..write('tags: $tags, ')
          ..write('mtimeMs: $mtimeMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    guid,
    noteTypeId,
    fields,
    sortField,
    checksum,
    tags,
    mtimeMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.guid == this.guid &&
          other.noteTypeId == this.noteTypeId &&
          other.fields == this.fields &&
          other.sortField == this.sortField &&
          other.checksum == this.checksum &&
          other.tags == this.tags &&
          other.mtimeMs == this.mtimeMs);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<int> id;
  final Value<String> guid;
  final Value<int> noteTypeId;
  final Value<String> fields;
  final Value<String> sortField;
  final Value<int> checksum;
  final Value<String> tags;
  final Value<int> mtimeMs;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.guid = const Value.absent(),
    this.noteTypeId = const Value.absent(),
    this.fields = const Value.absent(),
    this.sortField = const Value.absent(),
    this.checksum = const Value.absent(),
    this.tags = const Value.absent(),
    this.mtimeMs = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required String guid,
    required int noteTypeId,
    required String fields,
    required String sortField,
    required int checksum,
    required String tags,
    required int mtimeMs,
  }) : guid = Value(guid),
       noteTypeId = Value(noteTypeId),
       fields = Value(fields),
       sortField = Value(sortField),
       checksum = Value(checksum),
       tags = Value(tags),
       mtimeMs = Value(mtimeMs);
  static Insertable<NoteRow> custom({
    Expression<int>? id,
    Expression<String>? guid,
    Expression<int>? noteTypeId,
    Expression<String>? fields,
    Expression<String>? sortField,
    Expression<int>? checksum,
    Expression<String>? tags,
    Expression<int>? mtimeMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (guid != null) 'guid': guid,
      if (noteTypeId != null) 'note_type_id': noteTypeId,
      if (fields != null) 'fields': fields,
      if (sortField != null) 'sort_field': sortField,
      if (checksum != null) 'checksum': checksum,
      if (tags != null) 'tags': tags,
      if (mtimeMs != null) 'mtime_ms': mtimeMs,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<String>? guid,
    Value<int>? noteTypeId,
    Value<String>? fields,
    Value<String>? sortField,
    Value<int>? checksum,
    Value<String>? tags,
    Value<int>? mtimeMs,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      guid: guid ?? this.guid,
      noteTypeId: noteTypeId ?? this.noteTypeId,
      fields: fields ?? this.fields,
      sortField: sortField ?? this.sortField,
      checksum: checksum ?? this.checksum,
      tags: tags ?? this.tags,
      mtimeMs: mtimeMs ?? this.mtimeMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (noteTypeId.present) {
      map['note_type_id'] = Variable<int>(noteTypeId.value);
    }
    if (fields.present) {
      map['fields'] = Variable<String>(fields.value);
    }
    if (sortField.present) {
      map['sort_field'] = Variable<String>(sortField.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<int>(checksum.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (mtimeMs.present) {
      map['mtime_ms'] = Variable<int>(mtimeMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('guid: $guid, ')
          ..write('noteTypeId: $noteTypeId, ')
          ..write('fields: $fields, ')
          ..write('sortField: $sortField, ')
          ..write('checksum: $checksum, ')
          ..write('tags: $tags, ')
          ..write('mtimeMs: $mtimeMs')
          ..write(')'))
        .toString();
  }
}

class $CardsTable extends Cards with TableInfo<$CardsTable, CardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordMeta = const VerificationMeta('ord');
  @override
  late final GeneratedColumn<int> ord = GeneratedColumn<int>(
    'ord',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queueMeta = const VerificationMeta('queue');
  @override
  late final GeneratedColumn<int> queue = GeneratedColumn<int>(
    'queue',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<int> due = GeneratedColumn<int>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ivlMeta = const VerificationMeta('ivl');
  @override
  late final GeneratedColumn<int> ivl = GeneratedColumn<int>(
    'ivl',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _easeMeta = const VerificationMeta('ease');
  @override
  late final GeneratedColumn<int> ease = GeneratedColumn<int>(
    'ease',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leftMeta = const VerificationMeta('left');
  @override
  late final GeneratedColumn<int> left = GeneratedColumn<int>(
    'left',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flagsMeta = const VerificationMeta('flags');
  @override
  late final GeneratedColumn<int> flags = GeneratedColumn<int>(
    'flags',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mtimeMsMeta = const VerificationMeta(
    'mtimeMs',
  );
  @override
  late final GeneratedColumn<int> mtimeMs = GeneratedColumn<int>(
    'mtime_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    noteId,
    deckId,
    ord,
    type,
    queue,
    due,
    ivl,
    ease,
    reps,
    lapses,
    left,
    flags,
    mtimeMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('ord')) {
      context.handle(
        _ordMeta,
        ord.isAcceptableOrUnknown(data['ord']!, _ordMeta),
      );
    } else if (isInserting) {
      context.missing(_ordMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('queue')) {
      context.handle(
        _queueMeta,
        queue.isAcceptableOrUnknown(data['queue']!, _queueMeta),
      );
    } else if (isInserting) {
      context.missing(_queueMeta);
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    } else if (isInserting) {
      context.missing(_dueMeta);
    }
    if (data.containsKey('ivl')) {
      context.handle(
        _ivlMeta,
        ivl.isAcceptableOrUnknown(data['ivl']!, _ivlMeta),
      );
    } else if (isInserting) {
      context.missing(_ivlMeta);
    }
    if (data.containsKey('ease')) {
      context.handle(
        _easeMeta,
        ease.isAcceptableOrUnknown(data['ease']!, _easeMeta),
      );
    } else if (isInserting) {
      context.missing(_easeMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    } else if (isInserting) {
      context.missing(_lapsesMeta);
    }
    if (data.containsKey('left')) {
      context.handle(
        _leftMeta,
        left.isAcceptableOrUnknown(data['left']!, _leftMeta),
      );
    } else if (isInserting) {
      context.missing(_leftMeta);
    }
    if (data.containsKey('flags')) {
      context.handle(
        _flagsMeta,
        flags.isAcceptableOrUnknown(data['flags']!, _flagsMeta),
      );
    } else if (isInserting) {
      context.missing(_flagsMeta);
    }
    if (data.containsKey('mtime_ms')) {
      context.handle(
        _mtimeMsMeta,
        mtimeMs.isAcceptableOrUnknown(data['mtime_ms']!, _mtimeMsMeta),
      );
    } else if (isInserting) {
      context.missing(_mtimeMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      )!,
      ord: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ord'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      queue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queue'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due'],
      )!,
      ivl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ivl'],
      )!,
      ease: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ease'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      left: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}left'],
      )!,
      flags: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flags'],
      )!,
      mtimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mtime_ms'],
      )!,
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class CardRow extends DataClass implements Insertable<CardRow> {
  final int id;
  final int noteId;
  final int deckId;
  final int ord;
  final int type;
  final int queue;
  final int due;
  final int ivl;
  final int ease;
  final int reps;
  final int lapses;
  final int left;
  final int flags;
  final int mtimeMs;
  const CardRow({
    required this.id,
    required this.noteId,
    required this.deckId,
    required this.ord,
    required this.type,
    required this.queue,
    required this.due,
    required this.ivl,
    required this.ease,
    required this.reps,
    required this.lapses,
    required this.left,
    required this.flags,
    required this.mtimeMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['note_id'] = Variable<int>(noteId);
    map['deck_id'] = Variable<int>(deckId);
    map['ord'] = Variable<int>(ord);
    map['type'] = Variable<int>(type);
    map['queue'] = Variable<int>(queue);
    map['due'] = Variable<int>(due);
    map['ivl'] = Variable<int>(ivl);
    map['ease'] = Variable<int>(ease);
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    map['left'] = Variable<int>(left);
    map['flags'] = Variable<int>(flags);
    map['mtime_ms'] = Variable<int>(mtimeMs);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      noteId: Value(noteId),
      deckId: Value(deckId),
      ord: Value(ord),
      type: Value(type),
      queue: Value(queue),
      due: Value(due),
      ivl: Value(ivl),
      ease: Value(ease),
      reps: Value(reps),
      lapses: Value(lapses),
      left: Value(left),
      flags: Value(flags),
      mtimeMs: Value(mtimeMs),
    );
  }

  factory CardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardRow(
      id: serializer.fromJson<int>(json['id']),
      noteId: serializer.fromJson<int>(json['noteId']),
      deckId: serializer.fromJson<int>(json['deckId']),
      ord: serializer.fromJson<int>(json['ord']),
      type: serializer.fromJson<int>(json['type']),
      queue: serializer.fromJson<int>(json['queue']),
      due: serializer.fromJson<int>(json['due']),
      ivl: serializer.fromJson<int>(json['ivl']),
      ease: serializer.fromJson<int>(json['ease']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      left: serializer.fromJson<int>(json['left']),
      flags: serializer.fromJson<int>(json['flags']),
      mtimeMs: serializer.fromJson<int>(json['mtimeMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'noteId': serializer.toJson<int>(noteId),
      'deckId': serializer.toJson<int>(deckId),
      'ord': serializer.toJson<int>(ord),
      'type': serializer.toJson<int>(type),
      'queue': serializer.toJson<int>(queue),
      'due': serializer.toJson<int>(due),
      'ivl': serializer.toJson<int>(ivl),
      'ease': serializer.toJson<int>(ease),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'left': serializer.toJson<int>(left),
      'flags': serializer.toJson<int>(flags),
      'mtimeMs': serializer.toJson<int>(mtimeMs),
    };
  }

  CardRow copyWith({
    int? id,
    int? noteId,
    int? deckId,
    int? ord,
    int? type,
    int? queue,
    int? due,
    int? ivl,
    int? ease,
    int? reps,
    int? lapses,
    int? left,
    int? flags,
    int? mtimeMs,
  }) => CardRow(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    deckId: deckId ?? this.deckId,
    ord: ord ?? this.ord,
    type: type ?? this.type,
    queue: queue ?? this.queue,
    due: due ?? this.due,
    ivl: ivl ?? this.ivl,
    ease: ease ?? this.ease,
    reps: reps ?? this.reps,
    lapses: lapses ?? this.lapses,
    left: left ?? this.left,
    flags: flags ?? this.flags,
    mtimeMs: mtimeMs ?? this.mtimeMs,
  );
  CardRow copyWithCompanion(CardsCompanion data) {
    return CardRow(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      ord: data.ord.present ? data.ord.value : this.ord,
      type: data.type.present ? data.type.value : this.type,
      queue: data.queue.present ? data.queue.value : this.queue,
      due: data.due.present ? data.due.value : this.due,
      ivl: data.ivl.present ? data.ivl.value : this.ivl,
      ease: data.ease.present ? data.ease.value : this.ease,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      left: data.left.present ? data.left.value : this.left,
      flags: data.flags.present ? data.flags.value : this.flags,
      mtimeMs: data.mtimeMs.present ? data.mtimeMs.value : this.mtimeMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardRow(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('deckId: $deckId, ')
          ..write('ord: $ord, ')
          ..write('type: $type, ')
          ..write('queue: $queue, ')
          ..write('due: $due, ')
          ..write('ivl: $ivl, ')
          ..write('ease: $ease, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('left: $left, ')
          ..write('flags: $flags, ')
          ..write('mtimeMs: $mtimeMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    noteId,
    deckId,
    ord,
    type,
    queue,
    due,
    ivl,
    ease,
    reps,
    lapses,
    left,
    flags,
    mtimeMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardRow &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.deckId == this.deckId &&
          other.ord == this.ord &&
          other.type == this.type &&
          other.queue == this.queue &&
          other.due == this.due &&
          other.ivl == this.ivl &&
          other.ease == this.ease &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.left == this.left &&
          other.flags == this.flags &&
          other.mtimeMs == this.mtimeMs);
}

class CardsCompanion extends UpdateCompanion<CardRow> {
  final Value<int> id;
  final Value<int> noteId;
  final Value<int> deckId;
  final Value<int> ord;
  final Value<int> type;
  final Value<int> queue;
  final Value<int> due;
  final Value<int> ivl;
  final Value<int> ease;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<int> left;
  final Value<int> flags;
  final Value<int> mtimeMs;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.deckId = const Value.absent(),
    this.ord = const Value.absent(),
    this.type = const Value.absent(),
    this.queue = const Value.absent(),
    this.due = const Value.absent(),
    this.ivl = const Value.absent(),
    this.ease = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.left = const Value.absent(),
    this.flags = const Value.absent(),
    this.mtimeMs = const Value.absent(),
  });
  CardsCompanion.insert({
    this.id = const Value.absent(),
    required int noteId,
    required int deckId,
    required int ord,
    required int type,
    required int queue,
    required int due,
    required int ivl,
    required int ease,
    required int reps,
    required int lapses,
    required int left,
    required int flags,
    required int mtimeMs,
  }) : noteId = Value(noteId),
       deckId = Value(deckId),
       ord = Value(ord),
       type = Value(type),
       queue = Value(queue),
       due = Value(due),
       ivl = Value(ivl),
       ease = Value(ease),
       reps = Value(reps),
       lapses = Value(lapses),
       left = Value(left),
       flags = Value(flags),
       mtimeMs = Value(mtimeMs);
  static Insertable<CardRow> custom({
    Expression<int>? id,
    Expression<int>? noteId,
    Expression<int>? deckId,
    Expression<int>? ord,
    Expression<int>? type,
    Expression<int>? queue,
    Expression<int>? due,
    Expression<int>? ivl,
    Expression<int>? ease,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<int>? left,
    Expression<int>? flags,
    Expression<int>? mtimeMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (deckId != null) 'deck_id': deckId,
      if (ord != null) 'ord': ord,
      if (type != null) 'type': type,
      if (queue != null) 'queue': queue,
      if (due != null) 'due': due,
      if (ivl != null) 'ivl': ivl,
      if (ease != null) 'ease': ease,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (left != null) 'left': left,
      if (flags != null) 'flags': flags,
      if (mtimeMs != null) 'mtime_ms': mtimeMs,
    });
  }

  CardsCompanion copyWith({
    Value<int>? id,
    Value<int>? noteId,
    Value<int>? deckId,
    Value<int>? ord,
    Value<int>? type,
    Value<int>? queue,
    Value<int>? due,
    Value<int>? ivl,
    Value<int>? ease,
    Value<int>? reps,
    Value<int>? lapses,
    Value<int>? left,
    Value<int>? flags,
    Value<int>? mtimeMs,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      deckId: deckId ?? this.deckId,
      ord: ord ?? this.ord,
      type: type ?? this.type,
      queue: queue ?? this.queue,
      due: due ?? this.due,
      ivl: ivl ?? this.ivl,
      ease: ease ?? this.ease,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      left: left ?? this.left,
      flags: flags ?? this.flags,
      mtimeMs: mtimeMs ?? this.mtimeMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<int>(noteId.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (ord.present) {
      map['ord'] = Variable<int>(ord.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (queue.present) {
      map['queue'] = Variable<int>(queue.value);
    }
    if (due.present) {
      map['due'] = Variable<int>(due.value);
    }
    if (ivl.present) {
      map['ivl'] = Variable<int>(ivl.value);
    }
    if (ease.present) {
      map['ease'] = Variable<int>(ease.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (left.present) {
      map['left'] = Variable<int>(left.value);
    }
    if (flags.present) {
      map['flags'] = Variable<int>(flags.value);
    }
    if (mtimeMs.present) {
      map['mtime_ms'] = Variable<int>(mtimeMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('deckId: $deckId, ')
          ..write('ord: $ord, ')
          ..write('type: $type, ')
          ..write('queue: $queue, ')
          ..write('due: $due, ')
          ..write('ivl: $ivl, ')
          ..write('ease: $ease, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('left: $left, ')
          ..write('flags: $flags, ')
          ..write('mtimeMs: $mtimeMs')
          ..write(')'))
        .toString();
  }
}

class $RevlogTable extends Revlog with TableInfo<$RevlogTable, RevlogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RevlogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buttonMeta = const VerificationMeta('button');
  @override
  late final GeneratedColumn<int> button = GeneratedColumn<int>(
    'button',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ivlMeta = const VerificationMeta('ivl');
  @override
  late final GeneratedColumn<int> ivl = GeneratedColumn<int>(
    'ivl',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastIvlMeta = const VerificationMeta(
    'lastIvl',
  );
  @override
  late final GeneratedColumn<int> lastIvl = GeneratedColumn<int>(
    'last_ivl',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _factorMeta = const VerificationMeta('factor');
  @override
  late final GeneratedColumn<int> factor = GeneratedColumn<int>(
    'factor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeTakenMsMeta = const VerificationMeta(
    'timeTakenMs',
  );
  @override
  late final GeneratedColumn<int> timeTakenMs = GeneratedColumn<int>(
    'time_taken_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    button,
    ivl,
    lastIvl,
    factor,
    timeTakenMs,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'revlog';
  @override
  VerificationContext validateIntegrity(
    Insertable<RevlogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('button')) {
      context.handle(
        _buttonMeta,
        button.isAcceptableOrUnknown(data['button']!, _buttonMeta),
      );
    } else if (isInserting) {
      context.missing(_buttonMeta);
    }
    if (data.containsKey('ivl')) {
      context.handle(
        _ivlMeta,
        ivl.isAcceptableOrUnknown(data['ivl']!, _ivlMeta),
      );
    } else if (isInserting) {
      context.missing(_ivlMeta);
    }
    if (data.containsKey('last_ivl')) {
      context.handle(
        _lastIvlMeta,
        lastIvl.isAcceptableOrUnknown(data['last_ivl']!, _lastIvlMeta),
      );
    } else if (isInserting) {
      context.missing(_lastIvlMeta);
    }
    if (data.containsKey('factor')) {
      context.handle(
        _factorMeta,
        factor.isAcceptableOrUnknown(data['factor']!, _factorMeta),
      );
    } else if (isInserting) {
      context.missing(_factorMeta);
    }
    if (data.containsKey('time_taken_ms')) {
      context.handle(
        _timeTakenMsMeta,
        timeTakenMs.isAcceptableOrUnknown(
          data['time_taken_ms']!,
          _timeTakenMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeTakenMsMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RevlogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RevlogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      button: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}button'],
      )!,
      ivl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ivl'],
      )!,
      lastIvl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_ivl'],
      )!,
      factor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}factor'],
      )!,
      timeTakenMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_taken_ms'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $RevlogTable createAlias(String alias) {
    return $RevlogTable(attachedDatabase, alias);
  }
}

class RevlogRow extends DataClass implements Insertable<RevlogRow> {
  final int id;
  final int cardId;
  final int button;
  final int ivl;
  final int lastIvl;
  final int factor;
  final int timeTakenMs;
  final int type;
  const RevlogRow({
    required this.id,
    required this.cardId,
    required this.button,
    required this.ivl,
    required this.lastIvl,
    required this.factor,
    required this.timeTakenMs,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['button'] = Variable<int>(button);
    map['ivl'] = Variable<int>(ivl);
    map['last_ivl'] = Variable<int>(lastIvl);
    map['factor'] = Variable<int>(factor);
    map['time_taken_ms'] = Variable<int>(timeTakenMs);
    map['type'] = Variable<int>(type);
    return map;
  }

  RevlogCompanion toCompanion(bool nullToAbsent) {
    return RevlogCompanion(
      id: Value(id),
      cardId: Value(cardId),
      button: Value(button),
      ivl: Value(ivl),
      lastIvl: Value(lastIvl),
      factor: Value(factor),
      timeTakenMs: Value(timeTakenMs),
      type: Value(type),
    );
  }

  factory RevlogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RevlogRow(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      button: serializer.fromJson<int>(json['button']),
      ivl: serializer.fromJson<int>(json['ivl']),
      lastIvl: serializer.fromJson<int>(json['lastIvl']),
      factor: serializer.fromJson<int>(json['factor']),
      timeTakenMs: serializer.fromJson<int>(json['timeTakenMs']),
      type: serializer.fromJson<int>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'button': serializer.toJson<int>(button),
      'ivl': serializer.toJson<int>(ivl),
      'lastIvl': serializer.toJson<int>(lastIvl),
      'factor': serializer.toJson<int>(factor),
      'timeTakenMs': serializer.toJson<int>(timeTakenMs),
      'type': serializer.toJson<int>(type),
    };
  }

  RevlogRow copyWith({
    int? id,
    int? cardId,
    int? button,
    int? ivl,
    int? lastIvl,
    int? factor,
    int? timeTakenMs,
    int? type,
  }) => RevlogRow(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    button: button ?? this.button,
    ivl: ivl ?? this.ivl,
    lastIvl: lastIvl ?? this.lastIvl,
    factor: factor ?? this.factor,
    timeTakenMs: timeTakenMs ?? this.timeTakenMs,
    type: type ?? this.type,
  );
  RevlogRow copyWithCompanion(RevlogCompanion data) {
    return RevlogRow(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      button: data.button.present ? data.button.value : this.button,
      ivl: data.ivl.present ? data.ivl.value : this.ivl,
      lastIvl: data.lastIvl.present ? data.lastIvl.value : this.lastIvl,
      factor: data.factor.present ? data.factor.value : this.factor,
      timeTakenMs: data.timeTakenMs.present
          ? data.timeTakenMs.value
          : this.timeTakenMs,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RevlogRow(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('button: $button, ')
          ..write('ivl: $ivl, ')
          ..write('lastIvl: $lastIvl, ')
          ..write('factor: $factor, ')
          ..write('timeTakenMs: $timeTakenMs, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cardId, button, ivl, lastIvl, factor, timeTakenMs, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RevlogRow &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.button == this.button &&
          other.ivl == this.ivl &&
          other.lastIvl == this.lastIvl &&
          other.factor == this.factor &&
          other.timeTakenMs == this.timeTakenMs &&
          other.type == this.type);
}

class RevlogCompanion extends UpdateCompanion<RevlogRow> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<int> button;
  final Value<int> ivl;
  final Value<int> lastIvl;
  final Value<int> factor;
  final Value<int> timeTakenMs;
  final Value<int> type;
  const RevlogCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.button = const Value.absent(),
    this.ivl = const Value.absent(),
    this.lastIvl = const Value.absent(),
    this.factor = const Value.absent(),
    this.timeTakenMs = const Value.absent(),
    this.type = const Value.absent(),
  });
  RevlogCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required int button,
    required int ivl,
    required int lastIvl,
    required int factor,
    required int timeTakenMs,
    required int type,
  }) : cardId = Value(cardId),
       button = Value(button),
       ivl = Value(ivl),
       lastIvl = Value(lastIvl),
       factor = Value(factor),
       timeTakenMs = Value(timeTakenMs),
       type = Value(type);
  static Insertable<RevlogRow> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<int>? button,
    Expression<int>? ivl,
    Expression<int>? lastIvl,
    Expression<int>? factor,
    Expression<int>? timeTakenMs,
    Expression<int>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (button != null) 'button': button,
      if (ivl != null) 'ivl': ivl,
      if (lastIvl != null) 'last_ivl': lastIvl,
      if (factor != null) 'factor': factor,
      if (timeTakenMs != null) 'time_taken_ms': timeTakenMs,
      if (type != null) 'type': type,
    });
  }

  RevlogCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<int>? button,
    Value<int>? ivl,
    Value<int>? lastIvl,
    Value<int>? factor,
    Value<int>? timeTakenMs,
    Value<int>? type,
  }) {
    return RevlogCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      button: button ?? this.button,
      ivl: ivl ?? this.ivl,
      lastIvl: lastIvl ?? this.lastIvl,
      factor: factor ?? this.factor,
      timeTakenMs: timeTakenMs ?? this.timeTakenMs,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (button.present) {
      map['button'] = Variable<int>(button.value);
    }
    if (ivl.present) {
      map['ivl'] = Variable<int>(ivl.value);
    }
    if (lastIvl.present) {
      map['last_ivl'] = Variable<int>(lastIvl.value);
    }
    if (factor.present) {
      map['factor'] = Variable<int>(factor.value);
    }
    if (timeTakenMs.present) {
      map['time_taken_ms'] = Variable<int>(timeTakenMs.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RevlogCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('button: $button, ')
          ..write('ivl: $ivl, ')
          ..write('lastIvl: $lastIvl, ')
          ..write('factor: $factor, ')
          ..write('timeTakenMs: $timeTakenMs, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $DeckDayCountsTable extends DeckDayCounts
    with TableInfo<$DeckDayCountsTable, DayCountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeckDayCountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newDoneMeta = const VerificationMeta(
    'newDone',
  );
  @override
  late final GeneratedColumn<int> newDone = GeneratedColumn<int>(
    'new_done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewDoneMeta = const VerificationMeta(
    'reviewDone',
  );
  @override
  late final GeneratedColumn<int> reviewDone = GeneratedColumn<int>(
    'review_done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [deckId, day, newDone, reviewDone];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck_day_counts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayCountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('new_done')) {
      context.handle(
        _newDoneMeta,
        newDone.isAcceptableOrUnknown(data['new_done']!, _newDoneMeta),
      );
    } else if (isInserting) {
      context.missing(_newDoneMeta);
    }
    if (data.containsKey('review_done')) {
      context.handle(
        _reviewDoneMeta,
        reviewDone.isAcceptableOrUnknown(data['review_done']!, _reviewDoneMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewDoneMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deckId, day};
  @override
  DayCountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayCountRow(
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      )!,
      newDone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_done'],
      )!,
      reviewDone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_done'],
      )!,
    );
  }

  @override
  $DeckDayCountsTable createAlias(String alias) {
    return $DeckDayCountsTable(attachedDatabase, alias);
  }
}

class DayCountRow extends DataClass implements Insertable<DayCountRow> {
  final int deckId;
  final int day;
  final int newDone;
  final int reviewDone;
  const DayCountRow({
    required this.deckId,
    required this.day,
    required this.newDone,
    required this.reviewDone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['deck_id'] = Variable<int>(deckId);
    map['day'] = Variable<int>(day);
    map['new_done'] = Variable<int>(newDone);
    map['review_done'] = Variable<int>(reviewDone);
    return map;
  }

  DeckDayCountsCompanion toCompanion(bool nullToAbsent) {
    return DeckDayCountsCompanion(
      deckId: Value(deckId),
      day: Value(day),
      newDone: Value(newDone),
      reviewDone: Value(reviewDone),
    );
  }

  factory DayCountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayCountRow(
      deckId: serializer.fromJson<int>(json['deckId']),
      day: serializer.fromJson<int>(json['day']),
      newDone: serializer.fromJson<int>(json['newDone']),
      reviewDone: serializer.fromJson<int>(json['reviewDone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deckId': serializer.toJson<int>(deckId),
      'day': serializer.toJson<int>(day),
      'newDone': serializer.toJson<int>(newDone),
      'reviewDone': serializer.toJson<int>(reviewDone),
    };
  }

  DayCountRow copyWith({
    int? deckId,
    int? day,
    int? newDone,
    int? reviewDone,
  }) => DayCountRow(
    deckId: deckId ?? this.deckId,
    day: day ?? this.day,
    newDone: newDone ?? this.newDone,
    reviewDone: reviewDone ?? this.reviewDone,
  );
  DayCountRow copyWithCompanion(DeckDayCountsCompanion data) {
    return DayCountRow(
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      day: data.day.present ? data.day.value : this.day,
      newDone: data.newDone.present ? data.newDone.value : this.newDone,
      reviewDone: data.reviewDone.present
          ? data.reviewDone.value
          : this.reviewDone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayCountRow(')
          ..write('deckId: $deckId, ')
          ..write('day: $day, ')
          ..write('newDone: $newDone, ')
          ..write('reviewDone: $reviewDone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deckId, day, newDone, reviewDone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayCountRow &&
          other.deckId == this.deckId &&
          other.day == this.day &&
          other.newDone == this.newDone &&
          other.reviewDone == this.reviewDone);
}

class DeckDayCountsCompanion extends UpdateCompanion<DayCountRow> {
  final Value<int> deckId;
  final Value<int> day;
  final Value<int> newDone;
  final Value<int> reviewDone;
  final Value<int> rowid;
  const DeckDayCountsCompanion({
    this.deckId = const Value.absent(),
    this.day = const Value.absent(),
    this.newDone = const Value.absent(),
    this.reviewDone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeckDayCountsCompanion.insert({
    required int deckId,
    required int day,
    required int newDone,
    required int reviewDone,
    this.rowid = const Value.absent(),
  }) : deckId = Value(deckId),
       day = Value(day),
       newDone = Value(newDone),
       reviewDone = Value(reviewDone);
  static Insertable<DayCountRow> custom({
    Expression<int>? deckId,
    Expression<int>? day,
    Expression<int>? newDone,
    Expression<int>? reviewDone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deckId != null) 'deck_id': deckId,
      if (day != null) 'day': day,
      if (newDone != null) 'new_done': newDone,
      if (reviewDone != null) 'review_done': reviewDone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeckDayCountsCompanion copyWith({
    Value<int>? deckId,
    Value<int>? day,
    Value<int>? newDone,
    Value<int>? reviewDone,
    Value<int>? rowid,
  }) {
    return DeckDayCountsCompanion(
      deckId: deckId ?? this.deckId,
      day: day ?? this.day,
      newDone: newDone ?? this.newDone,
      reviewDone: reviewDone ?? this.reviewDone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (newDone.present) {
      map['new_done'] = Variable<int>(newDone.value);
    }
    if (reviewDone.present) {
      map['review_done'] = Variable<int>(reviewDone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckDayCountsCompanion(')
          ..write('deckId: $deckId, ')
          ..write('day: $day, ')
          ..write('newDone: $newDone, ')
          ..write('reviewDone: $reviewDone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UgkDatabase extends GeneratedDatabase {
  _$UgkDatabase(QueryExecutor e) : super(e);
  $UgkDatabaseManager get managers => $UgkDatabaseManager(this);
  late final $CollectionMetaTable collectionMeta = $CollectionMetaTable(this);
  late final $DeckConfigsTable deckConfigs = $DeckConfigsTable(this);
  late final $DecksTable decks = $DecksTable(this);
  late final $NoteTypesTable noteTypes = $NoteTypesTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $RevlogTable revlog = $RevlogTable(this);
  late final $DeckDayCountsTable deckDayCounts = $DeckDayCountsTable(this);
  late final Index idxNotesChecksum = Index(
    'idx_notes_checksum',
    'CREATE INDEX idx_notes_checksum ON notes (checksum)',
  );
  late final Index idxCardsDeckQueueDue = Index(
    'idx_cards_deck_queue_due',
    'CREATE INDEX idx_cards_deck_queue_due ON cards (deck_id, queue, due)',
  );
  late final Index idxCardsNote = Index(
    'idx_cards_note',
    'CREATE INDEX idx_cards_note ON cards (note_id)',
  );
  late final Index idxRevlogCard = Index(
    'idx_revlog_card',
    'CREATE INDEX idx_revlog_card ON revlog (card_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    collectionMeta,
    deckConfigs,
    decks,
    noteTypes,
    notes,
    cards,
    revlog,
    deckDayCounts,
    idxNotesChecksum,
    idxCardsDeckQueueDue,
    idxCardsNote,
    idxRevlogCard,
  ];
}

typedef $$CollectionMetaTableCreateCompanionBuilder =
    CollectionMetaCompanion Function({
      Value<int> id,
      required int createdMs,
      required int nextNewPos,
      required int lastUnburyDay,
    });
typedef $$CollectionMetaTableUpdateCompanionBuilder =
    CollectionMetaCompanion Function({
      Value<int> id,
      Value<int> createdMs,
      Value<int> nextNewPos,
      Value<int> lastUnburyDay,
    });

class $$CollectionMetaTableFilterComposer
    extends Composer<_$UgkDatabase, $CollectionMetaTable> {
  $$CollectionMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdMs => $composableBuilder(
    column: $table.createdMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextNewPos => $composableBuilder(
    column: $table.nextNewPos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUnburyDay => $composableBuilder(
    column: $table.lastUnburyDay,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionMetaTableOrderingComposer
    extends Composer<_$UgkDatabase, $CollectionMetaTable> {
  $$CollectionMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdMs => $composableBuilder(
    column: $table.createdMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextNewPos => $composableBuilder(
    column: $table.nextNewPos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUnburyDay => $composableBuilder(
    column: $table.lastUnburyDay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionMetaTableAnnotationComposer
    extends Composer<_$UgkDatabase, $CollectionMetaTable> {
  $$CollectionMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdMs =>
      $composableBuilder(column: $table.createdMs, builder: (column) => column);

  GeneratedColumn<int> get nextNewPos => $composableBuilder(
    column: $table.nextNewPos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastUnburyDay => $composableBuilder(
    column: $table.lastUnburyDay,
    builder: (column) => column,
  );
}

class $$CollectionMetaTableTableManager
    extends
        RootTableManager<
          _$UgkDatabase,
          $CollectionMetaTable,
          MetaRow,
          $$CollectionMetaTableFilterComposer,
          $$CollectionMetaTableOrderingComposer,
          $$CollectionMetaTableAnnotationComposer,
          $$CollectionMetaTableCreateCompanionBuilder,
          $$CollectionMetaTableUpdateCompanionBuilder,
          (
            MetaRow,
            BaseReferences<_$UgkDatabase, $CollectionMetaTable, MetaRow>,
          ),
          MetaRow,
          PrefetchHooks Function()
        > {
  $$CollectionMetaTableTableManager(
    _$UgkDatabase db,
    $CollectionMetaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> createdMs = const Value.absent(),
                Value<int> nextNewPos = const Value.absent(),
                Value<int> lastUnburyDay = const Value.absent(),
              }) => CollectionMetaCompanion(
                id: id,
                createdMs: createdMs,
                nextNewPos: nextNewPos,
                lastUnburyDay: lastUnburyDay,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdMs,
                required int nextNewPos,
                required int lastUnburyDay,
              }) => CollectionMetaCompanion.insert(
                id: id,
                createdMs: createdMs,
                nextNewPos: nextNewPos,
                lastUnburyDay: lastUnburyDay,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionMetaTable, MetaRow>(table),
                  BaseReferences<_$UgkDatabase, $CollectionMetaTable, MetaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$UgkDatabase,
      $CollectionMetaTable,
      MetaRow,
      $$CollectionMetaTableFilterComposer,
      $$CollectionMetaTableOrderingComposer,
      $$CollectionMetaTableAnnotationComposer,
      $$CollectionMetaTableCreateCompanionBuilder,
      $$CollectionMetaTableUpdateCompanionBuilder,
      (MetaRow, BaseReferences<_$UgkDatabase, $CollectionMetaTable, MetaRow>),
      MetaRow,
      PrefetchHooks Function()
    >;
typedef $$DeckConfigsTableCreateCompanionBuilder =
    DeckConfigsCompanion Function({
      Value<int> id,
      required String name,
      required String configJson,
    });
typedef $$DeckConfigsTableUpdateCompanionBuilder =
    DeckConfigsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> configJson,
    });

class $$DeckConfigsTableFilterComposer
    extends Composer<_$UgkDatabase, $DeckConfigsTable> {
  $$DeckConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeckConfigsTableOrderingComposer
    extends Composer<_$UgkDatabase, $DeckConfigsTable> {
  $$DeckConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeckConfigsTableAnnotationComposer
    extends Composer<_$UgkDatabase, $DeckConfigsTable> {
  $$DeckConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );
}

class $$DeckConfigsTableTableManager
    extends
        RootTableManager<
          _$UgkDatabase,
          $DeckConfigsTable,
          DeckConfigRow,
          $$DeckConfigsTableFilterComposer,
          $$DeckConfigsTableOrderingComposer,
          $$DeckConfigsTableAnnotationComposer,
          $$DeckConfigsTableCreateCompanionBuilder,
          $$DeckConfigsTableUpdateCompanionBuilder,
          (
            DeckConfigRow,
            BaseReferences<_$UgkDatabase, $DeckConfigsTable, DeckConfigRow>,
          ),
          DeckConfigRow,
          PrefetchHooks Function()
        > {
  $$DeckConfigsTableTableManager(_$UgkDatabase db, $DeckConfigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeckConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeckConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeckConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> configJson = const Value.absent(),
              }) => DeckConfigsCompanion(
                id: id,
                name: name,
                configJson: configJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String configJson,
              }) => DeckConfigsCompanion.insert(
                id: id,
                name: name,
                configJson: configJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeckConfigsTable, DeckConfigRow>(table),
                  BaseReferences<
                    _$UgkDatabase,
                    $DeckConfigsTable,
                    DeckConfigRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeckConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$UgkDatabase,
      $DeckConfigsTable,
      DeckConfigRow,
      $$DeckConfigsTableFilterComposer,
      $$DeckConfigsTableOrderingComposer,
      $$DeckConfigsTableAnnotationComposer,
      $$DeckConfigsTableCreateCompanionBuilder,
      $$DeckConfigsTableUpdateCompanionBuilder,
      (
        DeckConfigRow,
        BaseReferences<_$UgkDatabase, $DeckConfigsTable, DeckConfigRow>,
      ),
      DeckConfigRow,
      PrefetchHooks Function()
    >;
typedef $$DecksTableCreateCompanionBuilder =
    DecksCompanion Function({
      Value<int> id,
      required String name,
      required int configId,
    });
typedef $$DecksTableUpdateCompanionBuilder =
    DecksCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> configId,
    });

class $$DecksTableFilterComposer extends Composer<_$UgkDatabase, $DecksTable> {
  $$DecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get configId => $composableBuilder(
    column: $table.configId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DecksTableOrderingComposer
    extends Composer<_$UgkDatabase, $DecksTable> {
  $$DecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get configId => $composableBuilder(
    column: $table.configId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DecksTableAnnotationComposer
    extends Composer<_$UgkDatabase, $DecksTable> {
  $$DecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get configId =>
      $composableBuilder(column: $table.configId, builder: (column) => column);
}

class $$DecksTableTableManager
    extends
        RootTableManager<
          _$UgkDatabase,
          $DecksTable,
          DeckRow,
          $$DecksTableFilterComposer,
          $$DecksTableOrderingComposer,
          $$DecksTableAnnotationComposer,
          $$DecksTableCreateCompanionBuilder,
          $$DecksTableUpdateCompanionBuilder,
          (DeckRow, BaseReferences<_$UgkDatabase, $DecksTable, DeckRow>),
          DeckRow,
          PrefetchHooks Function()
        > {
  $$DecksTableTableManager(_$UgkDatabase db, $DecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> configId = const Value.absent(),
              }) => DecksCompanion(id: id, name: name, configId: configId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int configId,
              }) =>
                  DecksCompanion.insert(id: id, name: name, configId: configId),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DecksTable, DeckRow>(table),
                  BaseReferences<_$UgkDatabase, $DecksTable, DeckRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DecksTableProcessedTableManager =
    ProcessedTableManager<
      _$UgkDatabase,
      $DecksTable,
      DeckRow,
      $$DecksTableFilterComposer,
      $$DecksTableOrderingComposer,
      $$DecksTableAnnotationComposer,
      $$DecksTableCreateCompanionBuilder,
      $$DecksTableUpdateCompanionBuilder,
      (DeckRow, BaseReferences<_$UgkDatabase, $DecksTable, DeckRow>),
      DeckRow,
      PrefetchHooks Function()
    >;
typedef $$NoteTypesTableCreateCompanionBuilder =
    NoteTypesCompanion Function({
      Value<int> id,
      required String name,
      required int kind,
      required String fieldsJson,
      required String templatesJson,
      required String css,
      required int sortFieldIdx,
      required int mtimeMs,
    });
typedef $$NoteTypesTableUpdateCompanionBuilder =
    NoteTypesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> kind,
      Value<String> fieldsJson,
      Value<String> templatesJson,
      Value<String> css,
      Value<int> sortFieldIdx,
      Value<int> mtimeMs,
    });

class $$NoteTypesTableFilterComposer
    extends Composer<_$UgkDatabase, $NoteTypesTable> {
  $$NoteTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templatesJson => $composableBuilder(
    column: $table.templatesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get css => $composableBuilder(
    column: $table.css,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortFieldIdx => $composableBuilder(
    column: $table.sortFieldIdx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mtimeMs => $composableBuilder(
    column: $table.mtimeMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NoteTypesTableOrderingComposer
    extends Composer<_$UgkDatabase, $NoteTypesTable> {
  $$NoteTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templatesJson => $composableBuilder(
    column: $table.templatesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get css => $composableBuilder(
    column: $table.css,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortFieldIdx => $composableBuilder(
    column: $table.sortFieldIdx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mtimeMs => $composableBuilder(
    column: $table.mtimeMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NoteTypesTableAnnotationComposer
    extends Composer<_$UgkDatabase, $NoteTypesTable> {
  $$NoteTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templatesJson => $composableBuilder(
    column: $table.templatesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get css =>
      $composableBuilder(column: $table.css, builder: (column) => column);

  GeneratedColumn<int> get sortFieldIdx => $composableBuilder(
    column: $table.sortFieldIdx,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mtimeMs =>
      $composableBuilder(column: $table.mtimeMs, builder: (column) => column);
}

class $$NoteTypesTableTableManager
    extends
        RootTableManager<
          _$UgkDatabase,
          $NoteTypesTable,
          NoteTypeRow,
          $$NoteTypesTableFilterComposer,
          $$NoteTypesTableOrderingComposer,
          $$NoteTypesTableAnnotationComposer,
          $$NoteTypesTableCreateCompanionBuilder,
          $$NoteTypesTableUpdateCompanionBuilder,
          (
            NoteTypeRow,
            BaseReferences<_$UgkDatabase, $NoteTypesTable, NoteTypeRow>,
          ),
          NoteTypeRow,
          PrefetchHooks Function()
        > {
  $$NoteTypesTableTableManager(_$UgkDatabase db, $NoteTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> kind = const Value.absent(),
                Value<String> fieldsJson = const Value.absent(),
                Value<String> templatesJson = const Value.absent(),
                Value<String> css = const Value.absent(),
                Value<int> sortFieldIdx = const Value.absent(),
                Value<int> mtimeMs = const Value.absent(),
              }) => NoteTypesCompanion(
                id: id,
                name: name,
                kind: kind,
                fieldsJson: fieldsJson,
                templatesJson: templatesJson,
                css: css,
                sortFieldIdx: sortFieldIdx,
                mtimeMs: mtimeMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int kind,
                required String fieldsJson,
                required String templatesJson,
                required String css,
                required int sortFieldIdx,
                required int mtimeMs,
              }) => NoteTypesCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                fieldsJson: fieldsJson,
                templatesJson: templatesJson,
                css: css,
                sortFieldIdx: sortFieldIdx,
                mtimeMs: mtimeMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteTypesTable, NoteTypeRow>(table),
                  BaseReferences<_$UgkDatabase, $NoteTypesTable, NoteTypeRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoteTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$UgkDatabase,
      $NoteTypesTable,
      NoteTypeRow,
      $$NoteTypesTableFilterComposer,
      $$NoteTypesTableOrderingComposer,
      $$NoteTypesTableAnnotationComposer,
      $$NoteTypesTableCreateCompanionBuilder,
      $$NoteTypesTableUpdateCompanionBuilder,
      (
        NoteTypeRow,
        BaseReferences<_$UgkDatabase, $NoteTypesTable, NoteTypeRow>,
      ),
      NoteTypeRow,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      required String guid,
      required int noteTypeId,
      required String fields,
      required String sortField,
      required int checksum,
      required String tags,
      required int mtimeMs,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      Value<String> guid,
      Value<int> noteTypeId,
      Value<String> fields,
      Value<String> sortField,
      Value<int> checksum,
      Value<String> tags,
      Value<int> mtimeMs,
    });

class $$NotesTableFilterComposer extends Composer<_$UgkDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get noteTypeId => $composableBuilder(
    column: $table.noteTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortField => $composableBuilder(
    column: $table.sortField,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mtimeMs => $composableBuilder(
    column: $table.mtimeMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotesTableOrderingComposer
    extends Composer<_$UgkDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get noteTypeId => $composableBuilder(
    column: $table.noteTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortField => $composableBuilder(
    column: $table.sortField,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mtimeMs => $composableBuilder(
    column: $table.mtimeMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$UgkDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<int> get noteTypeId => $composableBuilder(
    column: $table.noteTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => column);

  GeneratedColumn<String> get sortField =>
      $composableBuilder(column: $table.sortField, builder: (column) => column);

  GeneratedColumn<int> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get mtimeMs =>
      $composableBuilder(column: $table.mtimeMs, builder: (column) => column);
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$UgkDatabase,
          $NotesTable,
          NoteRow,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteRow, BaseReferences<_$UgkDatabase, $NotesTable, NoteRow>),
          NoteRow,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$UgkDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<int> noteTypeId = const Value.absent(),
                Value<String> fields = const Value.absent(),
                Value<String> sortField = const Value.absent(),
                Value<int> checksum = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int> mtimeMs = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                guid: guid,
                noteTypeId: noteTypeId,
                fields: fields,
                sortField: sortField,
                checksum: checksum,
                tags: tags,
                mtimeMs: mtimeMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String guid,
                required int noteTypeId,
                required String fields,
                required String sortField,
                required int checksum,
                required String tags,
                required int mtimeMs,
              }) => NotesCompanion.insert(
                id: id,
                guid: guid,
                noteTypeId: noteTypeId,
                fields: fields,
                sortField: sortField,
                checksum: checksum,
                tags: tags,
                mtimeMs: mtimeMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, NoteRow>(table),
                  BaseReferences<_$UgkDatabase, $NotesTable, NoteRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$UgkDatabase,
      $NotesTable,
      NoteRow,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteRow, BaseReferences<_$UgkDatabase, $NotesTable, NoteRow>),
      NoteRow,
      PrefetchHooks Function()
    >;
typedef $$CardsTableCreateCompanionBuilder =
    CardsCompanion Function({
      Value<int> id,
      required int noteId,
      required int deckId,
      required int ord,
      required int type,
      required int queue,
      required int due,
      required int ivl,
      required int ease,
      required int reps,
      required int lapses,
      required int left,
      required int flags,
      required int mtimeMs,
    });
typedef $$CardsTableUpdateCompanionBuilder =
    CardsCompanion Function({
      Value<int> id,
      Value<int> noteId,
      Value<int> deckId,
      Value<int> ord,
      Value<int> type,
      Value<int> queue,
      Value<int> due,
      Value<int> ivl,
      Value<int> ease,
      Value<int> reps,
      Value<int> lapses,
      Value<int> left,
      Value<int> flags,
      Value<int> mtimeMs,
    });

class $$CardsTableFilterComposer extends Composer<_$UgkDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ord => $composableBuilder(
    column: $table.ord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get queue => $composableBuilder(
    column: $table.queue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ivl => $composableBuilder(
    column: $table.ivl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ease => $composableBuilder(
    column: $table.ease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get left => $composableBuilder(
    column: $table.left,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flags => $composableBuilder(
    column: $table.flags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mtimeMs => $composableBuilder(
    column: $table.mtimeMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardsTableOrderingComposer
    extends Composer<_$UgkDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ord => $composableBuilder(
    column: $table.ord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get queue => $composableBuilder(
    column: $table.queue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ivl => $composableBuilder(
    column: $table.ivl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ease => $composableBuilder(
    column: $table.ease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get left => $composableBuilder(
    column: $table.left,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flags => $composableBuilder(
    column: $table.flags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mtimeMs => $composableBuilder(
    column: $table.mtimeMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardsTableAnnotationComposer
    extends Composer<_$UgkDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<int> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<int> get ord =>
      $composableBuilder(column: $table.ord, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get queue =>
      $composableBuilder(column: $table.queue, builder: (column) => column);

  GeneratedColumn<int> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<int> get ivl =>
      $composableBuilder(column: $table.ivl, builder: (column) => column);

  GeneratedColumn<int> get ease =>
      $composableBuilder(column: $table.ease, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<int> get left =>
      $composableBuilder(column: $table.left, builder: (column) => column);

  GeneratedColumn<int> get flags =>
      $composableBuilder(column: $table.flags, builder: (column) => column);

  GeneratedColumn<int> get mtimeMs =>
      $composableBuilder(column: $table.mtimeMs, builder: (column) => column);
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$UgkDatabase,
          $CardsTable,
          CardRow,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (CardRow, BaseReferences<_$UgkDatabase, $CardsTable, CardRow>),
          CardRow,
          PrefetchHooks Function()
        > {
  $$CardsTableTableManager(_$UgkDatabase db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> noteId = const Value.absent(),
                Value<int> deckId = const Value.absent(),
                Value<int> ord = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> queue = const Value.absent(),
                Value<int> due = const Value.absent(),
                Value<int> ivl = const Value.absent(),
                Value<int> ease = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int> left = const Value.absent(),
                Value<int> flags = const Value.absent(),
                Value<int> mtimeMs = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                noteId: noteId,
                deckId: deckId,
                ord: ord,
                type: type,
                queue: queue,
                due: due,
                ivl: ivl,
                ease: ease,
                reps: reps,
                lapses: lapses,
                left: left,
                flags: flags,
                mtimeMs: mtimeMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int noteId,
                required int deckId,
                required int ord,
                required int type,
                required int queue,
                required int due,
                required int ivl,
                required int ease,
                required int reps,
                required int lapses,
                required int left,
                required int flags,
                required int mtimeMs,
              }) => CardsCompanion.insert(
                id: id,
                noteId: noteId,
                deckId: deckId,
                ord: ord,
                type: type,
                queue: queue,
                due: due,
                ivl: ivl,
                ease: ease,
                reps: reps,
                lapses: lapses,
                left: left,
                flags: flags,
                mtimeMs: mtimeMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardsTable, CardRow>(table),
                  BaseReferences<_$UgkDatabase, $CardsTable, CardRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$UgkDatabase,
      $CardsTable,
      CardRow,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (CardRow, BaseReferences<_$UgkDatabase, $CardsTable, CardRow>),
      CardRow,
      PrefetchHooks Function()
    >;
typedef $$RevlogTableCreateCompanionBuilder =
    RevlogCompanion Function({
      Value<int> id,
      required int cardId,
      required int button,
      required int ivl,
      required int lastIvl,
      required int factor,
      required int timeTakenMs,
      required int type,
    });
typedef $$RevlogTableUpdateCompanionBuilder =
    RevlogCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<int> button,
      Value<int> ivl,
      Value<int> lastIvl,
      Value<int> factor,
      Value<int> timeTakenMs,
      Value<int> type,
    });

class $$RevlogTableFilterComposer
    extends Composer<_$UgkDatabase, $RevlogTable> {
  $$RevlogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get button => $composableBuilder(
    column: $table.button,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ivl => $composableBuilder(
    column: $table.ivl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastIvl => $composableBuilder(
    column: $table.lastIvl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get factor => $composableBuilder(
    column: $table.factor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeTakenMs => $composableBuilder(
    column: $table.timeTakenMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RevlogTableOrderingComposer
    extends Composer<_$UgkDatabase, $RevlogTable> {
  $$RevlogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get button => $composableBuilder(
    column: $table.button,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ivl => $composableBuilder(
    column: $table.ivl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastIvl => $composableBuilder(
    column: $table.lastIvl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get factor => $composableBuilder(
    column: $table.factor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeTakenMs => $composableBuilder(
    column: $table.timeTakenMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RevlogTableAnnotationComposer
    extends Composer<_$UgkDatabase, $RevlogTable> {
  $$RevlogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<int> get button =>
      $composableBuilder(column: $table.button, builder: (column) => column);

  GeneratedColumn<int> get ivl =>
      $composableBuilder(column: $table.ivl, builder: (column) => column);

  GeneratedColumn<int> get lastIvl =>
      $composableBuilder(column: $table.lastIvl, builder: (column) => column);

  GeneratedColumn<int> get factor =>
      $composableBuilder(column: $table.factor, builder: (column) => column);

  GeneratedColumn<int> get timeTakenMs => $composableBuilder(
    column: $table.timeTakenMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$RevlogTableTableManager
    extends
        RootTableManager<
          _$UgkDatabase,
          $RevlogTable,
          RevlogRow,
          $$RevlogTableFilterComposer,
          $$RevlogTableOrderingComposer,
          $$RevlogTableAnnotationComposer,
          $$RevlogTableCreateCompanionBuilder,
          $$RevlogTableUpdateCompanionBuilder,
          (RevlogRow, BaseReferences<_$UgkDatabase, $RevlogTable, RevlogRow>),
          RevlogRow,
          PrefetchHooks Function()
        > {
  $$RevlogTableTableManager(_$UgkDatabase db, $RevlogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RevlogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RevlogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RevlogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<int> button = const Value.absent(),
                Value<int> ivl = const Value.absent(),
                Value<int> lastIvl = const Value.absent(),
                Value<int> factor = const Value.absent(),
                Value<int> timeTakenMs = const Value.absent(),
                Value<int> type = const Value.absent(),
              }) => RevlogCompanion(
                id: id,
                cardId: cardId,
                button: button,
                ivl: ivl,
                lastIvl: lastIvl,
                factor: factor,
                timeTakenMs: timeTakenMs,
                type: type,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required int button,
                required int ivl,
                required int lastIvl,
                required int factor,
                required int timeTakenMs,
                required int type,
              }) => RevlogCompanion.insert(
                id: id,
                cardId: cardId,
                button: button,
                ivl: ivl,
                lastIvl: lastIvl,
                factor: factor,
                timeTakenMs: timeTakenMs,
                type: type,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RevlogTable, RevlogRow>(table),
                  BaseReferences<_$UgkDatabase, $RevlogTable, RevlogRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RevlogTableProcessedTableManager =
    ProcessedTableManager<
      _$UgkDatabase,
      $RevlogTable,
      RevlogRow,
      $$RevlogTableFilterComposer,
      $$RevlogTableOrderingComposer,
      $$RevlogTableAnnotationComposer,
      $$RevlogTableCreateCompanionBuilder,
      $$RevlogTableUpdateCompanionBuilder,
      (RevlogRow, BaseReferences<_$UgkDatabase, $RevlogTable, RevlogRow>),
      RevlogRow,
      PrefetchHooks Function()
    >;
typedef $$DeckDayCountsTableCreateCompanionBuilder =
    DeckDayCountsCompanion Function({
      required int deckId,
      required int day,
      required int newDone,
      required int reviewDone,
      Value<int> rowid,
    });
typedef $$DeckDayCountsTableUpdateCompanionBuilder =
    DeckDayCountsCompanion Function({
      Value<int> deckId,
      Value<int> day,
      Value<int> newDone,
      Value<int> reviewDone,
      Value<int> rowid,
    });

class $$DeckDayCountsTableFilterComposer
    extends Composer<_$UgkDatabase, $DeckDayCountsTable> {
  $$DeckDayCountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newDone => $composableBuilder(
    column: $table.newDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewDone => $composableBuilder(
    column: $table.reviewDone,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeckDayCountsTableOrderingComposer
    extends Composer<_$UgkDatabase, $DeckDayCountsTable> {
  $$DeckDayCountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newDone => $composableBuilder(
    column: $table.newDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewDone => $composableBuilder(
    column: $table.reviewDone,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeckDayCountsTableAnnotationComposer
    extends Composer<_$UgkDatabase, $DeckDayCountsTable> {
  $$DeckDayCountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get newDone =>
      $composableBuilder(column: $table.newDone, builder: (column) => column);

  GeneratedColumn<int> get reviewDone => $composableBuilder(
    column: $table.reviewDone,
    builder: (column) => column,
  );
}

class $$DeckDayCountsTableTableManager
    extends
        RootTableManager<
          _$UgkDatabase,
          $DeckDayCountsTable,
          DayCountRow,
          $$DeckDayCountsTableFilterComposer,
          $$DeckDayCountsTableOrderingComposer,
          $$DeckDayCountsTableAnnotationComposer,
          $$DeckDayCountsTableCreateCompanionBuilder,
          $$DeckDayCountsTableUpdateCompanionBuilder,
          (
            DayCountRow,
            BaseReferences<_$UgkDatabase, $DeckDayCountsTable, DayCountRow>,
          ),
          DayCountRow,
          PrefetchHooks Function()
        > {
  $$DeckDayCountsTableTableManager(_$UgkDatabase db, $DeckDayCountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeckDayCountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeckDayCountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeckDayCountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> deckId = const Value.absent(),
                Value<int> day = const Value.absent(),
                Value<int> newDone = const Value.absent(),
                Value<int> reviewDone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeckDayCountsCompanion(
                deckId: deckId,
                day: day,
                newDone: newDone,
                reviewDone: reviewDone,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int deckId,
                required int day,
                required int newDone,
                required int reviewDone,
                Value<int> rowid = const Value.absent(),
              }) => DeckDayCountsCompanion.insert(
                deckId: deckId,
                day: day,
                newDone: newDone,
                reviewDone: reviewDone,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeckDayCountsTable, DayCountRow>(table),
                  BaseReferences<
                    _$UgkDatabase,
                    $DeckDayCountsTable,
                    DayCountRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeckDayCountsTableProcessedTableManager =
    ProcessedTableManager<
      _$UgkDatabase,
      $DeckDayCountsTable,
      DayCountRow,
      $$DeckDayCountsTableFilterComposer,
      $$DeckDayCountsTableOrderingComposer,
      $$DeckDayCountsTableAnnotationComposer,
      $$DeckDayCountsTableCreateCompanionBuilder,
      $$DeckDayCountsTableUpdateCompanionBuilder,
      (
        DayCountRow,
        BaseReferences<_$UgkDatabase, $DeckDayCountsTable, DayCountRow>,
      ),
      DayCountRow,
      PrefetchHooks Function()
    >;

class $UgkDatabaseManager {
  final _$UgkDatabase _db;
  $UgkDatabaseManager(this._db);
  $$CollectionMetaTableTableManager get collectionMeta =>
      $$CollectionMetaTableTableManager(_db, _db.collectionMeta);
  $$DeckConfigsTableTableManager get deckConfigs =>
      $$DeckConfigsTableTableManager(_db, _db.deckConfigs);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$NoteTypesTableTableManager get noteTypes =>
      $$NoteTypesTableTableManager(_db, _db.noteTypes);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$RevlogTableTableManager get revlog =>
      $$RevlogTableTableManager(_db, _db.revlog);
  $$DeckDayCountsTableTableManager get deckDayCounts =>
      $$DeckDayCountsTableTableManager(_db, _db.deckDayCounts);
}
