// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_session_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlayerSessionModelCollection on Isar {
  IsarCollection<PlayerSessionModel> get playerSessionModels =>
      this.collection();
}

const PlayerSessionModelSchema = CollectionSchema(
  name: r'PlayerSessionModel',
  id: 8193372508360206221,
  properties: {
    r'accumulatedCost': PropertySchema(
      id: 0,
      name: r'accumulatedCost',
      type: IsarType.double,
    ),
    r'customerId': PropertySchema(
      id: 1,
      name: r'customerId',
      type: IsarType.long,
    ),
    r'deviceName': PropertySchema(
      id: 2,
      name: r'deviceName',
      type: IsarType.string,
    ),
    r'discountPercentage': PropertySchema(
      id: 3,
      name: r'discountPercentage',
      type: IsarType.double,
    ),
    r'endTime': PropertySchema(
      id: 4,
      name: r'endTime',
      type: IsarType.dateTime,
    ),
    r'isActive': PropertySchema(
      id: 5,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isFinished': PropertySchema(
      id: 6,
      name: r'isFinished',
      type: IsarType.bool,
    ),
    r'lastCheckpointTime': PropertySchema(
      id: 7,
      name: r'lastCheckpointTime',
      type: IsarType.dateTime,
    ),
    r'playerName': PropertySchema(
      id: 8,
      name: r'playerName',
      type: IsarType.string,
    ),
    r'reminderMinutes': PropertySchema(
      id: 9,
      name: r'reminderMinutes',
      type: IsarType.long,
    ),
    r'sessionCode': PropertySchema(
      id: 10,
      name: r'sessionCode',
      type: IsarType.string,
    ),
    r'startTime': PropertySchema(
      id: 11,
      name: r'startTime',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 12,
      name: r'status',
      type: IsarType.byte,
      enumMap: _PlayerSessionModelstatusEnumValueMap,
    ),
    r'tableId': PropertySchema(
      id: 13,
      name: r'tableId',
      type: IsarType.long,
    ),
    r'totalPrice': PropertySchema(
      id: 14,
      name: r'totalPrice',
      type: IsarType.double,
    )
  },
  estimateSize: _playerSessionModelEstimateSize,
  serialize: _playerSessionModelSerialize,
  deserialize: _playerSessionModelDeserialize,
  deserializeProp: _playerSessionModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'tableId': IndexSchema(
      id: 519297262500120396,
      name: r'tableId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tableId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'sessionCode': IndexSchema(
      id: -3310930481242467997,
      name: r'sessionCode',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _playerSessionModelGetId,
  getLinks: _playerSessionModelGetLinks,
  attach: _playerSessionModelAttach,
  version: '3.1.0+1',
);

int _playerSessionModelEstimateSize(
  PlayerSessionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.deviceName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.playerName.length * 3;
  bytesCount += 3 + object.sessionCode.length * 3;
  return bytesCount;
}

void _playerSessionModelSerialize(
  PlayerSessionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accumulatedCost);
  writer.writeLong(offsets[1], object.customerId);
  writer.writeString(offsets[2], object.deviceName);
  writer.writeDouble(offsets[3], object.discountPercentage);
  writer.writeDateTime(offsets[4], object.endTime);
  writer.writeBool(offsets[5], object.isActive);
  writer.writeBool(offsets[6], object.isFinished);
  writer.writeDateTime(offsets[7], object.lastCheckpointTime);
  writer.writeString(offsets[8], object.playerName);
  writer.writeLong(offsets[9], object.reminderMinutes);
  writer.writeString(offsets[10], object.sessionCode);
  writer.writeDateTime(offsets[11], object.startTime);
  writer.writeByte(offsets[12], object.status.index);
  writer.writeLong(offsets[13], object.tableId);
  writer.writeDouble(offsets[14], object.totalPrice);
}

PlayerSessionModel _playerSessionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlayerSessionModel();
  object.accumulatedCost = reader.readDouble(offsets[0]);
  object.customerId = reader.readLongOrNull(offsets[1]);
  object.deviceName = reader.readStringOrNull(offsets[2]);
  object.discountPercentage = reader.readDouble(offsets[3]);
  object.endTime = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.lastCheckpointTime = reader.readDateTime(offsets[7]);
  object.playerName = reader.readString(offsets[8]);
  object.reminderMinutes = reader.readLongOrNull(offsets[9]);
  object.sessionCode = reader.readString(offsets[10]);
  object.startTime = reader.readDateTime(offsets[11]);
  object.status = _PlayerSessionModelstatusValueEnumMap[
          reader.readByteOrNull(offsets[12])] ??
      SessionStatus.active;
  object.tableId = reader.readLong(offsets[13]);
  object.totalPrice = reader.readDouble(offsets[14]);
  return object;
}

P _playerSessionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (_PlayerSessionModelstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SessionStatus.active) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PlayerSessionModelstatusEnumValueMap = {
  'active': 0,
  'finished': 1,
};
const _PlayerSessionModelstatusValueEnumMap = {
  0: SessionStatus.active,
  1: SessionStatus.finished,
};

Id _playerSessionModelGetId(PlayerSessionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playerSessionModelGetLinks(
    PlayerSessionModel object) {
  return [];
}

void _playerSessionModelAttach(
    IsarCollection<dynamic> col, Id id, PlayerSessionModel object) {
  object.id = id;
}

extension PlayerSessionModelByIndex on IsarCollection<PlayerSessionModel> {
  Future<PlayerSessionModel?> getBySessionCode(String sessionCode) {
    return getByIndex(r'sessionCode', [sessionCode]);
  }

  PlayerSessionModel? getBySessionCodeSync(String sessionCode) {
    return getByIndexSync(r'sessionCode', [sessionCode]);
  }

  Future<bool> deleteBySessionCode(String sessionCode) {
    return deleteByIndex(r'sessionCode', [sessionCode]);
  }

  bool deleteBySessionCodeSync(String sessionCode) {
    return deleteByIndexSync(r'sessionCode', [sessionCode]);
  }

  Future<List<PlayerSessionModel?>> getAllBySessionCode(
      List<String> sessionCodeValues) {
    final values = sessionCodeValues.map((e) => [e]).toList();
    return getAllByIndex(r'sessionCode', values);
  }

  List<PlayerSessionModel?> getAllBySessionCodeSync(
      List<String> sessionCodeValues) {
    final values = sessionCodeValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sessionCode', values);
  }

  Future<int> deleteAllBySessionCode(List<String> sessionCodeValues) {
    final values = sessionCodeValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sessionCode', values);
  }

  int deleteAllBySessionCodeSync(List<String> sessionCodeValues) {
    final values = sessionCodeValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sessionCode', values);
  }

  Future<Id> putBySessionCode(PlayerSessionModel object) {
    return putByIndex(r'sessionCode', object);
  }

  Id putBySessionCodeSync(PlayerSessionModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'sessionCode', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySessionCode(List<PlayerSessionModel> objects) {
    return putAllByIndex(r'sessionCode', objects);
  }

  List<Id> putAllBySessionCodeSync(List<PlayerSessionModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'sessionCode', objects, saveLinks: saveLinks);
  }
}

extension PlayerSessionModelQueryWhereSort
    on QueryBuilder<PlayerSessionModel, PlayerSessionModel, QWhere> {
  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhere>
      anyTableId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'tableId'),
      );
    });
  }
}

extension PlayerSessionModelQueryWhere
    on QueryBuilder<PlayerSessionModel, PlayerSessionModel, QWhereClause> {
  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhereClause>
      tableIdEqualTo(int tableId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tableId',
        value: [tableId],
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhereClause>
      tableIdNotEqualTo(int tableId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tableId',
              lower: [],
              upper: [tableId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tableId',
              lower: [tableId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tableId',
              lower: [tableId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tableId',
              lower: [],
              upper: [tableId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhereClause>
      tableIdGreaterThan(
    int tableId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tableId',
        lower: [tableId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhereClause>
      tableIdLessThan(
    int tableId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tableId',
        lower: [],
        upper: [tableId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhereClause>
      tableIdBetween(
    int lowerTableId,
    int upperTableId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tableId',
        lower: [lowerTableId],
        includeLower: includeLower,
        upper: [upperTableId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhereClause>
      sessionCodeEqualTo(String sessionCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionCode',
        value: [sessionCode],
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterWhereClause>
      sessionCodeNotEqualTo(String sessionCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionCode',
              lower: [],
              upper: [sessionCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionCode',
              lower: [sessionCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionCode',
              lower: [sessionCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionCode',
              lower: [],
              upper: [sessionCode],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PlayerSessionModelQueryFilter
    on QueryBuilder<PlayerSessionModel, PlayerSessionModel, QFilterCondition> {
  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      accumulatedCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accumulatedCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      accumulatedCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accumulatedCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      accumulatedCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accumulatedCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      accumulatedCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accumulatedCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      customerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'customerId',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      customerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'customerId',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      customerIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customerId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      customerIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customerId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      customerIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customerId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      customerIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      deviceNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deviceName',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      deviceNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deviceName',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      deviceNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      deviceNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      deviceNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      deviceNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      deviceNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      deviceNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      deviceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      deviceNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      deviceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      deviceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      discountPercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      discountPercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      discountPercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      discountPercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discountPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      endTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      endTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      endTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      endTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      endTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      isFinishedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFinished',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      lastCheckpointTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCheckpointTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      lastCheckpointTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCheckpointTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      lastCheckpointTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCheckpointTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      lastCheckpointTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCheckpointTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      playerNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      playerNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      playerNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      playerNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playerName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      playerNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      playerNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      playerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      playerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      playerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      playerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playerName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      reminderMinutesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reminderMinutes',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      reminderMinutesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reminderMinutes',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      reminderMinutesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      reminderMinutesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      reminderMinutesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      reminderMinutesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      sessionCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      sessionCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      sessionCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      sessionCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      sessionCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sessionCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      sessionCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sessionCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      sessionCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      sessionCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      sessionCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionCode',
        value: '',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      sessionCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionCode',
        value: '',
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      startTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      statusEqualTo(SessionStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      statusGreaterThan(
    SessionStatus value, {
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

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      statusLessThan(
    SessionStatus value, {
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

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      statusBetween(
    SessionStatus lower,
    SessionStatus upper, {
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

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      tableIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tableId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      tableIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tableId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      tableIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tableId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      tableIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tableId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      totalPriceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      totalPriceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      totalPriceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterFilterCondition>
      totalPriceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension PlayerSessionModelQueryObject
    on QueryBuilder<PlayerSessionModel, PlayerSessionModel, QFilterCondition> {}

extension PlayerSessionModelQueryLinks
    on QueryBuilder<PlayerSessionModel, PlayerSessionModel, QFilterCondition> {}

extension PlayerSessionModelQuerySortBy
    on QueryBuilder<PlayerSessionModel, PlayerSessionModel, QSortBy> {
  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByAccumulatedCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accumulatedCost', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByAccumulatedCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accumulatedCost', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByCustomerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerId', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByCustomerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerId', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountPercentage', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByDiscountPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountPercentage', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByIsFinished() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinished', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByIsFinishedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinished', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByLastCheckpointTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckpointTime', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByLastCheckpointTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckpointTime', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByPlayerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerName', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByPlayerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerName', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByReminderMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinutes', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByReminderMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinutes', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortBySessionCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionCode', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortBySessionCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionCode', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByTableId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tableId', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByTableIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tableId', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByTotalPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      sortByTotalPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.desc);
    });
  }
}

extension PlayerSessionModelQuerySortThenBy
    on QueryBuilder<PlayerSessionModel, PlayerSessionModel, QSortThenBy> {
  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByAccumulatedCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accumulatedCost', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByAccumulatedCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accumulatedCost', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByCustomerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerId', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByCustomerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerId', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountPercentage', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByDiscountPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountPercentage', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByIsFinished() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinished', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByIsFinishedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinished', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByLastCheckpointTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckpointTime', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByLastCheckpointTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckpointTime', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByPlayerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerName', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByPlayerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerName', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByReminderMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinutes', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByReminderMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinutes', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenBySessionCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionCode', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenBySessionCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionCode', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByTableId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tableId', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByTableIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tableId', Sort.desc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByTotalPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.asc);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QAfterSortBy>
      thenByTotalPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.desc);
    });
  }
}

extension PlayerSessionModelQueryWhereDistinct
    on QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct> {
  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByAccumulatedCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accumulatedCost');
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByCustomerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customerId');
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByDeviceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discountPercentage');
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByIsFinished() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFinished');
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByLastCheckpointTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCheckpointTime');
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByPlayerName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByReminderMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderMinutes');
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctBySessionCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByTableId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tableId');
    });
  }

  QueryBuilder<PlayerSessionModel, PlayerSessionModel, QDistinct>
      distinctByTotalPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPrice');
    });
  }
}

extension PlayerSessionModelQueryProperty
    on QueryBuilder<PlayerSessionModel, PlayerSessionModel, QQueryProperty> {
  QueryBuilder<PlayerSessionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlayerSessionModel, double, QQueryOperations>
      accumulatedCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accumulatedCost');
    });
  }

  QueryBuilder<PlayerSessionModel, int?, QQueryOperations>
      customerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customerId');
    });
  }

  QueryBuilder<PlayerSessionModel, String?, QQueryOperations>
      deviceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceName');
    });
  }

  QueryBuilder<PlayerSessionModel, double, QQueryOperations>
      discountPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discountPercentage');
    });
  }

  QueryBuilder<PlayerSessionModel, DateTime?, QQueryOperations>
      endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<PlayerSessionModel, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<PlayerSessionModel, bool, QQueryOperations>
      isFinishedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFinished');
    });
  }

  QueryBuilder<PlayerSessionModel, DateTime, QQueryOperations>
      lastCheckpointTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCheckpointTime');
    });
  }

  QueryBuilder<PlayerSessionModel, String, QQueryOperations>
      playerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playerName');
    });
  }

  QueryBuilder<PlayerSessionModel, int?, QQueryOperations>
      reminderMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderMinutes');
    });
  }

  QueryBuilder<PlayerSessionModel, String, QQueryOperations>
      sessionCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionCode');
    });
  }

  QueryBuilder<PlayerSessionModel, DateTime, QQueryOperations>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }

  QueryBuilder<PlayerSessionModel, SessionStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PlayerSessionModel, int, QQueryOperations> tableIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tableId');
    });
  }

  QueryBuilder<PlayerSessionModel, double, QQueryOperations>
      totalPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPrice');
    });
  }
}
