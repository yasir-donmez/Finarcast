// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_goal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFinancialGoalCollection on Isar {
  IsarCollection<FinancialGoal> get financialGoals => this.collection();
}

const FinancialGoalSchema = CollectionSchema(
  name: r'FinancialGoal',
  id: -4634083842245294579,
  properties: {
    r'aiPersonaText': PropertySchema(
      id: 0,
      name: r'aiPersonaText',
      type: IsarType.string,
    ),
    r'aiStrategyText': PropertySchema(
      id: 1,
      name: r'aiStrategyText',
      type: IsarType.string,
    ),
    r'analysisRawData': PropertySchema(
      id: 2,
      name: r'analysisRawData',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currencySymbol': PropertySchema(
      id: 4,
      name: r'currencySymbol',
      type: IsarType.string,
    ),
    r'rejectedCategories': PropertySchema(
      id: 5,
      name: r'rejectedCategories',
      type: IsarType.stringList,
    ),
    r'remoteId': PropertySchema(
      id: 6,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 7,
      name: r'syncStatus',
      type: IsarType.long,
    ),
    r'targetAmount': PropertySchema(
      id: 8,
      name: r'targetAmount',
      type: IsarType.double,
    ),
    r'targetDate': PropertySchema(
      id: 9,
      name: r'targetDate',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userApproved': PropertySchema(
      id: 11,
      name: r'userApproved',
      type: IsarType.bool,
    ),
    r'vaultId': PropertySchema(
      id: 12,
      name: r'vaultId',
      type: IsarType.long,
    )
  },
  estimateSize: _financialGoalEstimateSize,
  serialize: _financialGoalSerialize,
  deserialize: _financialGoalDeserialize,
  deserializeProp: _financialGoalDeserializeProp,
  idName: r'id',
  indexes: {
    r'remoteId': IndexSchema(
      id: 6301175856541681032,
      name: r'remoteId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'remoteId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'syncStatus': IndexSchema(
      id: 8239539375045684509,
      name: r'syncStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'syncStatus',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _financialGoalGetId,
  getLinks: _financialGoalGetLinks,
  attach: _financialGoalAttach,
  version: '3.1.0+1',
);

int _financialGoalEstimateSize(
  FinancialGoal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aiPersonaText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.aiStrategyText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.analysisRawData;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.currencySymbol.length * 3;
  bytesCount += 3 + object.rejectedCategories.length * 3;
  {
    for (var i = 0; i < object.rejectedCategories.length; i++) {
      final value = object.rejectedCategories[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.remoteId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _financialGoalSerialize(
  FinancialGoal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiPersonaText);
  writer.writeString(offsets[1], object.aiStrategyText);
  writer.writeString(offsets[2], object.analysisRawData);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeString(offsets[4], object.currencySymbol);
  writer.writeStringList(offsets[5], object.rejectedCategories);
  writer.writeString(offsets[6], object.remoteId);
  writer.writeLong(offsets[7], object.syncStatus);
  writer.writeDouble(offsets[8], object.targetAmount);
  writer.writeDateTime(offsets[9], object.targetDate);
  writer.writeDateTime(offsets[10], object.updatedAt);
  writer.writeBool(offsets[11], object.userApproved);
  writer.writeLong(offsets[12], object.vaultId);
}

FinancialGoal _financialGoalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FinancialGoal();
  object.aiPersonaText = reader.readStringOrNull(offsets[0]);
  object.aiStrategyText = reader.readStringOrNull(offsets[1]);
  object.analysisRawData = reader.readStringOrNull(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.currencySymbol = reader.readString(offsets[4]);
  object.id = id;
  object.rejectedCategories = reader.readStringList(offsets[5]) ?? [];
  object.remoteId = reader.readStringOrNull(offsets[6]);
  object.syncStatus = reader.readLong(offsets[7]);
  object.targetAmount = reader.readDouble(offsets[8]);
  object.targetDate = reader.readDateTimeOrNull(offsets[9]);
  object.updatedAt = reader.readDateTime(offsets[10]);
  object.userApproved = reader.readBoolOrNull(offsets[11]);
  object.vaultId = reader.readLongOrNull(offsets[12]);
  return object;
}

P _financialGoalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readBoolOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _financialGoalGetId(FinancialGoal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _financialGoalGetLinks(FinancialGoal object) {
  return [];
}

void _financialGoalAttach(
    IsarCollection<dynamic> col, Id id, FinancialGoal object) {
  object.id = id;
}

extension FinancialGoalQueryWhereSort
    on QueryBuilder<FinancialGoal, FinancialGoal, QWhere> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhere> anySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'syncStatus'),
      );
    });
  }
}

extension FinancialGoalQueryWhere
    on QueryBuilder<FinancialGoal, FinancialGoal, QWhereClause> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause> idBetween(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause>
      remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'remoteId',
        value: [null],
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause>
      remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'remoteId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause> remoteIdEqualTo(
      String? remoteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'remoteId',
        value: [remoteId],
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause>
      remoteIdNotEqualTo(String? remoteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteId',
              lower: [],
              upper: [remoteId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteId',
              lower: [remoteId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteId',
              lower: [remoteId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteId',
              lower: [],
              upper: [remoteId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause>
      updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause>
      updatedAtNotEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause>
      updatedAtGreaterThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [updatedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause>
      updatedAtLessThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [],
        upper: [updatedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause>
      updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [lowerUpdatedAt],
        includeLower: includeLower,
        upper: [upperUpdatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause>
      syncStatusEqualTo(int syncStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncStatus',
        value: [syncStatus],
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause>
      syncStatusNotEqualTo(int syncStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [],
              upper: [syncStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [syncStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [syncStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [],
              upper: [syncStatus],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause>
      syncStatusGreaterThan(
    int syncStatus, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'syncStatus',
        lower: [syncStatus],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause>
      syncStatusLessThan(
    int syncStatus, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'syncStatus',
        lower: [],
        upper: [syncStatus],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause>
      syncStatusBetween(
    int lowerSyncStatus,
    int upperSyncStatus, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'syncStatus',
        lower: [lowerSyncStatus],
        includeLower: includeLower,
        upper: [upperSyncStatus],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FinancialGoalQueryFilter
    on QueryBuilder<FinancialGoal, FinancialGoal, QFilterCondition> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiPersonaTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiPersonaText',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiPersonaTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiPersonaText',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiPersonaTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiPersonaText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiPersonaTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiPersonaText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiPersonaTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiPersonaText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiPersonaTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiPersonaText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiPersonaTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiPersonaText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiPersonaTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiPersonaText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiPersonaTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiPersonaText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiPersonaTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiPersonaText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiPersonaTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiPersonaText',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiPersonaTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiPersonaText',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiStrategyTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiStrategyText',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiStrategyTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiStrategyText',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiStrategyTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiStrategyText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiStrategyTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiStrategyText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiStrategyTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiStrategyText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiStrategyTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiStrategyText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiStrategyTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiStrategyText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiStrategyTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiStrategyText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiStrategyTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiStrategyText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiStrategyTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiStrategyText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiStrategyTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiStrategyText',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      aiStrategyTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiStrategyText',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      analysisRawDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'analysisRawData',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      analysisRawDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'analysisRawData',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      analysisRawDataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'analysisRawData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      analysisRawDataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'analysisRawData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      analysisRawDataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'analysisRawData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      analysisRawDataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'analysisRawData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      analysisRawDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'analysisRawData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      analysisRawDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'analysisRawData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      analysisRawDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'analysisRawData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      analysisRawDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'analysisRawData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      analysisRawDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'analysisRawData',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      analysisRawDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'analysisRawData',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currencySymbolEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currencySymbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currencySymbolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currencySymbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currencySymbolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currencySymbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currencySymbolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currencySymbol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currencySymbolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currencySymbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currencySymbolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currencySymbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currencySymbolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currencySymbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currencySymbolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currencySymbol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currencySymbolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currencySymbol',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currencySymbolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currencySymbol',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectedCategories',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rejectedCategories',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rejectedCategories',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rejectedCategories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rejectedCategories',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rejectedCategories',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rejectedCategories',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rejectedCategories',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectedCategories',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rejectedCategories',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rejectedCategories',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rejectedCategories',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rejectedCategories',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rejectedCategories',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rejectedCategories',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      rejectedCategoriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rejectedCategories',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      remoteIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      remoteIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      remoteIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      remoteIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remoteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      remoteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      remoteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      remoteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      remoteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remoteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      syncStatusEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      syncStatusGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      syncStatusLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      syncStatusBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetDate',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetDate',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      userApprovedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userApproved',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      userApprovedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userApproved',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      userApprovedEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userApproved',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      vaultIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'vaultId',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      vaultIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'vaultId',
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      vaultIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vaultId',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      vaultIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vaultId',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      vaultIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vaultId',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      vaultIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vaultId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FinancialGoalQueryObject
    on QueryBuilder<FinancialGoal, FinancialGoal, QFilterCondition> {}

extension FinancialGoalQueryLinks
    on QueryBuilder<FinancialGoal, FinancialGoal, QFilterCondition> {}

extension FinancialGoalQuerySortBy
    on QueryBuilder<FinancialGoal, FinancialGoal, QSortBy> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByAiPersonaText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiPersonaText', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByAiPersonaTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiPersonaText', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByAiStrategyText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiStrategyText', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByAiStrategyTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiStrategyText', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByAnalysisRawData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analysisRawData', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByAnalysisRawDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analysisRawData', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByCurrencySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySymbol', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByCurrencySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySymbol', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByUserApproved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userApproved', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByUserApprovedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userApproved', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultId', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByVaultIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultId', Sort.desc);
    });
  }
}

extension FinancialGoalQuerySortThenBy
    on QueryBuilder<FinancialGoal, FinancialGoal, QSortThenBy> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByAiPersonaText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiPersonaText', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByAiPersonaTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiPersonaText', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByAiStrategyText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiStrategyText', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByAiStrategyTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiStrategyText', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByAnalysisRawData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analysisRawData', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByAnalysisRawDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analysisRawData', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByCurrencySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySymbol', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByCurrencySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySymbol', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByUserApproved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userApproved', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByUserApprovedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userApproved', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultId', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByVaultIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultId', Sort.desc);
    });
  }
}

extension FinancialGoalQueryWhereDistinct
    on QueryBuilder<FinancialGoal, FinancialGoal, QDistinct> {
  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct> distinctByAiPersonaText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiPersonaText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct>
      distinctByAiStrategyText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiStrategyText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct>
      distinctByAnalysisRawData({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'analysisRawData',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct>
      distinctByCurrencySymbol({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currencySymbol',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct>
      distinctByRejectedCategories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rejectedCategories');
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct> distinctByRemoteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct> distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct>
      distinctByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetAmount');
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct> distinctByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetDate');
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct>
      distinctByUserApproved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userApproved');
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct> distinctByVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vaultId');
    });
  }
}

extension FinancialGoalQueryProperty
    on QueryBuilder<FinancialGoal, FinancialGoal, QQueryProperty> {
  QueryBuilder<FinancialGoal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FinancialGoal, String?, QQueryOperations>
      aiPersonaTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiPersonaText');
    });
  }

  QueryBuilder<FinancialGoal, String?, QQueryOperations>
      aiStrategyTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiStrategyText');
    });
  }

  QueryBuilder<FinancialGoal, String?, QQueryOperations>
      analysisRawDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'analysisRawData');
    });
  }

  QueryBuilder<FinancialGoal, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<FinancialGoal, String, QQueryOperations>
      currencySymbolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencySymbol');
    });
  }

  QueryBuilder<FinancialGoal, List<String>, QQueryOperations>
      rejectedCategoriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rejectedCategories');
    });
  }

  QueryBuilder<FinancialGoal, String?, QQueryOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<FinancialGoal, int, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<FinancialGoal, double, QQueryOperations> targetAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetAmount');
    });
  }

  QueryBuilder<FinancialGoal, DateTime?, QQueryOperations>
      targetDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetDate');
    });
  }

  QueryBuilder<FinancialGoal, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<FinancialGoal, bool?, QQueryOperations> userApprovedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userApproved');
    });
  }

  QueryBuilder<FinancialGoal, int?, QQueryOperations> vaultIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vaultId');
    });
  }
}
