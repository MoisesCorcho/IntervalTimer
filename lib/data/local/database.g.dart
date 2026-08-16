// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $IntervalsTable extends Intervals
    with TableInfo<$IntervalsTable, IntervalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntervalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorArgbMeta = const VerificationMeta(
    'colorArgb',
  );
  @override
  late final GeneratedColumn<int> colorArgb = GeneratedColumn<int>(
    'color_argb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _announceTextMeta = const VerificationMeta(
    'announceText',
  );
  @override
  late final GeneratedColumn<String> announceText = GeneratedColumn<String>(
    'announce_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    durationSeconds,
    colorArgb,
    type,
    announceText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intervals';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntervalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('color_argb')) {
      context.handle(
        _colorArgbMeta,
        colorArgb.isAcceptableOrUnknown(data['color_argb']!, _colorArgbMeta),
      );
    } else if (isInserting) {
      context.missing(_colorArgbMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('announce_text')) {
      context.handle(
        _announceTextMeta,
        announceText.isAcceptableOrUnknown(
          data['announce_text']!,
          _announceTextMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IntervalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntervalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      colorArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_argb'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      announceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}announce_text'],
      ),
    );
  }

  @override
  $IntervalsTable createAlias(String alias) {
    return $IntervalsTable(attachedDatabase, alias);
  }
}

class IntervalRow extends DataClass implements Insertable<IntervalRow> {
  final String id;
  final String name;
  final int durationSeconds;
  final int colorArgb;
  final String type;

  /// F02: optional custom TTS text; null → use [name].
  final String? announceText;
  const IntervalRow({
    required this.id,
    required this.name,
    required this.durationSeconds,
    required this.colorArgb,
    required this.type,
    this.announceText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['color_argb'] = Variable<int>(colorArgb);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || announceText != null) {
      map['announce_text'] = Variable<String>(announceText);
    }
    return map;
  }

  IntervalsCompanion toCompanion(bool nullToAbsent) {
    return IntervalsCompanion(
      id: Value(id),
      name: Value(name),
      durationSeconds: Value(durationSeconds),
      colorArgb: Value(colorArgb),
      type: Value(type),
      announceText: announceText == null && nullToAbsent
          ? const Value.absent()
          : Value(announceText),
    );
  }

  factory IntervalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntervalRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      colorArgb: serializer.fromJson<int>(json['colorArgb']),
      type: serializer.fromJson<String>(json['type']),
      announceText: serializer.fromJson<String?>(json['announceText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'colorArgb': serializer.toJson<int>(colorArgb),
      'type': serializer.toJson<String>(type),
      'announceText': serializer.toJson<String?>(announceText),
    };
  }

  IntervalRow copyWith({
    String? id,
    String? name,
    int? durationSeconds,
    int? colorArgb,
    String? type,
    Value<String?> announceText = const Value.absent(),
  }) => IntervalRow(
    id: id ?? this.id,
    name: name ?? this.name,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    colorArgb: colorArgb ?? this.colorArgb,
    type: type ?? this.type,
    announceText: announceText.present ? announceText.value : this.announceText,
  );
  IntervalRow copyWithCompanion(IntervalsCompanion data) {
    return IntervalRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      colorArgb: data.colorArgb.present ? data.colorArgb.value : this.colorArgb,
      type: data.type.present ? data.type.value : this.type,
      announceText: data.announceText.present
          ? data.announceText.value
          : this.announceText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntervalRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('type: $type, ')
          ..write('announceText: $announceText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, durationSeconds, colorArgb, type, announceText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntervalRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.durationSeconds == this.durationSeconds &&
          other.colorArgb == this.colorArgb &&
          other.type == this.type &&
          other.announceText == this.announceText);
}

class IntervalsCompanion extends UpdateCompanion<IntervalRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> durationSeconds;
  final Value<int> colorArgb;
  final Value<String> type;
  final Value<String?> announceText;
  final Value<int> rowid;
  const IntervalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.colorArgb = const Value.absent(),
    this.type = const Value.absent(),
    this.announceText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IntervalsCompanion.insert({
    required String id,
    required String name,
    required int durationSeconds,
    required int colorArgb,
    required String type,
    this.announceText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       durationSeconds = Value(durationSeconds),
       colorArgb = Value(colorArgb),
       type = Value(type);
  static Insertable<IntervalRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? durationSeconds,
    Expression<int>? colorArgb,
    Expression<String>? type,
    Expression<String>? announceText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (colorArgb != null) 'color_argb': colorArgb,
      if (type != null) 'type': type,
      if (announceText != null) 'announce_text': announceText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IntervalsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? durationSeconds,
    Value<int>? colorArgb,
    Value<String>? type,
    Value<String?>? announceText,
    Value<int>? rowid,
  }) {
    return IntervalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      colorArgb: colorArgb ?? this.colorArgb,
      type: type ?? this.type,
      announceText: announceText ?? this.announceText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (colorArgb.present) {
      map['color_argb'] = Variable<int>(colorArgb.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (announceText.present) {
      map['announce_text'] = Variable<String>(announceText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntervalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('type: $type, ')
          ..write('announceText: $announceText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines
    with TableInfo<$RoutinesTable, RoutineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class RoutineRow extends DataClass implements Insertable<RoutineRow> {
  final String id;
  final String name;
  final int createdAt;
  const RoutineRow({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory RoutineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  RoutineRow copyWith({String? id, String? name, int? createdAt}) => RoutineRow(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  RoutineRow copyWithCompanion(RoutinesCompanion data) {
    return RoutineRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class RoutinesCompanion extends UpdateCompanion<RoutineRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> rowid;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutinesCompanion.insert({
    required String id,
    required String name,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<RoutineRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutinesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineItemsTable extends RoutineItems
    with TableInfo<$RoutineItemsTable, RoutineItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalIdMeta = const VerificationMeta(
    'intervalId',
  );
  @override
  late final GeneratedColumn<String> intervalId = GeneratedColumn<String>(
    'interval_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES intervals (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    position,
    itemType,
    intervalId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('interval_id')) {
      context.handle(
        _intervalIdMeta,
        intervalId.isAcceptableOrUnknown(data['interval_id']!, _intervalIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {routineId, position},
  ];
  @override
  RoutineItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      intervalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interval_id'],
      ),
    );
  }

  @override
  $RoutineItemsTable createAlias(String alias) {
    return $RoutineItemsTable(attachedDatabase, alias);
  }
}

class RoutineItemRow extends DataClass implements Insertable<RoutineItemRow> {
  final String id;
  final String routineId;
  final int position;
  final String itemType;
  final String? intervalId;
  const RoutineItemRow({
    required this.id,
    required this.routineId,
    required this.position,
    required this.itemType,
    this.intervalId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['routine_id'] = Variable<String>(routineId);
    map['position'] = Variable<int>(position);
    map['item_type'] = Variable<String>(itemType);
    if (!nullToAbsent || intervalId != null) {
      map['interval_id'] = Variable<String>(intervalId);
    }
    return map;
  }

  RoutineItemsCompanion toCompanion(bool nullToAbsent) {
    return RoutineItemsCompanion(
      id: Value(id),
      routineId: Value(routineId),
      position: Value(position),
      itemType: Value(itemType),
      intervalId: intervalId == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalId),
    );
  }

  factory RoutineItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineItemRow(
      id: serializer.fromJson<String>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      position: serializer.fromJson<int>(json['position']),
      itemType: serializer.fromJson<String>(json['itemType']),
      intervalId: serializer.fromJson<String?>(json['intervalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routineId': serializer.toJson<String>(routineId),
      'position': serializer.toJson<int>(position),
      'itemType': serializer.toJson<String>(itemType),
      'intervalId': serializer.toJson<String?>(intervalId),
    };
  }

  RoutineItemRow copyWith({
    String? id,
    String? routineId,
    int? position,
    String? itemType,
    Value<String?> intervalId = const Value.absent(),
  }) => RoutineItemRow(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    position: position ?? this.position,
    itemType: itemType ?? this.itemType,
    intervalId: intervalId.present ? intervalId.value : this.intervalId,
  );
  RoutineItemRow copyWithCompanion(RoutineItemsCompanion data) {
    return RoutineItemRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      position: data.position.present ? data.position.value : this.position,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      intervalId: data.intervalId.present
          ? data.intervalId.value
          : this.intervalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItemRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('position: $position, ')
          ..write('itemType: $itemType, ')
          ..write('intervalId: $intervalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, routineId, position, itemType, intervalId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineItemRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.position == this.position &&
          other.itemType == this.itemType &&
          other.intervalId == this.intervalId);
}

class RoutineItemsCompanion extends UpdateCompanion<RoutineItemRow> {
  final Value<String> id;
  final Value<String> routineId;
  final Value<int> position;
  final Value<String> itemType;
  final Value<String?> intervalId;
  final Value<int> rowid;
  const RoutineItemsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.position = const Value.absent(),
    this.itemType = const Value.absent(),
    this.intervalId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineItemsCompanion.insert({
    required String id,
    required String routineId,
    required int position,
    required String itemType,
    this.intervalId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       routineId = Value(routineId),
       position = Value(position),
       itemType = Value(itemType);
  static Insertable<RoutineItemRow> custom({
    Expression<String>? id,
    Expression<String>? routineId,
    Expression<int>? position,
    Expression<String>? itemType,
    Expression<String>? intervalId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (position != null) 'position': position,
      if (itemType != null) 'item_type': itemType,
      if (intervalId != null) 'interval_id': intervalId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? routineId,
    Value<int>? position,
    Value<String>? itemType,
    Value<String?>? intervalId,
    Value<int>? rowid,
  }) {
    return RoutineItemsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      position: position ?? this.position,
      itemType: itemType ?? this.itemType,
      intervalId: intervalId ?? this.intervalId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (intervalId.present) {
      map['interval_id'] = Variable<String>(intervalId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItemsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('position: $position, ')
          ..write('itemType: $itemType, ')
          ..write('intervalId: $intervalId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts
    with TableInfo<$WorkoutsTable, WorkoutRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int> rounds = GeneratedColumn<int>(
    'rounds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    updatedAt,
    rounds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('rounds')) {
      context.handle(
        _roundsMeta,
        rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      rounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounds'],
      )!,
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class WorkoutRow extends DataClass implements Insertable<WorkoutRow> {
  final String id;
  final String name;
  final int createdAt;
  final int updatedAt;

  /// Global rounds for the whole workout sequence (1–99). Default 1.
  final int rounds;
  const WorkoutRow({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.rounds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['rounds'] = Variable<int>(rounds);
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rounds: Value(rounds),
    );
  }

  factory WorkoutRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      rounds: serializer.fromJson<int>(json['rounds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'rounds': serializer.toJson<int>(rounds),
    };
  }

  WorkoutRow copyWith({
    String? id,
    String? name,
    int? createdAt,
    int? updatedAt,
    int? rounds,
  }) => WorkoutRow(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rounds: rounds ?? this.rounds,
  );
  WorkoutRow copyWithCompanion(WorkoutsCompanion data) {
    return WorkoutRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rounds: data.rounds.present ? data.rounds.value : this.rounds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rounds: $rounds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt, rounds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rounds == this.rounds);
}

class WorkoutsCompanion extends UpdateCompanion<WorkoutRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rounds;
  final Value<int> rowid;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rounds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    required String id,
    required String name,
    required int createdAt,
    required int updatedAt,
    this.rounds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkoutRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rounds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rounds != null) 'rounds': rounds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rounds,
    Value<int>? rowid,
  }) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rounds: rounds ?? this.rounds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int>(rounds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rounds: $rounds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutExercisesTable extends WorkoutExercises
    with TableInfo<$WorkoutExercisesTable, WorkoutExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workouts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<int> sets = GeneratedColumn<int>(
    'sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workSecondsMeta = const VerificationMeta(
    'workSeconds',
  );
  @override
  late final GeneratedColumn<int> workSeconds = GeneratedColumn<int>(
    'work_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restAfterExerciseSecondsMeta =
      const VerificationMeta('restAfterExerciseSeconds');
  @override
  late final GeneratedColumn<int> restAfterExerciseSeconds =
      GeneratedColumn<int>(
        'rest_after_exercise_seconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutId,
    position,
    name,
    sets,
    workSeconds,
    restSeconds,
    restAfterExerciseSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sets')) {
      context.handle(
        _setsMeta,
        sets.isAcceptableOrUnknown(data['sets']!, _setsMeta),
      );
    } else if (isInserting) {
      context.missing(_setsMeta);
    }
    if (data.containsKey('work_seconds')) {
      context.handle(
        _workSecondsMeta,
        workSeconds.isAcceptableOrUnknown(
          data['work_seconds']!,
          _workSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workSecondsMeta);
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restSecondsMeta);
    }
    if (data.containsKey('rest_after_exercise_seconds')) {
      context.handle(
        _restAfterExerciseSecondsMeta,
        restAfterExerciseSeconds.isAcceptableOrUnknown(
          data['rest_after_exercise_seconds']!,
          _restAfterExerciseSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {workoutId, position},
  ];
  @override
  WorkoutExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutExerciseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sets'],
      )!,
      workSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_seconds'],
      )!,
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      )!,
      restAfterExerciseSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_after_exercise_seconds'],
      )!,
    );
  }

  @override
  $WorkoutExercisesTable createAlias(String alias) {
    return $WorkoutExercisesTable(attachedDatabase, alias);
  }
}

class WorkoutExerciseRow extends DataClass
    implements Insertable<WorkoutExerciseRow> {
  final String id;
  final String workoutId;
  final int position;
  final String name;
  final int sets;
  final int workSeconds;
  final int restSeconds;
  final int restAfterExerciseSeconds;
  const WorkoutExerciseRow({
    required this.id,
    required this.workoutId,
    required this.position,
    required this.name,
    required this.sets,
    required this.workSeconds,
    required this.restSeconds,
    required this.restAfterExerciseSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_id'] = Variable<String>(workoutId);
    map['position'] = Variable<int>(position);
    map['name'] = Variable<String>(name);
    map['sets'] = Variable<int>(sets);
    map['work_seconds'] = Variable<int>(workSeconds);
    map['rest_seconds'] = Variable<int>(restSeconds);
    map['rest_after_exercise_seconds'] = Variable<int>(
      restAfterExerciseSeconds,
    );
    return map;
  }

  WorkoutExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutExercisesCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      position: Value(position),
      name: Value(name),
      sets: Value(sets),
      workSeconds: Value(workSeconds),
      restSeconds: Value(restSeconds),
      restAfterExerciseSeconds: Value(restAfterExerciseSeconds),
    );
  }

  factory WorkoutExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      position: serializer.fromJson<int>(json['position']),
      name: serializer.fromJson<String>(json['name']),
      sets: serializer.fromJson<int>(json['sets']),
      workSeconds: serializer.fromJson<int>(json['workSeconds']),
      restSeconds: serializer.fromJson<int>(json['restSeconds']),
      restAfterExerciseSeconds: serializer.fromJson<int>(
        json['restAfterExerciseSeconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutId': serializer.toJson<String>(workoutId),
      'position': serializer.toJson<int>(position),
      'name': serializer.toJson<String>(name),
      'sets': serializer.toJson<int>(sets),
      'workSeconds': serializer.toJson<int>(workSeconds),
      'restSeconds': serializer.toJson<int>(restSeconds),
      'restAfterExerciseSeconds': serializer.toJson<int>(
        restAfterExerciseSeconds,
      ),
    };
  }

  WorkoutExerciseRow copyWith({
    String? id,
    String? workoutId,
    int? position,
    String? name,
    int? sets,
    int? workSeconds,
    int? restSeconds,
    int? restAfterExerciseSeconds,
  }) => WorkoutExerciseRow(
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    position: position ?? this.position,
    name: name ?? this.name,
    sets: sets ?? this.sets,
    workSeconds: workSeconds ?? this.workSeconds,
    restSeconds: restSeconds ?? this.restSeconds,
    restAfterExerciseSeconds:
        restAfterExerciseSeconds ?? this.restAfterExerciseSeconds,
  );
  WorkoutExerciseRow copyWithCompanion(WorkoutExercisesCompanion data) {
    return WorkoutExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      position: data.position.present ? data.position.value : this.position,
      name: data.name.present ? data.name.value : this.name,
      sets: data.sets.present ? data.sets.value : this.sets,
      workSeconds: data.workSeconds.present
          ? data.workSeconds.value
          : this.workSeconds,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
      restAfterExerciseSeconds: data.restAfterExerciseSeconds.present
          ? data.restAfterExerciseSeconds.value
          : this.restAfterExerciseSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExerciseRow(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('sets: $sets, ')
          ..write('workSeconds: $workSeconds, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('restAfterExerciseSeconds: $restAfterExerciseSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutId,
    position,
    name,
    sets,
    workSeconds,
    restSeconds,
    restAfterExerciseSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutExerciseRow &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.position == this.position &&
          other.name == this.name &&
          other.sets == this.sets &&
          other.workSeconds == this.workSeconds &&
          other.restSeconds == this.restSeconds &&
          other.restAfterExerciseSeconds == this.restAfterExerciseSeconds);
}

class WorkoutExercisesCompanion extends UpdateCompanion<WorkoutExerciseRow> {
  final Value<String> id;
  final Value<String> workoutId;
  final Value<int> position;
  final Value<String> name;
  final Value<int> sets;
  final Value<int> workSeconds;
  final Value<int> restSeconds;
  final Value<int> restAfterExerciseSeconds;
  final Value<int> rowid;
  const WorkoutExercisesCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.position = const Value.absent(),
    this.name = const Value.absent(),
    this.sets = const Value.absent(),
    this.workSeconds = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.restAfterExerciseSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutExercisesCompanion.insert({
    required String id,
    required String workoutId,
    required int position,
    required String name,
    required int sets,
    required int workSeconds,
    required int restSeconds,
    this.restAfterExerciseSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workoutId = Value(workoutId),
       position = Value(position),
       name = Value(name),
       sets = Value(sets),
       workSeconds = Value(workSeconds),
       restSeconds = Value(restSeconds);
  static Insertable<WorkoutExerciseRow> custom({
    Expression<String>? id,
    Expression<String>? workoutId,
    Expression<int>? position,
    Expression<String>? name,
    Expression<int>? sets,
    Expression<int>? workSeconds,
    Expression<int>? restSeconds,
    Expression<int>? restAfterExerciseSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (position != null) 'position': position,
      if (name != null) 'name': name,
      if (sets != null) 'sets': sets,
      if (workSeconds != null) 'work_seconds': workSeconds,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (restAfterExerciseSeconds != null)
        'rest_after_exercise_seconds': restAfterExerciseSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutId,
    Value<int>? position,
    Value<String>? name,
    Value<int>? sets,
    Value<int>? workSeconds,
    Value<int>? restSeconds,
    Value<int>? restAfterExerciseSeconds,
    Value<int>? rowid,
  }) {
    return WorkoutExercisesCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      position: position ?? this.position,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      workSeconds: workSeconds ?? this.workSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      restAfterExerciseSeconds:
          restAfterExerciseSeconds ?? this.restAfterExerciseSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sets.present) {
      map['sets'] = Variable<int>(sets.value);
    }
    if (workSeconds.present) {
      map['work_seconds'] = Variable<int>(workSeconds.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (restAfterExerciseSeconds.present) {
      map['rest_after_exercise_seconds'] = Variable<int>(
        restAfterExerciseSeconds.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercisesCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('sets: $sets, ')
          ..write('workSeconds: $workSeconds, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('restAfterExerciseSeconds: $restAfterExerciseSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreferenceRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreferenceRow extends DataClass
    implements Insertable<AppPreferenceRow> {
  final String key;
  final String? value;
  const AppPreferenceRow({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory AppPreferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreferenceRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  AppPreferenceRow copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => AppPreferenceRow(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  AppPreferenceRow copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreferenceRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferenceRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreferenceRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreferenceRow> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppPreferenceRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionLogsTable extends SessionLogs
    with TableInfo<$SessionLogsTable, SessionLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalDurationSecondsMeta =
      const VerificationMeta('totalDurationSeconds');
  @override
  late final GeneratedColumn<int> totalDurationSeconds = GeneratedColumn<int>(
    'total_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemCountMeta = const VerificationMeta(
    'itemCount',
  );
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
    'item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    displayName,
    endedAt,
    localDate,
    status,
    totalDurationSeconds,
    itemCount,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('total_duration_seconds')) {
      context.handle(
        _totalDurationSecondsMeta,
        totalDurationSeconds.isAcceptableOrUnknown(
          data['total_duration_seconds']!,
          _totalDurationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalDurationSecondsMeta);
    }
    if (data.containsKey('item_count')) {
      context.handle(
        _itemCountMeta,
        itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta),
      );
    } else if (isInserting) {
      context.missing(_itemCountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      totalDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration_seconds'],
      )!,
      itemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_count'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $SessionLogsTable createAlias(String alias) {
    return $SessionLogsTable(attachedDatabase, alias);
  }
}

class SessionLogRow extends DataClass implements Insertable<SessionLogRow> {
  final String id;
  final String sourceId;
  final String displayName;
  final int endedAt;
  final String localDate;
  final String status;
  final int totalDurationSeconds;
  final int itemCount;
  final String? note;
  const SessionLogRow({
    required this.id,
    required this.sourceId,
    required this.displayName,
    required this.endedAt,
    required this.localDate,
    required this.status,
    required this.totalDurationSeconds,
    required this.itemCount,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['display_name'] = Variable<String>(displayName);
    map['ended_at'] = Variable<int>(endedAt);
    map['local_date'] = Variable<String>(localDate);
    map['status'] = Variable<String>(status);
    map['total_duration_seconds'] = Variable<int>(totalDurationSeconds);
    map['item_count'] = Variable<int>(itemCount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  SessionLogsCompanion toCompanion(bool nullToAbsent) {
    return SessionLogsCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      displayName: Value(displayName),
      endedAt: Value(endedAt),
      localDate: Value(localDate),
      status: Value(status),
      totalDurationSeconds: Value(totalDurationSeconds),
      itemCount: Value(itemCount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory SessionLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionLogRow(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      endedAt: serializer.fromJson<int>(json['endedAt']),
      localDate: serializer.fromJson<String>(json['localDate']),
      status: serializer.fromJson<String>(json['status']),
      totalDurationSeconds: serializer.fromJson<int>(
        json['totalDurationSeconds'],
      ),
      itemCount: serializer.fromJson<int>(json['itemCount']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'displayName': serializer.toJson<String>(displayName),
      'endedAt': serializer.toJson<int>(endedAt),
      'localDate': serializer.toJson<String>(localDate),
      'status': serializer.toJson<String>(status),
      'totalDurationSeconds': serializer.toJson<int>(totalDurationSeconds),
      'itemCount': serializer.toJson<int>(itemCount),
      'note': serializer.toJson<String?>(note),
    };
  }

  SessionLogRow copyWith({
    String? id,
    String? sourceId,
    String? displayName,
    int? endedAt,
    String? localDate,
    String? status,
    int? totalDurationSeconds,
    int? itemCount,
    Value<String?> note = const Value.absent(),
  }) => SessionLogRow(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    displayName: displayName ?? this.displayName,
    endedAt: endedAt ?? this.endedAt,
    localDate: localDate ?? this.localDate,
    status: status ?? this.status,
    totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
    itemCount: itemCount ?? this.itemCount,
    note: note.present ? note.value : this.note,
  );
  SessionLogRow copyWithCompanion(SessionLogsCompanion data) {
    return SessionLogRow(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      status: data.status.present ? data.status.value : this.status,
      totalDurationSeconds: data.totalDurationSeconds.present
          ? data.totalDurationSeconds.value
          : this.totalDurationSeconds,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionLogRow(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('displayName: $displayName, ')
          ..write('endedAt: $endedAt, ')
          ..write('localDate: $localDate, ')
          ..write('status: $status, ')
          ..write('totalDurationSeconds: $totalDurationSeconds, ')
          ..write('itemCount: $itemCount, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    displayName,
    endedAt,
    localDate,
    status,
    totalDurationSeconds,
    itemCount,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionLogRow &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.displayName == this.displayName &&
          other.endedAt == this.endedAt &&
          other.localDate == this.localDate &&
          other.status == this.status &&
          other.totalDurationSeconds == this.totalDurationSeconds &&
          other.itemCount == this.itemCount &&
          other.note == this.note);
}

class SessionLogsCompanion extends UpdateCompanion<SessionLogRow> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String> displayName;
  final Value<int> endedAt;
  final Value<String> localDate;
  final Value<String> status;
  final Value<int> totalDurationSeconds;
  final Value<int> itemCount;
  final Value<String?> note;
  final Value<int> rowid;
  const SessionLogsCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.localDate = const Value.absent(),
    this.status = const Value.absent(),
    this.totalDurationSeconds = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionLogsCompanion.insert({
    required String id,
    required String sourceId,
    required String displayName,
    required int endedAt,
    required String localDate,
    required String status,
    required int totalDurationSeconds,
    required int itemCount,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       displayName = Value(displayName),
       endedAt = Value(endedAt),
       localDate = Value(localDate),
       status = Value(status),
       totalDurationSeconds = Value(totalDurationSeconds),
       itemCount = Value(itemCount);
  static Insertable<SessionLogRow> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? displayName,
    Expression<int>? endedAt,
    Expression<String>? localDate,
    Expression<String>? status,
    Expression<int>? totalDurationSeconds,
    Expression<int>? itemCount,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (displayName != null) 'display_name': displayName,
      if (endedAt != null) 'ended_at': endedAt,
      if (localDate != null) 'local_date': localDate,
      if (status != null) 'status': status,
      if (totalDurationSeconds != null)
        'total_duration_seconds': totalDurationSeconds,
      if (itemCount != null) 'item_count': itemCount,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<String>? displayName,
    Value<int>? endedAt,
    Value<String>? localDate,
    Value<String>? status,
    Value<int>? totalDurationSeconds,
    Value<int>? itemCount,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return SessionLogsCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      displayName: displayName ?? this.displayName,
      endedAt: endedAt ?? this.endedAt,
      localDate: localDate ?? this.localDate,
      status: status ?? this.status,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      itemCount: itemCount ?? this.itemCount,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalDurationSeconds.present) {
      map['total_duration_seconds'] = Variable<int>(totalDurationSeconds.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionLogsCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('displayName: $displayName, ')
          ..write('endedAt: $endedAt, ')
          ..write('localDate: $localDate, ')
          ..write('status: $status, ')
          ..write('totalDurationSeconds: $totalDurationSeconds, ')
          ..write('itemCount: $itemCount, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementsTable extends BodyMeasurements
    with TableInfo<$BodyMeasurementsTable, BodyMeasurementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _waistCmMeta = const VerificationMeta(
    'waistCm',
  );
  @override
  late final GeneratedColumn<double> waistCm = GeneratedColumn<double>(
    'waist_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _armCmMeta = const VerificationMeta('armCm');
  @override
  late final GeneratedColumn<double> armCm = GeneratedColumn<double>(
    'arm_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legCmMeta = const VerificationMeta('legCm');
  @override
  late final GeneratedColumn<double> legCm = GeneratedColumn<double>(
    'leg_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localDate,
    weightKg,
    waistCm,
    armCm,
    legCm,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyMeasurementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('waist_cm')) {
      context.handle(
        _waistCmMeta,
        waistCm.isAcceptableOrUnknown(data['waist_cm']!, _waistCmMeta),
      );
    }
    if (data.containsKey('arm_cm')) {
      context.handle(
        _armCmMeta,
        armCm.isAcceptableOrUnknown(data['arm_cm']!, _armCmMeta),
      );
    }
    if (data.containsKey('leg_cm')) {
      context.handle(
        _legCmMeta,
        legCm.isAcceptableOrUnknown(data['leg_cm']!, _legCmMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {localDate},
  ];
  @override
  BodyMeasurementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      waistCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}waist_cm'],
      ),
      armCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}arm_cm'],
      ),
      legCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}leg_cm'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BodyMeasurementsTable createAlias(String alias) {
    return $BodyMeasurementsTable(attachedDatabase, alias);
  }
}

class BodyMeasurementRow extends DataClass
    implements Insertable<BodyMeasurementRow> {
  final String id;
  final String localDate;
  final double weightKg;
  final double? waistCm;
  final double? armCm;
  final double? legCm;
  final int createdAt;
  final int updatedAt;
  const BodyMeasurementRow({
    required this.id,
    required this.localDate,
    required this.weightKg,
    this.waistCm,
    this.armCm,
    this.legCm,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_date'] = Variable<String>(localDate);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || waistCm != null) {
      map['waist_cm'] = Variable<double>(waistCm);
    }
    if (!nullToAbsent || armCm != null) {
      map['arm_cm'] = Variable<double>(armCm);
    }
    if (!nullToAbsent || legCm != null) {
      map['leg_cm'] = Variable<double>(legCm);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  BodyMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return BodyMeasurementsCompanion(
      id: Value(id),
      localDate: Value(localDate),
      weightKg: Value(weightKg),
      waistCm: waistCm == null && nullToAbsent
          ? const Value.absent()
          : Value(waistCm),
      armCm: armCm == null && nullToAbsent
          ? const Value.absent()
          : Value(armCm),
      legCm: legCm == null && nullToAbsent
          ? const Value.absent()
          : Value(legCm),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BodyMeasurementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMeasurementRow(
      id: serializer.fromJson<String>(json['id']),
      localDate: serializer.fromJson<String>(json['localDate']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      waistCm: serializer.fromJson<double?>(json['waistCm']),
      armCm: serializer.fromJson<double?>(json['armCm']),
      legCm: serializer.fromJson<double?>(json['legCm']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localDate': serializer.toJson<String>(localDate),
      'weightKg': serializer.toJson<double>(weightKg),
      'waistCm': serializer.toJson<double?>(waistCm),
      'armCm': serializer.toJson<double?>(armCm),
      'legCm': serializer.toJson<double?>(legCm),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  BodyMeasurementRow copyWith({
    String? id,
    String? localDate,
    double? weightKg,
    Value<double?> waistCm = const Value.absent(),
    Value<double?> armCm = const Value.absent(),
    Value<double?> legCm = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => BodyMeasurementRow(
    id: id ?? this.id,
    localDate: localDate ?? this.localDate,
    weightKg: weightKg ?? this.weightKg,
    waistCm: waistCm.present ? waistCm.value : this.waistCm,
    armCm: armCm.present ? armCm.value : this.armCm,
    legCm: legCm.present ? legCm.value : this.legCm,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BodyMeasurementRow copyWithCompanion(BodyMeasurementsCompanion data) {
    return BodyMeasurementRow(
      id: data.id.present ? data.id.value : this.id,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      waistCm: data.waistCm.present ? data.waistCm.value : this.waistCm,
      armCm: data.armCm.present ? data.armCm.value : this.armCm,
      legCm: data.legCm.present ? data.legCm.value : this.legCm,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementRow(')
          ..write('id: $id, ')
          ..write('localDate: $localDate, ')
          ..write('weightKg: $weightKg, ')
          ..write('waistCm: $waistCm, ')
          ..write('armCm: $armCm, ')
          ..write('legCm: $legCm, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localDate,
    weightKg,
    waistCm,
    armCm,
    legCm,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMeasurementRow &&
          other.id == this.id &&
          other.localDate == this.localDate &&
          other.weightKg == this.weightKg &&
          other.waistCm == this.waistCm &&
          other.armCm == this.armCm &&
          other.legCm == this.legCm &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BodyMeasurementsCompanion extends UpdateCompanion<BodyMeasurementRow> {
  final Value<String> id;
  final Value<String> localDate;
  final Value<double> weightKg;
  final Value<double?> waistCm;
  final Value<double?> armCm;
  final Value<double?> legCm;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const BodyMeasurementsCompanion({
    this.id = const Value.absent(),
    this.localDate = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.armCm = const Value.absent(),
    this.legCm = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyMeasurementsCompanion.insert({
    required String id,
    required String localDate,
    required double weightKg,
    this.waistCm = const Value.absent(),
    this.armCm = const Value.absent(),
    this.legCm = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       localDate = Value(localDate),
       weightKg = Value(weightKg),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BodyMeasurementRow> custom({
    Expression<String>? id,
    Expression<String>? localDate,
    Expression<double>? weightKg,
    Expression<double>? waistCm,
    Expression<double>? armCm,
    Expression<double>? legCm,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localDate != null) 'local_date': localDate,
      if (weightKg != null) 'weight_kg': weightKg,
      if (waistCm != null) 'waist_cm': waistCm,
      if (armCm != null) 'arm_cm': armCm,
      if (legCm != null) 'leg_cm': legCm,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyMeasurementsCompanion copyWith({
    Value<String>? id,
    Value<String>? localDate,
    Value<double>? weightKg,
    Value<double?>? waistCm,
    Value<double?>? armCm,
    Value<double?>? legCm,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return BodyMeasurementsCompanion(
      id: id ?? this.id,
      localDate: localDate ?? this.localDate,
      weightKg: weightKg ?? this.weightKg,
      waistCm: waistCm ?? this.waistCm,
      armCm: armCm ?? this.armCm,
      legCm: legCm ?? this.legCm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (waistCm.present) {
      map['waist_cm'] = Variable<double>(waistCm.value);
    }
    if (armCm.present) {
      map['arm_cm'] = Variable<double>(armCm.value);
    }
    if (legCm.present) {
      map['leg_cm'] = Variable<double>(legCm.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('localDate: $localDate, ')
          ..write('weightKg: $weightKg, ')
          ..write('waistCm: $waistCm, ')
          ..write('armCm: $armCm, ')
          ..write('legCm: $legCm, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnlockedAchievementsTable extends UnlockedAchievements
    with TableInfo<$UnlockedAchievementsTable, UnlockedAchievementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnlockedAchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _achievementIdMeta = const VerificationMeta(
    'achievementId',
  );
  @override
  late final GeneratedColumn<String> achievementId = GeneratedColumn<String>(
    'achievement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<int> unlockedAt = GeneratedColumn<int>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [achievementId, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unlocked_achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnlockedAchievementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('achievement_id')) {
      context.handle(
        _achievementIdMeta,
        achievementId.isAcceptableOrUnknown(
          data['achievement_id']!,
          _achievementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_achievementIdMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {achievementId};
  @override
  UnlockedAchievementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnlockedAchievementRow(
      achievementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}achievement_id'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $UnlockedAchievementsTable createAlias(String alias) {
    return $UnlockedAchievementsTable(attachedDatabase, alias);
  }
}

class UnlockedAchievementRow extends DataClass
    implements Insertable<UnlockedAchievementRow> {
  final String achievementId;
  final int unlockedAt;
  const UnlockedAchievementRow({
    required this.achievementId,
    required this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['achievement_id'] = Variable<String>(achievementId);
    map['unlocked_at'] = Variable<int>(unlockedAt);
    return map;
  }

  UnlockedAchievementsCompanion toCompanion(bool nullToAbsent) {
    return UnlockedAchievementsCompanion(
      achievementId: Value(achievementId),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory UnlockedAchievementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnlockedAchievementRow(
      achievementId: serializer.fromJson<String>(json['achievementId']),
      unlockedAt: serializer.fromJson<int>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'achievementId': serializer.toJson<String>(achievementId),
      'unlockedAt': serializer.toJson<int>(unlockedAt),
    };
  }

  UnlockedAchievementRow copyWith({String? achievementId, int? unlockedAt}) =>
      UnlockedAchievementRow(
        achievementId: achievementId ?? this.achievementId,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
  UnlockedAchievementRow copyWithCompanion(UnlockedAchievementsCompanion data) {
    return UnlockedAchievementRow(
      achievementId: data.achievementId.present
          ? data.achievementId.value
          : this.achievementId,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnlockedAchievementRow(')
          ..write('achievementId: $achievementId, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(achievementId, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnlockedAchievementRow &&
          other.achievementId == this.achievementId &&
          other.unlockedAt == this.unlockedAt);
}

class UnlockedAchievementsCompanion
    extends UpdateCompanion<UnlockedAchievementRow> {
  final Value<String> achievementId;
  final Value<int> unlockedAt;
  final Value<int> rowid;
  const UnlockedAchievementsCompanion({
    this.achievementId = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnlockedAchievementsCompanion.insert({
    required String achievementId,
    required int unlockedAt,
    this.rowid = const Value.absent(),
  }) : achievementId = Value(achievementId),
       unlockedAt = Value(unlockedAt);
  static Insertable<UnlockedAchievementRow> custom({
    Expression<String>? achievementId,
    Expression<int>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (achievementId != null) 'achievement_id': achievementId,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnlockedAchievementsCompanion copyWith({
    Value<String>? achievementId,
    Value<int>? unlockedAt,
    Value<int>? rowid,
  }) {
    return UnlockedAchievementsCompanion(
      achievementId: achievementId ?? this.achievementId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (achievementId.present) {
      map['achievement_id'] = Variable<String>(achievementId.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<int>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnlockedAchievementsCompanion(')
          ..write('achievementId: $achievementId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteRoutinesTable extends FavoriteRoutines
    with TableInfo<$FavoriteRoutinesTable, FavoriteRoutineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteRoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, targetId, targetType, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRoutineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {targetId, targetType},
  ];
  @override
  FavoriteRoutineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRoutineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FavoriteRoutinesTable createAlias(String alias) {
    return $FavoriteRoutinesTable(attachedDatabase, alias);
  }
}

class FavoriteRoutineRow extends DataClass
    implements Insertable<FavoriteRoutineRow> {
  final String id;
  final String targetId;
  final String targetType;
  final int createdAt;
  const FavoriteRoutineRow({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['target_id'] = Variable<String>(targetId);
    map['target_type'] = Variable<String>(targetType);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  FavoriteRoutinesCompanion toCompanion(bool nullToAbsent) {
    return FavoriteRoutinesCompanion(
      id: Value(id),
      targetId: Value(targetId),
      targetType: Value(targetType),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteRoutineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRoutineRow(
      id: serializer.fromJson<String>(json['id']),
      targetId: serializer.fromJson<String>(json['targetId']),
      targetType: serializer.fromJson<String>(json['targetType']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'targetId': serializer.toJson<String>(targetId),
      'targetType': serializer.toJson<String>(targetType),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  FavoriteRoutineRow copyWith({
    String? id,
    String? targetId,
    String? targetType,
    int? createdAt,
  }) => FavoriteRoutineRow(
    id: id ?? this.id,
    targetId: targetId ?? this.targetId,
    targetType: targetType ?? this.targetType,
    createdAt: createdAt ?? this.createdAt,
  );
  FavoriteRoutineRow copyWithCompanion(FavoriteRoutinesCompanion data) {
    return FavoriteRoutineRow(
      id: data.id.present ? data.id.value : this.id,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRoutineRow(')
          ..write('id: $id, ')
          ..write('targetId: $targetId, ')
          ..write('targetType: $targetType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, targetId, targetType, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRoutineRow &&
          other.id == this.id &&
          other.targetId == this.targetId &&
          other.targetType == this.targetType &&
          other.createdAt == this.createdAt);
}

class FavoriteRoutinesCompanion extends UpdateCompanion<FavoriteRoutineRow> {
  final Value<String> id;
  final Value<String> targetId;
  final Value<String> targetType;
  final Value<int> createdAt;
  final Value<int> rowid;
  const FavoriteRoutinesCompanion({
    this.id = const Value.absent(),
    this.targetId = const Value.absent(),
    this.targetType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteRoutinesCompanion.insert({
    required String id,
    required String targetId,
    required String targetType,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       targetId = Value(targetId),
       targetType = Value(targetType),
       createdAt = Value(createdAt);
  static Insertable<FavoriteRoutineRow> custom({
    Expression<String>? id,
    Expression<String>? targetId,
    Expression<String>? targetType,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetId != null) 'target_id': targetId,
      if (targetType != null) 'target_type': targetType,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteRoutinesCompanion copyWith({
    Value<String>? id,
    Value<String>? targetId,
    Value<String>? targetType,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return FavoriteRoutinesCompanion(
      id: id ?? this.id,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRoutinesCompanion(')
          ..write('id: $id, ')
          ..write('targetId: $targetId, ')
          ..write('targetType: $targetType, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IntervalsTable intervals = $IntervalsTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $RoutineItemsTable routineItems = $RoutineItemsTable(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $WorkoutExercisesTable workoutExercises = $WorkoutExercisesTable(
    this,
  );
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  late final $SessionLogsTable sessionLogs = $SessionLogsTable(this);
  late final $BodyMeasurementsTable bodyMeasurements = $BodyMeasurementsTable(
    this,
  );
  late final $UnlockedAchievementsTable unlockedAchievements =
      $UnlockedAchievementsTable(this);
  late final $FavoriteRoutinesTable favoriteRoutines = $FavoriteRoutinesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    intervals,
    routines,
    routineItems,
    workouts,
    workoutExercises,
    appPreferences,
    sessionLogs,
    bodyMeasurements,
    unlockedAchievements,
    favoriteRoutines,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workouts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_exercises', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$IntervalsTableCreateCompanionBuilder =
    IntervalsCompanion Function({
      required String id,
      required String name,
      required int durationSeconds,
      required int colorArgb,
      required String type,
      Value<String?> announceText,
      Value<int> rowid,
    });
typedef $$IntervalsTableUpdateCompanionBuilder =
    IntervalsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> durationSeconds,
      Value<int> colorArgb,
      Value<String> type,
      Value<String?> announceText,
      Value<int> rowid,
    });

final class $$IntervalsTableReferences
    extends BaseReferences<_$AppDatabase, $IntervalsTable, IntervalRow> {
  $$IntervalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutineItemsTable, List<RoutineItemRow>>
  _routineItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineItems,
    aliasName: 'intervals__id__routine_items__interval_id',
  );

  $$RoutineItemsTableProcessedTableManager get routineItemsRefs {
    final manager = $$RoutineItemsTableTableManager(
      $_db,
      $_db.routineItems,
    ).filter((f) => f.intervalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IntervalsTableFilterComposer
    extends Composer<_$AppDatabase, $IntervalsTable> {
  $$IntervalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get announceText => $composableBuilder(
    column: $table.announceText,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routineItemsRefs(
    Expression<bool> Function($$RoutineItemsTableFilterComposer f) f,
  ) {
    final $$RoutineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.intervalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableFilterComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IntervalsTableOrderingComposer
    extends Composer<_$AppDatabase, $IntervalsTable> {
  $$IntervalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get announceText => $composableBuilder(
    column: $table.announceText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IntervalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IntervalsTable> {
  $$IntervalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorArgb =>
      $composableBuilder(column: $table.colorArgb, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get announceText => $composableBuilder(
    column: $table.announceText,
    builder: (column) => column,
  );

  Expression<T> routineItemsRefs<T extends Object>(
    Expression<T> Function($$RoutineItemsTableAnnotationComposer a) f,
  ) {
    final $$RoutineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.intervalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IntervalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IntervalsTable,
          IntervalRow,
          $$IntervalsTableFilterComposer,
          $$IntervalsTableOrderingComposer,
          $$IntervalsTableAnnotationComposer,
          $$IntervalsTableCreateCompanionBuilder,
          $$IntervalsTableUpdateCompanionBuilder,
          (IntervalRow, $$IntervalsTableReferences),
          IntervalRow,
          PrefetchHooks Function({bool routineItemsRefs})
        > {
  $$IntervalsTableTableManager(_$AppDatabase db, $IntervalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntervalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntervalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntervalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> colorArgb = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> announceText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntervalsCompanion(
                id: id,
                name: name,
                durationSeconds: durationSeconds,
                colorArgb: colorArgb,
                type: type,
                announceText: announceText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int durationSeconds,
                required int colorArgb,
                required String type,
                Value<String?> announceText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntervalsCompanion.insert(
                id: id,
                name: name,
                durationSeconds: durationSeconds,
                colorArgb: colorArgb,
                type: type,
                announceText: announceText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IntervalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routineItemsRefs) db.routineItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routineItemsRefs)
                    await $_getPrefetchedData<
                      IntervalRow,
                      $IntervalsTable,
                      RoutineItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$IntervalsTableReferences
                          ._routineItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$IntervalsTableReferences(
                            db,
                            table,
                            p0,
                          ).routineItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.intervalId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$IntervalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IntervalsTable,
      IntervalRow,
      $$IntervalsTableFilterComposer,
      $$IntervalsTableOrderingComposer,
      $$IntervalsTableAnnotationComposer,
      $$IntervalsTableCreateCompanionBuilder,
      $$IntervalsTableUpdateCompanionBuilder,
      (IntervalRow, $$IntervalsTableReferences),
      IntervalRow,
      PrefetchHooks Function({bool routineItemsRefs})
    >;
typedef $$RoutinesTableCreateCompanionBuilder =
    RoutinesCompanion Function({
      required String id,
      required String name,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$RoutinesTableUpdateCompanionBuilder =
    RoutinesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$RoutinesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutinesTable, RoutineRow> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutineItemsTable, List<RoutineItemRow>>
  _routineItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineItems,
    aliasName: 'routines__id__routine_items__routine_id',
  );

  $$RoutineItemsTableProcessedTableManager get routineItemsRefs {
    final manager = $$RoutineItemsTableTableManager(
      $_db,
      $_db.routineItems,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routineItemsRefs(
    Expression<bool> Function($$RoutineItemsTableFilterComposer f) f,
  ) {
    final $$RoutineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableFilterComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> routineItemsRefs<T extends Object>(
    Expression<T> Function($$RoutineItemsTableAnnotationComposer a) f,
  ) {
    final $$RoutineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutinesTable,
          RoutineRow,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (RoutineRow, $$RoutinesTableReferences),
          RoutineRow,
          PrefetchHooks Function({bool routineItemsRefs})
        > {
  $$RoutinesTableTableManager(_$AppDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routineItemsRefs) db.routineItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routineItemsRefs)
                    await $_getPrefetchedData<
                      RoutineRow,
                      $RoutinesTable,
                      RoutineItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$RoutinesTableReferences
                          ._routineItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$RoutinesTableReferences(
                        db,
                        table,
                        p0,
                      ).routineItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.routineId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutinesTable,
      RoutineRow,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (RoutineRow, $$RoutinesTableReferences),
      RoutineRow,
      PrefetchHooks Function({bool routineItemsRefs})
    >;
typedef $$RoutineItemsTableCreateCompanionBuilder =
    RoutineItemsCompanion Function({
      required String id,
      required String routineId,
      required int position,
      required String itemType,
      Value<String?> intervalId,
      Value<int> rowid,
    });
typedef $$RoutineItemsTableUpdateCompanionBuilder =
    RoutineItemsCompanion Function({
      Value<String> id,
      Value<String> routineId,
      Value<int> position,
      Value<String> itemType,
      Value<String?> intervalId,
      Value<int> rowid,
    });

final class $$RoutineItemsTableReferences
    extends BaseReferences<_$AppDatabase, $RoutineItemsTable, RoutineItemRow> {
  $$RoutineItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutinesTable _routineIdTable(_$AppDatabase db) =>
      db.routines.createAlias('routine_items__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IntervalsTable _intervalIdTable(_$AppDatabase db) =>
      db.intervals.createAlias('routine_items__interval_id__intervals__id');

  $$IntervalsTableProcessedTableManager? get intervalId {
    final $_column = $_itemColumn<String>('interval_id');
    if ($_column == null) return null;
    final manager = $$IntervalsTableTableManager(
      $_db,
      $_db.intervals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_intervalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IntervalsTableFilterComposer get intervalId {
    final $$IntervalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intervalId,
      referencedTable: $db.intervals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntervalsTableFilterComposer(
            $db: $db,
            $table: $db.intervals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IntervalsTableOrderingComposer get intervalId {
    final $$IntervalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intervalId,
      referencedTable: $db.intervals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntervalsTableOrderingComposer(
            $db: $db,
            $table: $db.intervals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IntervalsTableAnnotationComposer get intervalId {
    final $$IntervalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intervalId,
      referencedTable: $db.intervals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntervalsTableAnnotationComposer(
            $db: $db,
            $table: $db.intervals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineItemsTable,
          RoutineItemRow,
          $$RoutineItemsTableFilterComposer,
          $$RoutineItemsTableOrderingComposer,
          $$RoutineItemsTableAnnotationComposer,
          $$RoutineItemsTableCreateCompanionBuilder,
          $$RoutineItemsTableUpdateCompanionBuilder,
          (RoutineItemRow, $$RoutineItemsTableReferences),
          RoutineItemRow,
          PrefetchHooks Function({bool routineId, bool intervalId})
        > {
  $$RoutineItemsTableTableManager(_$AppDatabase db, $RoutineItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<String?> intervalId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineItemsCompanion(
                id: id,
                routineId: routineId,
                position: position,
                itemType: itemType,
                intervalId: intervalId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String routineId,
                required int position,
                required String itemType,
                Value<String?> intervalId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineItemsCompanion.insert(
                id: id,
                routineId: routineId,
                position: position,
                itemType: itemType,
                intervalId: intervalId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutineItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineId = false, intervalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routineId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.routineId,
                                referencedTable: $$RoutineItemsTableReferences
                                    ._routineIdTable(db),
                                referencedColumn: $$RoutineItemsTableReferences
                                    ._routineIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (intervalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.intervalId,
                                referencedTable: $$RoutineItemsTableReferences
                                    ._intervalIdTable(db),
                                referencedColumn: $$RoutineItemsTableReferences
                                    ._intervalIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineItemsTable,
      RoutineItemRow,
      $$RoutineItemsTableFilterComposer,
      $$RoutineItemsTableOrderingComposer,
      $$RoutineItemsTableAnnotationComposer,
      $$RoutineItemsTableCreateCompanionBuilder,
      $$RoutineItemsTableUpdateCompanionBuilder,
      (RoutineItemRow, $$RoutineItemsTableReferences),
      RoutineItemRow,
      PrefetchHooks Function({bool routineId, bool intervalId})
    >;
typedef $$WorkoutsTableCreateCompanionBuilder =
    WorkoutsCompanion Function({
      required String id,
      required String name,
      required int createdAt,
      required int updatedAt,
      Value<int> rounds,
      Value<int> rowid,
    });
typedef $$WorkoutsTableUpdateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rounds,
      Value<int> rowid,
    });

final class $$WorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutsTable, WorkoutRow> {
  $$WorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExerciseRow>>
  _workoutExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutExercises,
    aliasName: 'workouts__id__workout_exercises__workout_id',
  );

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager = $$WorkoutExercisesTableTableManager(
      $_db,
      $_db.workoutExercises,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutExercisesRefs(
    Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get rounds =>
      $composableBuilder(column: $table.rounds, builder: (column) => column);

  Expression<T> workoutExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutsTable,
          WorkoutRow,
          $$WorkoutsTableFilterComposer,
          $$WorkoutsTableOrderingComposer,
          $$WorkoutsTableAnnotationComposer,
          $$WorkoutsTableCreateCompanionBuilder,
          $$WorkoutsTableUpdateCompanionBuilder,
          (WorkoutRow, $$WorkoutsTableReferences),
          WorkoutRow,
          PrefetchHooks Function({bool workoutExercisesRefs})
        > {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rounds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rounds: rounds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int createdAt,
                required int updatedAt,
                Value<int> rounds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rounds: rounds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workoutExercisesRefs) db.workoutExercises,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutExercisesRefs)
                    await $_getPrefetchedData<
                      WorkoutRow,
                      $WorkoutsTable,
                      WorkoutExerciseRow
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutsTableReferences
                          ._workoutExercisesRefsTable(db),
                      managerFromTypedResult: (p0) => $$WorkoutsTableReferences(
                        db,
                        table,
                        p0,
                      ).workoutExercisesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.workoutId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutsTable,
      WorkoutRow,
      $$WorkoutsTableFilterComposer,
      $$WorkoutsTableOrderingComposer,
      $$WorkoutsTableAnnotationComposer,
      $$WorkoutsTableCreateCompanionBuilder,
      $$WorkoutsTableUpdateCompanionBuilder,
      (WorkoutRow, $$WorkoutsTableReferences),
      WorkoutRow,
      PrefetchHooks Function({bool workoutExercisesRefs})
    >;
typedef $$WorkoutExercisesTableCreateCompanionBuilder =
    WorkoutExercisesCompanion Function({
      required String id,
      required String workoutId,
      required int position,
      required String name,
      required int sets,
      required int workSeconds,
      required int restSeconds,
      Value<int> restAfterExerciseSeconds,
      Value<int> rowid,
    });
typedef $$WorkoutExercisesTableUpdateCompanionBuilder =
    WorkoutExercisesCompanion Function({
      Value<String> id,
      Value<String> workoutId,
      Value<int> position,
      Value<String> name,
      Value<int> sets,
      Value<int> workSeconds,
      Value<int> restSeconds,
      Value<int> restAfterExerciseSeconds,
      Value<int> rowid,
    });

final class $$WorkoutExercisesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutExercisesTable,
          WorkoutExerciseRow
        > {
  $$WorkoutExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('workout_exercises__workout_id__workouts__id');

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<String>('workout_id')!;

    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workSeconds => $composableBuilder(
    column: $table.workSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restAfterExerciseSeconds => $composableBuilder(
    column: $table.restAfterExerciseSeconds,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workSeconds => $composableBuilder(
    column: $table.workSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restAfterExerciseSeconds => $composableBuilder(
    column: $table.restAfterExerciseSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<int> get workSeconds => $composableBuilder(
    column: $table.workSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restAfterExerciseSeconds => $composableBuilder(
    column: $table.restAfterExerciseSeconds,
    builder: (column) => column,
  );

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutExercisesTable,
          WorkoutExerciseRow,
          $$WorkoutExercisesTableFilterComposer,
          $$WorkoutExercisesTableOrderingComposer,
          $$WorkoutExercisesTableAnnotationComposer,
          $$WorkoutExercisesTableCreateCompanionBuilder,
          $$WorkoutExercisesTableUpdateCompanionBuilder,
          (WorkoutExerciseRow, $$WorkoutExercisesTableReferences),
          WorkoutExerciseRow,
          PrefetchHooks Function({bool workoutId})
        > {
  $$WorkoutExercisesTableTableManager(
    _$AppDatabase db,
    $WorkoutExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sets = const Value.absent(),
                Value<int> workSeconds = const Value.absent(),
                Value<int> restSeconds = const Value.absent(),
                Value<int> restAfterExerciseSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutExercisesCompanion(
                id: id,
                workoutId: workoutId,
                position: position,
                name: name,
                sets: sets,
                workSeconds: workSeconds,
                restSeconds: restSeconds,
                restAfterExerciseSeconds: restAfterExerciseSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workoutId,
                required int position,
                required String name,
                required int sets,
                required int workSeconds,
                required int restSeconds,
                Value<int> restAfterExerciseSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutExercisesCompanion.insert(
                id: id,
                workoutId: workoutId,
                position: position,
                name: name,
                sets: sets,
                workSeconds: workSeconds,
                restSeconds: restSeconds,
                restAfterExerciseSeconds: restAfterExerciseSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workoutId,
                                referencedTable:
                                    $$WorkoutExercisesTableReferences
                                        ._workoutIdTable(db),
                                referencedColumn:
                                    $$WorkoutExercisesTableReferences
                                        ._workoutIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutExercisesTable,
      WorkoutExerciseRow,
      $$WorkoutExercisesTableFilterComposer,
      $$WorkoutExercisesTableOrderingComposer,
      $$WorkoutExercisesTableAnnotationComposer,
      $$WorkoutExercisesTableCreateCompanionBuilder,
      $$WorkoutExercisesTableUpdateCompanionBuilder,
      (WorkoutExerciseRow, $$WorkoutExercisesTableReferences),
      WorkoutExerciseRow,
      PrefetchHooks Function({bool workoutId})
    >;
typedef $$AppPreferencesTableCreateCompanionBuilder =
    AppPreferencesCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$AppPreferencesTableUpdateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$AppPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPreferencesTable,
          AppPreferenceRow,
          $$AppPreferencesTableFilterComposer,
          $$AppPreferencesTableOrderingComposer,
          $$AppPreferencesTableAnnotationComposer,
          $$AppPreferencesTableCreateCompanionBuilder,
          $$AppPreferencesTableUpdateCompanionBuilder,
          (
            AppPreferenceRow,
            BaseReferences<
              _$AppDatabase,
              $AppPreferencesTable,
              AppPreferenceRow
            >,
          ),
          AppPreferenceRow,
          PrefetchHooks Function()
        > {
  $$AppPreferencesTableTableManager(
    _$AppDatabase db,
    $AppPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppPreferencesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPreferencesTable,
      AppPreferenceRow,
      $$AppPreferencesTableFilterComposer,
      $$AppPreferencesTableOrderingComposer,
      $$AppPreferencesTableAnnotationComposer,
      $$AppPreferencesTableCreateCompanionBuilder,
      $$AppPreferencesTableUpdateCompanionBuilder,
      (
        AppPreferenceRow,
        BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreferenceRow>,
      ),
      AppPreferenceRow,
      PrefetchHooks Function()
    >;
typedef $$SessionLogsTableCreateCompanionBuilder =
    SessionLogsCompanion Function({
      required String id,
      required String sourceId,
      required String displayName,
      required int endedAt,
      required String localDate,
      required String status,
      required int totalDurationSeconds,
      required int itemCount,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$SessionLogsTableUpdateCompanionBuilder =
    SessionLogsCompanion Function({
      Value<String> id,
      Value<String> sourceId,
      Value<String> displayName,
      Value<int> endedAt,
      Value<String> localDate,
      Value<String> status,
      Value<int> totalDurationSeconds,
      Value<int> itemCount,
      Value<String?> note,
      Value<int> rowid,
    });

class $$SessionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionLogsTable> {
  $$SessionLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDurationSeconds => $composableBuilder(
    column: $table.totalDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionLogsTable> {
  $$SessionLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDurationSeconds => $composableBuilder(
    column: $table.totalDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionLogsTable> {
  $$SessionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalDurationSeconds => $composableBuilder(
    column: $table.totalDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$SessionLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionLogsTable,
          SessionLogRow,
          $$SessionLogsTableFilterComposer,
          $$SessionLogsTableOrderingComposer,
          $$SessionLogsTableAnnotationComposer,
          $$SessionLogsTableCreateCompanionBuilder,
          $$SessionLogsTableUpdateCompanionBuilder,
          (
            SessionLogRow,
            BaseReferences<_$AppDatabase, $SessionLogsTable, SessionLogRow>,
          ),
          SessionLogRow,
          PrefetchHooks Function()
        > {
  $$SessionLogsTableTableManager(_$AppDatabase db, $SessionLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> endedAt = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> totalDurationSeconds = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionLogsCompanion(
                id: id,
                sourceId: sourceId,
                displayName: displayName,
                endedAt: endedAt,
                localDate: localDate,
                status: status,
                totalDurationSeconds: totalDurationSeconds,
                itemCount: itemCount,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceId,
                required String displayName,
                required int endedAt,
                required String localDate,
                required String status,
                required int totalDurationSeconds,
                required int itemCount,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionLogsCompanion.insert(
                id: id,
                sourceId: sourceId,
                displayName: displayName,
                endedAt: endedAt,
                localDate: localDate,
                status: status,
                totalDurationSeconds: totalDurationSeconds,
                itemCount: itemCount,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionLogsTable,
      SessionLogRow,
      $$SessionLogsTableFilterComposer,
      $$SessionLogsTableOrderingComposer,
      $$SessionLogsTableAnnotationComposer,
      $$SessionLogsTableCreateCompanionBuilder,
      $$SessionLogsTableUpdateCompanionBuilder,
      (
        SessionLogRow,
        BaseReferences<_$AppDatabase, $SessionLogsTable, SessionLogRow>,
      ),
      SessionLogRow,
      PrefetchHooks Function()
    >;
typedef $$BodyMeasurementsTableCreateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      required String id,
      required String localDate,
      required double weightKg,
      Value<double?> waistCm,
      Value<double?> armCm,
      Value<double?> legCm,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$BodyMeasurementsTableUpdateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      Value<String> id,
      Value<String> localDate,
      Value<double> weightKg,
      Value<double?> waistCm,
      Value<double?> armCm,
      Value<double?> legCm,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$BodyMeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get armCm => $composableBuilder(
    column: $table.armCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get legCm => $composableBuilder(
    column: $table.legCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyMeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get armCm => $composableBuilder(
    column: $table.armCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get legCm => $composableBuilder(
    column: $table.legCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyMeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get waistCm =>
      $composableBuilder(column: $table.waistCm, builder: (column) => column);

  GeneratedColumn<double> get armCm =>
      $composableBuilder(column: $table.armCm, builder: (column) => column);

  GeneratedColumn<double> get legCm =>
      $composableBuilder(column: $table.legCm, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BodyMeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyMeasurementsTable,
          BodyMeasurementRow,
          $$BodyMeasurementsTableFilterComposer,
          $$BodyMeasurementsTableOrderingComposer,
          $$BodyMeasurementsTableAnnotationComposer,
          $$BodyMeasurementsTableCreateCompanionBuilder,
          $$BodyMeasurementsTableUpdateCompanionBuilder,
          (
            BodyMeasurementRow,
            BaseReferences<
              _$AppDatabase,
              $BodyMeasurementsTable,
              BodyMeasurementRow
            >,
          ),
          BodyMeasurementRow,
          PrefetchHooks Function()
        > {
  $$BodyMeasurementsTableTableManager(
    _$AppDatabase db,
    $BodyMeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyMeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> armCm = const Value.absent(),
                Value<double?> legCm = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion(
                id: id,
                localDate: localDate,
                weightKg: weightKg,
                waistCm: waistCm,
                armCm: armCm,
                legCm: legCm,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String localDate,
                required double weightKg,
                Value<double?> waistCm = const Value.absent(),
                Value<double?> armCm = const Value.absent(),
                Value<double?> legCm = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion.insert(
                id: id,
                localDate: localDate,
                weightKg: weightKg,
                waistCm: waistCm,
                armCm: armCm,
                legCm: legCm,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyMeasurementsTable,
      BodyMeasurementRow,
      $$BodyMeasurementsTableFilterComposer,
      $$BodyMeasurementsTableOrderingComposer,
      $$BodyMeasurementsTableAnnotationComposer,
      $$BodyMeasurementsTableCreateCompanionBuilder,
      $$BodyMeasurementsTableUpdateCompanionBuilder,
      (
        BodyMeasurementRow,
        BaseReferences<
          _$AppDatabase,
          $BodyMeasurementsTable,
          BodyMeasurementRow
        >,
      ),
      BodyMeasurementRow,
      PrefetchHooks Function()
    >;
typedef $$UnlockedAchievementsTableCreateCompanionBuilder =
    UnlockedAchievementsCompanion Function({
      required String achievementId,
      required int unlockedAt,
      Value<int> rowid,
    });
typedef $$UnlockedAchievementsTableUpdateCompanionBuilder =
    UnlockedAchievementsCompanion Function({
      Value<String> achievementId,
      Value<int> unlockedAt,
      Value<int> rowid,
    });

class $$UnlockedAchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $UnlockedAchievementsTable> {
  $$UnlockedAchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnlockedAchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnlockedAchievementsTable> {
  $$UnlockedAchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnlockedAchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnlockedAchievementsTable> {
  $$UnlockedAchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$UnlockedAchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnlockedAchievementsTable,
          UnlockedAchievementRow,
          $$UnlockedAchievementsTableFilterComposer,
          $$UnlockedAchievementsTableOrderingComposer,
          $$UnlockedAchievementsTableAnnotationComposer,
          $$UnlockedAchievementsTableCreateCompanionBuilder,
          $$UnlockedAchievementsTableUpdateCompanionBuilder,
          (
            UnlockedAchievementRow,
            BaseReferences<
              _$AppDatabase,
              $UnlockedAchievementsTable,
              UnlockedAchievementRow
            >,
          ),
          UnlockedAchievementRow,
          PrefetchHooks Function()
        > {
  $$UnlockedAchievementsTableTableManager(
    _$AppDatabase db,
    $UnlockedAchievementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnlockedAchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnlockedAchievementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UnlockedAchievementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> achievementId = const Value.absent(),
                Value<int> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnlockedAchievementsCompanion(
                achievementId: achievementId,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String achievementId,
                required int unlockedAt,
                Value<int> rowid = const Value.absent(),
              }) => UnlockedAchievementsCompanion.insert(
                achievementId: achievementId,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnlockedAchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnlockedAchievementsTable,
      UnlockedAchievementRow,
      $$UnlockedAchievementsTableFilterComposer,
      $$UnlockedAchievementsTableOrderingComposer,
      $$UnlockedAchievementsTableAnnotationComposer,
      $$UnlockedAchievementsTableCreateCompanionBuilder,
      $$UnlockedAchievementsTableUpdateCompanionBuilder,
      (
        UnlockedAchievementRow,
        BaseReferences<
          _$AppDatabase,
          $UnlockedAchievementsTable,
          UnlockedAchievementRow
        >,
      ),
      UnlockedAchievementRow,
      PrefetchHooks Function()
    >;
typedef $$FavoriteRoutinesTableCreateCompanionBuilder =
    FavoriteRoutinesCompanion Function({
      required String id,
      required String targetId,
      required String targetType,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$FavoriteRoutinesTableUpdateCompanionBuilder =
    FavoriteRoutinesCompanion Function({
      Value<String> id,
      Value<String> targetId,
      Value<String> targetType,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$FavoriteRoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteRoutinesTable> {
  $$FavoriteRoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteRoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteRoutinesTable> {
  $$FavoriteRoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteRoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteRoutinesTable> {
  $$FavoriteRoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoriteRoutinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteRoutinesTable,
          FavoriteRoutineRow,
          $$FavoriteRoutinesTableFilterComposer,
          $$FavoriteRoutinesTableOrderingComposer,
          $$FavoriteRoutinesTableAnnotationComposer,
          $$FavoriteRoutinesTableCreateCompanionBuilder,
          $$FavoriteRoutinesTableUpdateCompanionBuilder,
          (
            FavoriteRoutineRow,
            BaseReferences<
              _$AppDatabase,
              $FavoriteRoutinesTable,
              FavoriteRoutineRow
            >,
          ),
          FavoriteRoutineRow,
          PrefetchHooks Function()
        > {
  $$FavoriteRoutinesTableTableManager(
    _$AppDatabase db,
    $FavoriteRoutinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteRoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteRoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteRoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteRoutinesCompanion(
                id: id,
                targetId: targetId,
                targetType: targetType,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String targetId,
                required String targetType,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoriteRoutinesCompanion.insert(
                id: id,
                targetId: targetId,
                targetType: targetType,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteRoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteRoutinesTable,
      FavoriteRoutineRow,
      $$FavoriteRoutinesTableFilterComposer,
      $$FavoriteRoutinesTableOrderingComposer,
      $$FavoriteRoutinesTableAnnotationComposer,
      $$FavoriteRoutinesTableCreateCompanionBuilder,
      $$FavoriteRoutinesTableUpdateCompanionBuilder,
      (
        FavoriteRoutineRow,
        BaseReferences<
          _$AppDatabase,
          $FavoriteRoutinesTable,
          FavoriteRoutineRow
        >,
      ),
      FavoriteRoutineRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IntervalsTableTableManager get intervals =>
      $$IntervalsTableTableManager(_db, _db.intervals);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$RoutineItemsTableTableManager get routineItems =>
      $$RoutineItemsTableTableManager(_db, _db.routineItems);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$WorkoutExercisesTableTableManager get workoutExercises =>
      $$WorkoutExercisesTableTableManager(_db, _db.workoutExercises);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
  $$SessionLogsTableTableManager get sessionLogs =>
      $$SessionLogsTableTableManager(_db, _db.sessionLogs);
  $$BodyMeasurementsTableTableManager get bodyMeasurements =>
      $$BodyMeasurementsTableTableManager(_db, _db.bodyMeasurements);
  $$UnlockedAchievementsTableTableManager get unlockedAchievements =>
      $$UnlockedAchievementsTableTableManager(_db, _db.unlockedAchievements);
  $$FavoriteRoutinesTableTableManager get favoriteRoutines =>
      $$FavoriteRoutinesTableTableManager(_db, _db.favoriteRoutines);
}
