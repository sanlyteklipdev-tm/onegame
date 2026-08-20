// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTableModelCollection on Isar {
  IsarCollection<TableModel> get tableModels => this.collection();
}

const TableModelSchema = CollectionSchema(
  name: r'TableModel',
  id: 3157658449793411318,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isActive': PropertySchema(
      id: 1,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isAvailable': PropertySchema(
      id: 2,
      name: r'isAvailable',
      type: IsarType.bool,
    ),
    r'maxUsers': PropertySchema(
      id: 3,
      name: r'maxUsers',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'pricePerHour': PropertySchema(
      id: 5,
      name: r'pricePerHour',
      type: IsarType.double,
    ),
    r'pricePerMinute': PropertySchema(
      id: 6,
      name: r'pricePerMinute',
      type: IsarType.double,
    ),
    r'status': PropertySchema(
      id: 7,
      name: r'status',
      type: IsarType.byte,
      enumMap: _TableModelstatusEnumValueMap,
    )
  },
  estimateSize: _tableModelEstimateSize,
  serialize: _tableModelSerialize,
  deserialize: _tableModelDeserialize,
  deserializeProp: _tableModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _tableModelGetId,
  getLinks: _tableModelGetLinks,
  attach: _tableModelAttach,
  version: '3.1.0+1',
);

int _tableModelEstimateSize(
  TableModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _tableModelSerialize(
  TableModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.isActive);
  writer.writeBool(offsets[2], object.isAvailable);
  writer.writeLong(offsets[3], object.maxUsers);
  writer.writeString(offsets[4], object.name);
  writer.writeDouble(offsets[5], object.pricePerHour);
  writer.writeDouble(offsets[6], object.pricePerMinute);
  writer.writeByte(offsets[7], object.status.index);
}

TableModel _tableModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TableModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.maxUsers = reader.readLongOrNull(offsets[3]);
  object.name = reader.readString(offsets[4]);
  object.pricePerHour = reader.readDouble(offsets[5]);
  object.status =
      _TableModelstatusValueEnumMap[reader.readByteOrNull(offsets[7])] ??
          TableStatus.available;
  return object;
}

P _tableModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (_TableModelstatusValueEnumMap[reader.readByteOrNull(offset)] ??
          TableStatus.available) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TableModelstatusEnumValueMap = {
  'available': 0,
  'active': 1,
};
const _TableModelstatusValueEnumMap = {
  0: TableStatus.available,
  1: TableStatus.active,
};

Id _tableModelGetId(TableModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tableModelGetLinks(TableModel object) {
  return [];
}

void _tableModelAttach(IsarCollection<dynamic> col, Id id, TableModel object) {
  object.id = id;
}

extension TableModelByIndex on IsarCollection<TableModel> {
  Future<TableModel?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  TableModel? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<TableModel?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<TableModel?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(TableModel object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(TableModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<TableModel> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<TableModel> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension TableModelQueryWhereSort
    on QueryBuilder<TableModel, TableModel, QWhere> {
  QueryBuilder<TableModel, TableModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TableModelQueryWhere
    on QueryBuilder<TableModel, TableModel, QWhereClause> {
  QueryBuilder<TableModel, TableModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TableModelQueryFilter
    on QueryBuilder<TableModel, TableModel, QFilterCondition> {
  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition>
      isAvailableEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAvailable',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> maxUsersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maxUsers',
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition>
      maxUsersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maxUsers',
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> maxUsersEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxUsers',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition>
      maxUsersGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxUsers',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> maxUsersLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxUsers',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> maxUsersBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxUsers',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition>
      pricePerHourEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pricePerHour',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition>
      pricePerHourGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pricePerHour',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition>
      pricePerHourLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pricePerHour',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition>
      pricePerHourBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pricePerHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition>
      pricePerMinuteEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pricePerMinute',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition>
      pricePerMinuteGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pricePerMinute',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition>
      pricePerMinuteLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pricePerMinute',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition>
      pricePerMinuteBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pricePerMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> statusEqualTo(
      TableStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> statusGreaterThan(
    TableStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> statusLessThan(
    TableStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterFilterCondition> statusBetween(
    TableStatus lower,
    TableStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TableModelQueryObject
    on QueryBuilder<TableModel, TableModel, QFilterCondition> {}

extension TableModelQueryLinks
    on QueryBuilder<TableModel, TableModel, QFilterCondition> {}

extension TableModelQuerySortBy
    on QueryBuilder<TableModel, TableModel, QSortBy> {
  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByIsAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAvailable', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByIsAvailableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAvailable', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByMaxUsers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxUsers', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByMaxUsersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxUsers', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByPricePerHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerHour', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByPricePerHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerHour', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByPricePerMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerMinute', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy>
      sortByPricePerMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerMinute', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension TableModelQuerySortThenBy
    on QueryBuilder<TableModel, TableModel, QSortThenBy> {
  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByIsAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAvailable', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByIsAvailableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAvailable', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByMaxUsers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxUsers', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByMaxUsersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxUsers', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByPricePerHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerHour', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByPricePerHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerHour', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByPricePerMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerMinute', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy>
      thenByPricePerMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerMinute', Sort.desc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TableModel, TableModel, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension TableModelQueryWhereDistinct
    on QueryBuilder<TableModel, TableModel, QDistinct> {
  QueryBuilder<TableModel, TableModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TableModel, TableModel, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<TableModel, TableModel, QDistinct> distinctByIsAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAvailable');
    });
  }

  QueryBuilder<TableModel, TableModel, QDistinct> distinctByMaxUsers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxUsers');
    });
  }

  QueryBuilder<TableModel, TableModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TableModel, TableModel, QDistinct> distinctByPricePerHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pricePerHour');
    });
  }

  QueryBuilder<TableModel, TableModel, QDistinct> distinctByPricePerMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pricePerMinute');
    });
  }

  QueryBuilder<TableModel, TableModel, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }
}

extension TableModelQueryProperty
    on QueryBuilder<TableModel, TableModel, QQueryProperty> {
  QueryBuilder<TableModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TableModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TableModel, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<TableModel, bool, QQueryOperations> isAvailableProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAvailable');
    });
  }

  QueryBuilder<TableModel, int?, QQueryOperations> maxUsersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxUsers');
    });
  }

  QueryBuilder<TableModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<TableModel, double, QQueryOperations> pricePerHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pricePerHour');
    });
  }

  QueryBuilder<TableModel, double, QQueryOperations> pricePerMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pricePerMinute');
    });
  }

  QueryBuilder<TableModel, TableStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
