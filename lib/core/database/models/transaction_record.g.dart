// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTransactionRecordCollection on Isar {
  IsarCollection<TransactionRecord> get transactionRecords => this.collection();
}

const TransactionRecordSchema = CollectionSchema(
  name: r'TransactionRecord',
  id: 5251947889243599499,
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
    r'date': PropertySchema(id: 3, name: r'date', type: IsarType.dateTime),
    r'iconCode': PropertySchema(
      id: 4,
      name: r'iconCode',
      type: IsarType.string,
    ),
    r'installmentNumber': PropertySchema(
      id: 5,
      name: r'installmentNumber',
      type: IsarType.long,
    ),
    r'isArchived': PropertySchema(
      id: 6,
      name: r'isArchived',
      type: IsarType.bool,
    ),
    r'isIncome': PropertySchema(id: 7, name: r'isIncome', type: IsarType.bool),
    r'isReviewed': PropertySchema(
      id: 8,
      name: r'isReviewed',
      type: IsarType.bool,
    ),
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
    r'occurrenceDate': PropertySchema(
      id: 12,
      name: r'occurrenceDate',
      type: IsarType.dateTime,
    ),
    r'occurrenceKey': PropertySchema(
      id: 13,
      name: r'occurrenceKey',
      type: IsarType.string,
    ),
    r'remoteId': PropertySchema(
      id: 14,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(id: 15, name: r'status', type: IsarType.long),
    r'syncStatus': PropertySchema(
      id: 16,
      name: r'syncStatus',
      type: IsarType.long,
    ),
    r'targetVaultId': PropertySchema(
      id: 17,
      name: r'targetVaultId',
      type: IsarType.long,
    ),
    r'templateId': PropertySchema(
      id: 18,
      name: r'templateId',
      type: IsarType.long,
    ),
    r'title': PropertySchema(id: 19, name: r'title', type: IsarType.string),
    r'totalInstallments': PropertySchema(
      id: 20,
      name: r'totalInstallments',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 21,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'vaultId': PropertySchema(id: 22, name: r'vaultId', type: IsarType.long),
  },

  estimateSize: _transactionRecordEstimateSize,
  serialize: _transactionRecordSerialize,
  deserialize: _transactionRecordDeserialize,
  deserializeProp: _transactionRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'occurrenceDate': IndexSchema(
      id: 7253513228793877556,
      name: r'occurrenceDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'occurrenceDate',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
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
    r'targetVaultId': IndexSchema(
      id: -150656434833661031,
      name: r'targetVaultId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'targetVaultId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'templateId': IndexSchema(
      id: -5352721467389445085,
      name: r'templateId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'templateId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'occurrenceKey': IndexSchema(
      id: 1905454298359628696,
      name: r'occurrenceKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'occurrenceKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'isReviewed': IndexSchema(
      id: 463194079450348758,
      name: r'isReviewed',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isReviewed',
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

  getId: _transactionRecordGetId,
  getLinks: _transactionRecordGetLinks,
  attach: _transactionRecordAttach,
  version: '3.3.2',
);

int _transactionRecordEstimateSize(
  TransactionRecord object,
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
  bytesCount += 3 + object.occurrenceKey.length * 3;
  {
    final value = object.remoteId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _transactionRecordSerialize(
  TransactionRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeString(offsets[1], object.categoryId);
  writer.writeString(offsets[2], object.currency);
  writer.writeDateTime(offsets[3], object.date);
  writer.writeString(offsets[4], object.iconCode);
  writer.writeLong(offsets[5], object.installmentNumber);
  writer.writeBool(offsets[6], object.isArchived);
  writer.writeBool(offsets[7], object.isIncome);
  writer.writeBool(offsets[8], object.isReviewed);
  writer.writeDouble(offsets[9], object.maxAmount);
  writer.writeDouble(offsets[10], object.minAmount);
  writer.writeString(offsets[11], object.note);
  writer.writeDateTime(offsets[12], object.occurrenceDate);
  writer.writeString(offsets[13], object.occurrenceKey);
  writer.writeString(offsets[14], object.remoteId);
  writer.writeLong(offsets[15], object.status);
  writer.writeLong(offsets[16], object.syncStatus);
  writer.writeLong(offsets[17], object.targetVaultId);
  writer.writeLong(offsets[18], object.templateId);
  writer.writeString(offsets[19], object.title);
  writer.writeLong(offsets[20], object.totalInstallments);
  writer.writeDateTime(offsets[21], object.updatedAt);
  writer.writeLong(offsets[22], object.vaultId);
}

TransactionRecord _transactionRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TransactionRecord();
  object.amount = reader.readDouble(offsets[0]);
  object.categoryId = reader.readStringOrNull(offsets[1]);
  object.currency = reader.readStringOrNull(offsets[2]);
  object.date = reader.readDateTime(offsets[3]);
  object.iconCode = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.installmentNumber = reader.readLongOrNull(offsets[5]);
  object.isArchived = reader.readBool(offsets[6]);
  object.isIncome = reader.readBool(offsets[7]);
  object.isReviewed = reader.readBool(offsets[8]);
  object.maxAmount = reader.readDoubleOrNull(offsets[9]);
  object.minAmount = reader.readDoubleOrNull(offsets[10]);
  object.note = reader.readStringOrNull(offsets[11]);
  object.occurrenceDate = reader.readDateTime(offsets[12]);
  object.occurrenceKey = reader.readString(offsets[13]);
  object.remoteId = reader.readStringOrNull(offsets[14]);
  object.status = reader.readLong(offsets[15]);
  object.syncStatus = reader.readLong(offsets[16]);
  object.targetVaultId = reader.readLongOrNull(offsets[17]);
  object.templateId = reader.readLongOrNull(offsets[18]);
  object.title = reader.readString(offsets[19]);
  object.totalInstallments = reader.readLongOrNull(offsets[20]);
  object.updatedAt = reader.readDateTime(offsets[21]);
  object.vaultId = reader.readLongOrNull(offsets[22]);
  return object;
}

P _transactionRecordDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
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
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readLongOrNull(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readLongOrNull(offset)) as P;
    case 21:
      return (reader.readDateTime(offset)) as P;
    case 22:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _transactionRecordGetId(TransactionRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transactionRecordGetLinks(
  TransactionRecord object,
) {
  return [];
}

void _transactionRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  TransactionRecord object,
) {
  object.id = id;
}

extension TransactionRecordByIndex on IsarCollection<TransactionRecord> {
  Future<TransactionRecord?> getByOccurrenceKey(String occurrenceKey) {
    return getByIndex(r'occurrenceKey', [occurrenceKey]);
  }

  TransactionRecord? getByOccurrenceKeySync(String occurrenceKey) {
    return getByIndexSync(r'occurrenceKey', [occurrenceKey]);
  }

  Future<bool> deleteByOccurrenceKey(String occurrenceKey) {
    return deleteByIndex(r'occurrenceKey', [occurrenceKey]);
  }

  bool deleteByOccurrenceKeySync(String occurrenceKey) {
    return deleteByIndexSync(r'occurrenceKey', [occurrenceKey]);
  }

  Future<List<TransactionRecord?>> getAllByOccurrenceKey(
    List<String> occurrenceKeyValues,
  ) {
    final values = occurrenceKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'occurrenceKey', values);
  }

  List<TransactionRecord?> getAllByOccurrenceKeySync(
    List<String> occurrenceKeyValues,
  ) {
    final values = occurrenceKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'occurrenceKey', values);
  }

  Future<int> deleteAllByOccurrenceKey(List<String> occurrenceKeyValues) {
    final values = occurrenceKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'occurrenceKey', values);
  }

  int deleteAllByOccurrenceKeySync(List<String> occurrenceKeyValues) {
    final values = occurrenceKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'occurrenceKey', values);
  }

  Future<Id> putByOccurrenceKey(TransactionRecord object) {
    return putByIndex(r'occurrenceKey', object);
  }

  Id putByOccurrenceKeySync(TransactionRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'occurrenceKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOccurrenceKey(List<TransactionRecord> objects) {
    return putAllByIndex(r'occurrenceKey', objects);
  }

  List<Id> putAllByOccurrenceKeySync(
    List<TransactionRecord> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'occurrenceKey', objects, saveLinks: saveLinks);
  }
}

extension TransactionRecordQueryWhereSort
    on QueryBuilder<TransactionRecord, TransactionRecord, QWhere> {
  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhere>
  anyOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'occurrenceDate'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhere> anyVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'vaultId'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhere>
  anyTargetVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'targetVaultId'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhere>
  anyTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'templateId'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhere> anyStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'status'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhere>
  anyIsReviewed() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isReviewed'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhere>
  anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhere>
  anySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'syncStatus'),
      );
    });
  }
}

extension TransactionRecordQueryWhere
    on QueryBuilder<TransactionRecord, TransactionRecord, QWhereClause> {
  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  occurrenceDateEqualTo(DateTime occurrenceDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'occurrenceDate',
          value: [occurrenceDate],
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  occurrenceDateNotEqualTo(DateTime occurrenceDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'occurrenceDate',
                lower: [],
                upper: [occurrenceDate],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'occurrenceDate',
                lower: [occurrenceDate],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'occurrenceDate',
                lower: [occurrenceDate],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'occurrenceDate',
                lower: [],
                upper: [occurrenceDate],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  occurrenceDateGreaterThan(DateTime occurrenceDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'occurrenceDate',
          lower: [occurrenceDate],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  occurrenceDateLessThan(DateTime occurrenceDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'occurrenceDate',
          lower: [],
          upper: [occurrenceDate],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  occurrenceDateBetween(
    DateTime lowerOccurrenceDate,
    DateTime upperOccurrenceDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'occurrenceDate',
          lower: [lowerOccurrenceDate],
          includeLower: includeLower,
          upper: [upperOccurrenceDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  vaultIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'vaultId', value: [null]),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  vaultIdEqualTo(int? vaultId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'vaultId', value: [vaultId]),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  targetVaultIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'targetVaultId', value: [null]),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  targetVaultIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'targetVaultId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  targetVaultIdEqualTo(int? targetVaultId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'targetVaultId',
          value: [targetVaultId],
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  targetVaultIdNotEqualTo(int? targetVaultId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'targetVaultId',
                lower: [],
                upper: [targetVaultId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'targetVaultId',
                lower: [targetVaultId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'targetVaultId',
                lower: [targetVaultId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'targetVaultId',
                lower: [],
                upper: [targetVaultId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  targetVaultIdGreaterThan(int? targetVaultId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'targetVaultId',
          lower: [targetVaultId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  targetVaultIdLessThan(int? targetVaultId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'targetVaultId',
          lower: [],
          upper: [targetVaultId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  targetVaultIdBetween(
    int? lowerTargetVaultId,
    int? upperTargetVaultId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'targetVaultId',
          lower: [lowerTargetVaultId],
          includeLower: includeLower,
          upper: [upperTargetVaultId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  templateIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'templateId', value: [null]),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  templateIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'templateId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  templateIdEqualTo(int? templateId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'templateId', value: [templateId]),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  templateIdNotEqualTo(int? templateId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'templateId',
                lower: [],
                upper: [templateId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'templateId',
                lower: [templateId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'templateId',
                lower: [templateId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'templateId',
                lower: [],
                upper: [templateId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  templateIdGreaterThan(int? templateId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'templateId',
          lower: [templateId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  templateIdLessThan(int? templateId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'templateId',
          lower: [],
          upper: [templateId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  templateIdBetween(
    int? lowerTemplateId,
    int? upperTemplateId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'templateId',
          lower: [lowerTemplateId],
          includeLower: includeLower,
          upper: [upperTemplateId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  occurrenceKeyEqualTo(String occurrenceKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'occurrenceKey',
          value: [occurrenceKey],
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  occurrenceKeyNotEqualTo(String occurrenceKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'occurrenceKey',
                lower: [],
                upper: [occurrenceKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'occurrenceKey',
                lower: [occurrenceKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'occurrenceKey',
                lower: [occurrenceKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'occurrenceKey',
                lower: [],
                upper: [occurrenceKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  statusEqualTo(int status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'status', value: [status]),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  statusNotEqualTo(int status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  statusGreaterThan(int status, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'status',
          lower: [status],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  statusLessThan(int status, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'status',
          lower: [],
          upper: [status],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  statusBetween(
    int lowerStatus,
    int upperStatus, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'status',
          lower: [lowerStatus],
          includeLower: includeLower,
          upper: [upperStatus],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  isReviewedEqualTo(bool isReviewed) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'isReviewed', value: [isReviewed]),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  isReviewedNotEqualTo(bool isReviewed) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isReviewed',
                lower: [],
                upper: [isReviewed],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isReviewed',
                lower: [isReviewed],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isReviewed',
                lower: [isReviewed],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isReviewed',
                lower: [],
                upper: [isReviewed],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'remoteId', value: [null]),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  remoteIdEqualTo(String? remoteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'remoteId', value: [remoteId]),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'updatedAt', value: [updatedAt]),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
  syncStatusEqualTo(int syncStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'syncStatus', value: [syncStatus]),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterWhereClause>
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

extension TransactionRecordQueryFilter
    on QueryBuilder<TransactionRecord, TransactionRecord, QFilterCondition> {
  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  categoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'categoryId'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  categoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'categoryId'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  categoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  categoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  currencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currency'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  currencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currency'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currency', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currency', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  dateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  dateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  iconCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'iconCode'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  iconCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'iconCode'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  iconCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'iconCode', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  iconCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'iconCode', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  installmentNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'installmentNumber'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  installmentNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'installmentNumber'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  installmentNumberEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'installmentNumber', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  installmentNumberGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'installmentNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  installmentNumberLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'installmentNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  installmentNumberBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'installmentNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  isArchivedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isArchived', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  isIncomeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isIncome', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  isReviewedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isReviewed', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  maxAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'maxAmount'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  maxAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'maxAmount'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  minAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'minAmount'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  minAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'minAmount'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'note'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'note'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'occurrenceDate', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'occurrenceDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'occurrenceDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'occurrenceDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'occurrenceKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'occurrenceKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'occurrenceKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'occurrenceKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'occurrenceKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'occurrenceKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'occurrenceKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'occurrenceKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'occurrenceKey', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  occurrenceKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'occurrenceKey', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'remoteId'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'remoteId'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  statusEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  statusGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  statusLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  statusBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  syncStatusEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStatus', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  targetVaultIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'targetVaultId'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  targetVaultIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'targetVaultId'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  targetVaultIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'targetVaultId', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  targetVaultIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'targetVaultId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  targetVaultIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'targetVaultId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  targetVaultIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'targetVaultId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  templateIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'templateId'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  templateIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'templateId'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  templateIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'templateId', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  templateIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'templateId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  templateIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'templateId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  templateIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'templateId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  totalInstallmentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'totalInstallments'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  totalInstallmentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'totalInstallments'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  totalInstallmentsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalInstallments', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  vaultIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'vaultId'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  vaultIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'vaultId'),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
  vaultIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'vaultId', value: value),
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterFilterCondition>
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

extension TransactionRecordQueryObject
    on QueryBuilder<TransactionRecord, TransactionRecord, QFilterCondition> {}

extension TransactionRecordQueryLinks
    on QueryBuilder<TransactionRecord, TransactionRecord, QFilterCondition> {}

extension TransactionRecordQuerySortBy
    on QueryBuilder<TransactionRecord, TransactionRecord, QSortBy> {
  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByIconCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByIconCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByInstallmentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentNumber', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByInstallmentNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentNumber', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByIsIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIncome', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByIsIncomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIncome', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByIsReviewed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReviewed', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByIsReviewedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReviewed', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByMaxAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAmount', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByMaxAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAmount', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByMinAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAmount', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByMinAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAmount', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByOccurrenceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByOccurrenceKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceKey', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByOccurrenceKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceKey', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByTargetVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetVaultId', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByTargetVaultIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetVaultId', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByTotalInstallments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInstallments', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByTotalInstallmentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInstallments', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultId', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  sortByVaultIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultId', Sort.desc);
    });
  }
}

extension TransactionRecordQuerySortThenBy
    on QueryBuilder<TransactionRecord, TransactionRecord, QSortThenBy> {
  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByIconCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByIconCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByInstallmentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentNumber', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByInstallmentNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentNumber', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByIsIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIncome', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByIsIncomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIncome', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByIsReviewed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReviewed', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByIsReviewedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReviewed', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByMaxAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAmount', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByMaxAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAmount', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByMinAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAmount', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByMinAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAmount', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByOccurrenceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByOccurrenceKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceKey', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByOccurrenceKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceKey', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByTargetVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetVaultId', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByTargetVaultIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetVaultId', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByTotalInstallments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInstallments', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByTotalInstallmentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInstallments', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultId', Sort.asc);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QAfterSortBy>
  thenByVaultIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultId', Sort.desc);
    });
  }
}

extension TransactionRecordQueryWhereDistinct
    on QueryBuilder<TransactionRecord, TransactionRecord, QDistinct> {
  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByIconCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByInstallmentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'installmentNumber');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isArchived');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByIsIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isIncome');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByIsReviewed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isReviewed');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByMaxAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxAmount');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByMinAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minAmount');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'occurrenceDate');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByOccurrenceKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'occurrenceKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByRemoteId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByTargetVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetVaultId');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'templateId');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByTotalInstallments() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalInstallments');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<TransactionRecord, TransactionRecord, QDistinct>
  distinctByVaultId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vaultId');
    });
  }
}

extension TransactionRecordQueryProperty
    on QueryBuilder<TransactionRecord, TransactionRecord, QQueryProperty> {
  QueryBuilder<TransactionRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TransactionRecord, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<TransactionRecord, String?, QQueryOperations>
  categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<TransactionRecord, String?, QQueryOperations>
  currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<TransactionRecord, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<TransactionRecord, String?, QQueryOperations>
  iconCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconCode');
    });
  }

  QueryBuilder<TransactionRecord, int?, QQueryOperations>
  installmentNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'installmentNumber');
    });
  }

  QueryBuilder<TransactionRecord, bool, QQueryOperations> isArchivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isArchived');
    });
  }

  QueryBuilder<TransactionRecord, bool, QQueryOperations> isIncomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isIncome');
    });
  }

  QueryBuilder<TransactionRecord, bool, QQueryOperations> isReviewedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isReviewed');
    });
  }

  QueryBuilder<TransactionRecord, double?, QQueryOperations>
  maxAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxAmount');
    });
  }

  QueryBuilder<TransactionRecord, double?, QQueryOperations>
  minAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minAmount');
    });
  }

  QueryBuilder<TransactionRecord, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<TransactionRecord, DateTime, QQueryOperations>
  occurrenceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occurrenceDate');
    });
  }

  QueryBuilder<TransactionRecord, String, QQueryOperations>
  occurrenceKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occurrenceKey');
    });
  }

  QueryBuilder<TransactionRecord, String?, QQueryOperations>
  remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<TransactionRecord, int, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<TransactionRecord, int, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<TransactionRecord, int?, QQueryOperations>
  targetVaultIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetVaultId');
    });
  }

  QueryBuilder<TransactionRecord, int?, QQueryOperations> templateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'templateId');
    });
  }

  QueryBuilder<TransactionRecord, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<TransactionRecord, int?, QQueryOperations>
  totalInstallmentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalInstallments');
    });
  }

  QueryBuilder<TransactionRecord, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<TransactionRecord, int?, QQueryOperations> vaultIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vaultId');
    });
  }
}
