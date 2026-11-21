// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_fixture.dart';

// ignore_for_file: type=lint
class $SampleRecordsTable extends SampleRecords
    with TableInfo<$SampleRecordsTable, SampleRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SampleRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sample_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SampleRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SampleRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SampleRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
    );
  }

  @override
  $SampleRecordsTable createAlias(String alias) {
    return $SampleRecordsTable(attachedDatabase, alias);
  }
}

class SampleRecord extends DataClass implements Insertable<SampleRecord> {
  final int id;
  const SampleRecord({required this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    return map;
  }

  SampleRecordsCompanion toCompanion(bool nullToAbsent) {
    return SampleRecordsCompanion(id: Value(id));
  }

  factory SampleRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SampleRecord(id: serializer.fromJson<int>(json['id']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'id': serializer.toJson<int>(id)};
  }

  SampleRecord copyWith({int? id}) => SampleRecord(id: id ?? this.id);
  SampleRecord copyWithCompanion(SampleRecordsCompanion data) {
    return SampleRecord(id: data.id.present ? data.id.value : this.id);
  }

  @override
  String toString() {
    return (StringBuffer('SampleRecord(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SampleRecord && other.id == this.id);
}

class SampleRecordsCompanion extends UpdateCompanion<SampleRecord> {
  final Value<int> id;
  const SampleRecordsCompanion({this.id = const Value.absent()});
  SampleRecordsCompanion.insert({this.id = const Value.absent()});
  static Insertable<SampleRecord> custom({Expression<int>? id}) {
    return RawValuesInsertable({if (id != null) 'id': id});
  }

  SampleRecordsCompanion copyWith({Value<int>? id}) {
    return SampleRecordsCompanion(id: id ?? this.id);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SampleRecordsCompanion(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }
}

abstract class _$SampleDatabase extends GeneratedDatabase {
  _$SampleDatabase(QueryExecutor e) : super(e);
  $SampleDatabaseManager get managers => $SampleDatabaseManager(this);
  late final $SampleRecordsTable sampleRecords = $SampleRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sampleRecords];
}

typedef $$SampleRecordsTableCreateCompanionBuilder =
    SampleRecordsCompanion Function({Value<int> id});
typedef $$SampleRecordsTableUpdateCompanionBuilder =
    SampleRecordsCompanion Function({Value<int> id});

class $$SampleRecordsTableFilterComposer
    extends Composer<_$SampleDatabase, $SampleRecordsTable> {
  $$SampleRecordsTableFilterComposer({
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
}

class $$SampleRecordsTableOrderingComposer
    extends Composer<_$SampleDatabase, $SampleRecordsTable> {
  $$SampleRecordsTableOrderingComposer({
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
}

class $$SampleRecordsTableAnnotationComposer
    extends Composer<_$SampleDatabase, $SampleRecordsTable> {
  $$SampleRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
}

class $$SampleRecordsTableTableManager
    extends
        RootTableManager<
          _$SampleDatabase,
          $SampleRecordsTable,
          SampleRecord,
          $$SampleRecordsTableFilterComposer,
          $$SampleRecordsTableOrderingComposer,
          $$SampleRecordsTableAnnotationComposer,
          $$SampleRecordsTableCreateCompanionBuilder,
          $$SampleRecordsTableUpdateCompanionBuilder,
          (
            SampleRecord,
            BaseReferences<_$SampleDatabase, $SampleRecordsTable, SampleRecord>,
          ),
          SampleRecord,
          PrefetchHooks Function()
        > {
  $$SampleRecordsTableTableManager(
    _$SampleDatabase db,
    $SampleRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SampleRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SampleRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SampleRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({Value<int> id = const Value.absent()}) =>
              SampleRecordsCompanion(id: id),
          createCompanionCallback: ({Value<int> id = const Value.absent()}) =>
              SampleRecordsCompanion.insert(id: id),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SampleRecordsTable, SampleRecord>(table),
                  BaseReferences<
                    _$SampleDatabase,
                    $SampleRecordsTable,
                    SampleRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SampleRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$SampleDatabase,
      $SampleRecordsTable,
      SampleRecord,
      $$SampleRecordsTableFilterComposer,
      $$SampleRecordsTableOrderingComposer,
      $$SampleRecordsTableAnnotationComposer,
      $$SampleRecordsTableCreateCompanionBuilder,
      $$SampleRecordsTableUpdateCompanionBuilder,
      (
        SampleRecord,
        BaseReferences<_$SampleDatabase, $SampleRecordsTable, SampleRecord>,
      ),
      SampleRecord,
      PrefetchHooks Function()
    >;

class $SampleDatabaseManager {
  final _$SampleDatabase _db;
  $SampleDatabaseManager(this._db);
  $$SampleRecordsTableTableManager get sampleRecords =>
      $$SampleRecordsTableTableManager(_db, _db.sampleRecords);
}
