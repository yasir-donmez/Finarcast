// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_template.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecurringTemplateCollection on Isar {
  IsarCollection<RecurringTemplate> get recurringTemplates => this.collection();
}

const RecurringTemplateSchema = CollectionSchema(
  name: r'RecurringTemplate',
  id: 9077164383914161837,
  properties: {
    r'amount': PropertySchema(id: 0, name: r'amount', type: IsarType.double),
    r'categoryId': PropertySchema(
      id: 1,
      name: r'categoryId',
      type: IsarType.string,
    ),
    r'currency': PropertySchema(
      id: 2,
      name: r'currency',
      type: IsarType.string,
    ),
    r'hasNotification': PropertySchema(
      id: 3,
      name: r'hasNotification',
      type: IsarType.bool,
    ),
    r'iconCode': PropertySchema(
      id: 4,
      name: r'iconCode',
      type: IsarType.string,
    ),
    r'isArchived': PropertySchema(
      id: 5,
      name: r'isArchived',
      type: IsarType.bool,
    ),
    r'isIncome': PropertySchema(id: 6, name: r'isIncome', type: IsarType.bool),
    r'isNotificationEnabled': PropertySchema(
      id: 7,
      name: r'isNotificationEnabled',
      type: IsarType.bool,
    ),
    r'isPaused': PropertySchema(id: 8, name: r'isPaused', type: IsarType.bool),
    r'maxAmount': PropertySchema(
      id: 9,
      name: r'maxAmount',
      type: IsarType.double,
    ),
    r'minAmount': PropertySchema(
      id: 10,
      name: r'minAmount',
      type: IsarType.double,
    ),
    r'note': PropertySchema(id: 11, name: r'note', type: IsarType.string),
    r'notificationHour': PropertySchema(
      id: 12,
      name: r'notificationHour',
      type: IsarType.long,
    ),
    r'notificationMinute': PropertySchema(
      id: 13,
      name: r'notificationMinute',
      type: IsarType.long,
    ),
    r'notificationReminderDays': PropertySchema(
      id: 14,
      name: r'notificationReminderDays',
      type: IsarType.long,
    ),
    r'periodType': PropertySchema(
      id: 15,
      name: r'periodType',
      type: IsarType.long,
    ),
    r'recurrenceDate': PropertySchema(
      id: 16,
      name: r'recurrenceDate',
      type: IsarType.dateTime,
    ),
    r'recurrenceDay': PropertySchema(
      id: 17,
      name: r'recurrenceDay',
      type: IsarType.long,
    ),
    r'remoteId': PropertySchema(
      id: 18,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'startDate': PropertySchema(
      id: 19,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'syncStatus': PropertySchema(
      id: 20,
      name: r'syncStatus',
      type: IsarType.long,
    ),
    r'title': PropertySchema(id: 21, name: r'title', type: IsarType.string),
    r'totalInstallments': PropertySchema(
      id: 22,
      name: r'totalInstallments',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 23,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'vaultId': PropertySchema(id: 24, name: r'vaultId', type: IsarType.long),
  },

  estimateSize: _recurringTemplateEstimateSize,
  serialize: _recurringTemplateSerialize,
  deserialize: _recurringTemplateDeserialize,
  deserializeProp: _recurringTemplateDeserializeProp,
  idName: r'id',
  indexes: {
    r'vaultId': IndexSchema(
      id: -1162152712452118160,
      name: r'vaultId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'vaultId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
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
        ),
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
        ),
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
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _recurringTemplateGetId,
  getLinks: _recurringTemplateGetLinks,
  attach: _recurringTemplateAttach,
  version: '3.3.2',
);

int _recurringTemplateEstimateSize(
  RecurringTemplate object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.categoryId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currency;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.iconCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.remoteId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _recurringTemplateSerialize(
  RecurringTemplate object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeString(offsets[1], object.categoryId);
  writer.writeString(offsets[2], object.currency);
  writer.writeBool(offsets[3], object.hasNotification);
  writer.writeString(offsets[4], object.iconCode);
  writer.writeBool(offsets[5], object.isArchived);
  writer.writeBool(offsets[6], object.isIncome);
  writer.writeBool(offsets[7], object.isNotificationEnabled);
  writer.writeBool(offsets[8], object.isPaused);
  writer.writeDouble(offsets[9], object.maxAmount);
  writer.writeDouble(offsets[10], object.minAmount);
  writer.writeString(offsets[11], object.note);
  writer.writeLong(offsets[12], object.notificationHour);
  writer.writeLong(offsets[13], object.notificationMinute);
  writer.writeLong(offsets[14], object.notificationReminderDays);
  writer.writeLong(offsets[15], object.periodType);
  writer.writeDateTime(offsets[16], object.recurrenceDate);
  writer.writeLong(offsets[17], object.recurrenceDay);
  writer.writeString(offsets[18], object.remoteId);
  writer.writeDateTime(offsets[19], object.startDate);
  writer.writeLong(offsets[20], object.syncStatus);
  writer.writeString(offsets[21], object.title);
  writer.writeLong(offsets[22], object.totalInstallments);
  writer.writeDateTime(offsets[23], object.updatedAt);
  writer.writeLong(offsets[24], object.vaultId);
}

RecurringTemplate _recurringTemplateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecurringTemplate();
  object.amount = reader.readDouble(offsets[0]);
  object.categoryId = reader.readStringOrNull(offsets[1]);
  object.currency = reader.readStringOrNull(offsets[2]);
  object.hasNotification = reader.readBool(offsets[3]);
  object.iconCode = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.isArchived = reader.readBool(offsets[5]);
  object.isIncome = reader.readBool(offsets[6]);
  object.isNotificationEnabled = reader.readBool(offsets[7]);
  object.isPaused = reader.readBool(offsets[8]);
  object.maxAmount = reader.readDoubleOrNull(offsets[9]);
  object.minAmount = reader.readDoubleOrNull(offsets[10]);
  object.note = reader.readStringOrNull(offsets[11]);
  object.notificationHour = reader.readLong(offsets[12]);
  object.notificationMinute = reader.readLong(offsets[13]);
  object.notificationReminderDays = reader.readLong(offsets[14]);
  object.periodType = reader.readLong(offsets[15]);
  object.recurrenceDate = reader.readDateTimeOrNull(offsets[16]);
  object.recurrenceDay = reader.readLongOrNull(offsets[17]);
  object.remoteId = reader.readStringOrNull(offsets[18]);
  object.startDate = reader.readDateTime(offsets[19]);
  object.syncStatus = reader.readLong(offsets[20]);
  object.title = reader.readString(offsets[21]);
  object.totalInstallments = reader.readLongOrNull(offsets[22]);
  object.updatedAt = reader.readDateTime(offsets[23]);
  object.vaultId = reader.readLongOrNull(offsets[24]);
  return object;
}

P _recurringTemplateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readDateTime(offset)) as P;
    case 20:
      return (reader.readLong(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readLongOrNull(offset)) as P;
    case 23:
      return (reader.readDateTime(offset)) as P;
    case 24:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _recurringTemplateGetId(RecurringTemplate object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recurringTemplateGetLinks(
  RecurringTemplate object,
) {
  return [];
}

void _recurringTemplateAttach(
  IsarCollection<dynamic> col,
  Id id,
  RecurringTemplate object,
) {
  object.id = id;
}

extension RecurringTemplateQueryWhereSort
    on QueryBuilder<RecurringTemplate, RecurringTemplate, QWhere> {
  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhere> anyVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'vaultId'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhere>
  anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhere>
  anySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'syncStatus'),
      );
    });
  }
}

extension RecurringTemplateQueryWhere
    on QueryBuilder<RecurringTemplate, RecurringTemplate, QWhereClause> {
  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
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

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  vaultIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'vaultId', value: [null]),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  vaultIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'vaultId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  vaultIdEqualTo(int? vaultId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'vaultId', value: [vaultId]),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  vaultIdNotEqualTo(int? vaultId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'vaultId',
                lower: [],
                upper: [vaultId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'vaultId',
                lower: [vaultId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'vaultId',
                lower: [vaultId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'vaultId',
                lower: [],
                upper: [vaultId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  vaultIdGreaterThan(int? vaultId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'vaultId',
          lower: [vaultId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  vaultIdLessThan(int? vaultId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'vaultId',
          lower: [],
          upper: [vaultId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  vaultIdBetween(
    int? lowerVaultId,
    int? upperVaultId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'vaultId',
          lower: [lowerVaultId],
          includeLower: includeLower,
          upper: [upperVaultId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'remoteId', value: [null]),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'remoteId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  remoteIdEqualTo(String? remoteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'remoteId', value: [remoteId]),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  remoteIdNotEqualTo(String? remoteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [],
                upper: [remoteId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [remoteId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [remoteId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [],
                upper: [remoteId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'updatedAt', value: [updatedAt]),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  updatedAtNotEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  updatedAtGreaterThan(DateTime updatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [updatedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  updatedAtLessThan(DateTime updatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [],
          upper: [updatedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [lowerUpdatedAt],
          includeLower: includeLower,
          upper: [upperUpdatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  syncStatusEqualTo(int syncStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'syncStatus', value: [syncStatus]),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  syncStatusNotEqualTo(int syncStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncStatus',
                lower: [],
                upper: [syncStatus],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncStatus',
                lower: [syncStatus],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncStatus',
                lower: [syncStatus],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncStatus',
                lower: [],
                upper: [syncStatus],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  syncStatusGreaterThan(int syncStatus, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'syncStatus',
          lower: [syncStatus],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  syncStatusLessThan(int syncStatus, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'syncStatus',
          lower: [],
          upper: [syncStatus],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterWhereClause>
  syncStatusBetween(
    int lowerSyncStatus,
    int upperSyncStatus, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'syncStatus',
          lower: [lowerSyncStatus],
          includeLower: includeLower,
          upper: [upperSyncStatus],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RecurringTemplateQueryFilter
    on QueryBuilder<RecurringTemplate, RecurringTemplate, QFilterCondition> {
  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  amountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  categoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'categoryId'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  categoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'categoryId'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  categoryIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  categoryIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  categoryIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  categoryIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'categoryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  categoryIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  categoryIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  categoryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  categoryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'categoryId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  categoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  categoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  currencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currency'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  currencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currency'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  currencyEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  currencyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  currencyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  currencyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currency',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  currencyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  currencyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currency',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currency', value: ''),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currency', value: ''),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  hasNotificationEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasNotification', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  iconCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'iconCode'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  iconCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'iconCode'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  iconCodeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'iconCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  iconCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'iconCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  iconCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'iconCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  iconCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'iconCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  iconCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'iconCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  iconCodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'iconCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  iconCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'iconCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  iconCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'iconCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  iconCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'iconCode', value: ''),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  iconCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'iconCode', value: ''),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  isArchivedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isArchived', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  isIncomeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isIncome', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  isNotificationEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isNotificationEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  isPausedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isPaused', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  maxAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'maxAmount'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  maxAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'maxAmount'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  maxAmountEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'maxAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  maxAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maxAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  maxAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maxAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  maxAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maxAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  minAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'minAmount'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  minAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'minAmount'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  minAmountEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'minAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  minAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'minAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  minAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'minAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  minAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'minAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'note'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'note'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  noteEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  noteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  noteEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  notificationHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notificationHour', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  notificationHourGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notificationHour',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  notificationHourLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notificationHour',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  notificationHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notificationHour',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  notificationMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notificationMinute', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  notificationMinuteGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notificationMinute',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  notificationMinuteLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notificationMinute',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  notificationMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notificationMinute',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  notificationReminderDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notificationReminderDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  notificationReminderDaysGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notificationReminderDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  notificationReminderDaysLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notificationReminderDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  notificationReminderDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notificationReminderDays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  periodTypeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'periodType', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  periodTypeGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'periodType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  periodTypeLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'periodType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  periodTypeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'periodType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  recurrenceDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'recurrenceDate'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  recurrenceDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'recurrenceDate'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  recurrenceDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recurrenceDate', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  recurrenceDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recurrenceDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  recurrenceDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recurrenceDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  recurrenceDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recurrenceDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  recurrenceDayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'recurrenceDay'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  recurrenceDayIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'recurrenceDay'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  recurrenceDayEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recurrenceDay', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  recurrenceDayGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recurrenceDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  recurrenceDayLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recurrenceDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  recurrenceDayBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recurrenceDay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'remoteId'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'remoteId'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  remoteIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  remoteIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  remoteIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  remoteIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remoteId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  remoteIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  remoteIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  remoteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  remoteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'remoteId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  startDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startDate', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  startDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  startDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  syncStatusEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStatus', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  syncStatusGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncStatus',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  syncStatusLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncStatus',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  syncStatusBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncStatus',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  totalInstallmentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'totalInstallments'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  totalInstallmentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'totalInstallments'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  totalInstallmentsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalInstallments', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  totalInstallmentsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalInstallments',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  totalInstallmentsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalInstallments',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  totalInstallmentsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalInstallments',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  vaultIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'vaultId'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  vaultIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'vaultId'),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  vaultIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'vaultId', value: value),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  vaultIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'vaultId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  vaultIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'vaultId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterFilterCondition>
  vaultIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'vaultId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RecurringTemplateQueryObject
    on QueryBuilder<RecurringTemplate, RecurringTemplate, QFilterCondition> {}

extension RecurringTemplateQueryLinks
    on QueryBuilder<RecurringTemplate, RecurringTemplate, QFilterCondition> {}

extension RecurringTemplateQuerySortBy
    on QueryBuilder<RecurringTemplate, RecurringTemplate, QSortBy> {
  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByHasNotification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasNotification', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByHasNotificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasNotification', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByIconCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByIconCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByIsIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIncome', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByIsIncomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIncome', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByIsNotificationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationEnabled', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByIsNotificationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationEnabled', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByIsPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByMaxAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAmount', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByMaxAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAmount', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByMinAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAmount', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByMinAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAmount', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByNotificationHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationHour', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByNotificationHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationHour', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByNotificationMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationMinute', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByNotificationMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationMinute', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByNotificationReminderDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationReminderDays', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByNotificationReminderDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationReminderDays', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByPeriodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByPeriodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByRecurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceDate', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByRecurrenceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceDate', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByRecurrenceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceDay', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByRecurrenceDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceDay', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByTotalInstallments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInstallments', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByTotalInstallmentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInstallments', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultId', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  sortByVaultIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultId', Sort.desc);
    });
  }
}

extension RecurringTemplateQuerySortThenBy
    on QueryBuilder<RecurringTemplate, RecurringTemplate, QSortThenBy> {
  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByHasNotification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasNotification', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByHasNotificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasNotification', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByIconCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByIconCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByIsIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIncome', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByIsIncomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIncome', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByIsNotificationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationEnabled', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByIsNotificationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationEnabled', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByIsPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByMaxAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAmount', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByMaxAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAmount', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByMinAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAmount', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByMinAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAmount', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByNotificationHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationHour', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByNotificationHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationHour', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByNotificationMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationMinute', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByNotificationMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationMinute', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByNotificationReminderDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationReminderDays', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByNotificationReminderDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationReminderDays', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByPeriodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByPeriodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByRecurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceDate', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByRecurrenceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceDate', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByRecurrenceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceDay', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByRecurrenceDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceDay', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByTotalInstallments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInstallments', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByTotalInstallmentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInstallments', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultId', Sort.asc);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QAfterSortBy>
  thenByVaultIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultId', Sort.desc);
    });
  }
}

extension RecurringTemplateQueryWhereDistinct
    on QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct> {
  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByHasNotification() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasNotification');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByIconCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isArchived');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByIsIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isIncome');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByIsNotificationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNotificationEnabled');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPaused');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByMaxAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxAmount');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByMinAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minAmount');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByNotificationHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationHour');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByNotificationMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationMinute');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByNotificationReminderDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationReminderDays');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByPeriodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodType');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByRecurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceDate');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByRecurrenceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceDay');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByRemoteId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByTotalInstallments() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalInstallments');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<RecurringTemplate, RecurringTemplate, QDistinct>
  distinctByVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vaultId');
    });
  }
}

extension RecurringTemplateQueryProperty
    on QueryBuilder<RecurringTemplate, RecurringTemplate, QQueryProperty> {
  QueryBuilder<RecurringTemplate, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecurringTemplate, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<RecurringTemplate, String?, QQueryOperations>
  categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<RecurringTemplate, String?, QQueryOperations>
  currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<RecurringTemplate, bool, QQueryOperations>
  hasNotificationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasNotification');
    });
  }

  QueryBuilder<RecurringTemplate, String?, QQueryOperations>
  iconCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconCode');
    });
  }

  QueryBuilder<RecurringTemplate, bool, QQueryOperations> isArchivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isArchived');
    });
  }

  QueryBuilder<RecurringTemplate, bool, QQueryOperations> isIncomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isIncome');
    });
  }

  QueryBuilder<RecurringTemplate, bool, QQueryOperations>
  isNotificationEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNotificationEnabled');
    });
  }

  QueryBuilder<RecurringTemplate, bool, QQueryOperations> isPausedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPaused');
    });
  }

  QueryBuilder<RecurringTemplate, double?, QQueryOperations>
  maxAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxAmount');
    });
  }

  QueryBuilder<RecurringTemplate, double?, QQueryOperations>
  minAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minAmount');
    });
  }

  QueryBuilder<RecurringTemplate, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<RecurringTemplate, int, QQueryOperations>
  notificationHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationHour');
    });
  }

  QueryBuilder<RecurringTemplate, int, QQueryOperations>
  notificationMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationMinute');
    });
  }

  QueryBuilder<RecurringTemplate, int, QQueryOperations>
  notificationReminderDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationReminderDays');
    });
  }

  QueryBuilder<RecurringTemplate, int, QQueryOperations> periodTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodType');
    });
  }

  QueryBuilder<RecurringTemplate, DateTime?, QQueryOperations>
  recurrenceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceDate');
    });
  }

  QueryBuilder<RecurringTemplate, int?, QQueryOperations>
  recurrenceDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceDay');
    });
  }

  QueryBuilder<RecurringTemplate, String?, QQueryOperations>
  remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<RecurringTemplate, DateTime, QQueryOperations>
  startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<RecurringTemplate, int, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<RecurringTemplate, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<RecurringTemplate, int?, QQueryOperations>
  totalInstallmentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalInstallments');
    });
  }

  QueryBuilder<RecurringTemplate, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<RecurringTemplate, int?, QQueryOperations> vaultIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vaultId');
    });
  }
}
