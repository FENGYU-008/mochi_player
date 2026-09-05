// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_metadata_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSeasonMetadataEntityCollection on Isar {
  IsarCollection<SeasonMetadataEntity> get seasonMetadataEntitys => this.collection();
}

const SeasonMetadataEntitySchema = CollectionSchema(
  name: r'SeasonMetadataEntity',
  id: 1929386387446529387,
  properties: {
    r'numberOfEpisodes': PropertySchema(id: 0, name: r'numberOfEpisodes', type: IsarType.long),
    r'overview': PropertySchema(id: 1, name: r'overview', type: IsarType.string),
    r'posterUrl': PropertySchema(id: 2, name: r'posterUrl', type: IsarType.string),
    r'seasonKey': PropertySchema(id: 3, name: r'seasonKey', type: IsarType.string),
    r'seasonNumber': PropertySchema(id: 4, name: r'seasonNumber', type: IsarType.long),
    r'title': PropertySchema(id: 5, name: r'title', type: IsarType.string),
  },
  estimateSize: _seasonMetadataEntityEstimateSize,
  serialize: _seasonMetadataEntitySerialize,
  deserialize: _seasonMetadataEntityDeserialize,
  deserializeProp: _seasonMetadataEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'seasonKey': IndexSchema(
      id: 3690771949584093165,
      name: r'seasonKey',
      unique: true,
      replace: false,
      properties: [IndexPropertySchema(name: r'seasonKey', type: IndexType.hash, caseSensitive: true)],
    ),
  },
  links: {
    r'tvShow': LinkSchema(id: -2766324169383571907, name: r'tvShow', target: r'TVShowMetadataEntity', single: true),
    r'episodes': LinkSchema(
      id: -3427217056510816274,
      name: r'episodes',
      target: r'EpisodeMetadataEntity',
      single: false,
      linkName: r'season',
    ),
  },
  embeddedSchemas: {},
  getId: _seasonMetadataEntityGetId,
  getLinks: _seasonMetadataEntityGetLinks,
  attach: _seasonMetadataEntityAttach,
  version: '3.1.0+1',
);

int _seasonMetadataEntityEstimateSize(SeasonMetadataEntity object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  {
    final value = object.overview;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.posterUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.seasonKey.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _seasonMetadataEntitySerialize(
  SeasonMetadataEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.numberOfEpisodes);
  writer.writeString(offsets[1], object.overview);
  writer.writeString(offsets[2], object.posterUrl);
  writer.writeString(offsets[3], object.seasonKey);
  writer.writeLong(offsets[4], object.seasonNumber);
  writer.writeString(offsets[5], object.title);
}

SeasonMetadataEntity _seasonMetadataEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SeasonMetadataEntity();
  object.id = id;
  object.numberOfEpisodes = reader.readLongOrNull(offsets[0]);
  object.overview = reader.readStringOrNull(offsets[1]);
  object.posterUrl = reader.readStringOrNull(offsets[2]);
  object.seasonKey = reader.readString(offsets[3]);
  object.seasonNumber = reader.readLong(offsets[4]);
  object.title = reader.readString(offsets[5]);
  return object;
}

P _seasonMetadataEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _seasonMetadataEntityGetId(SeasonMetadataEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _seasonMetadataEntityGetLinks(SeasonMetadataEntity object) {
  return [object.tvShow, object.episodes];
}

void _seasonMetadataEntityAttach(IsarCollection<dynamic> col, Id id, SeasonMetadataEntity object) {
  object.id = id;
  object.tvShow.attach(col, col.isar.collection<TVShowMetadataEntity>(), r'tvShow', id);
  object.episodes.attach(col, col.isar.collection<EpisodeMetadataEntity>(), r'episodes', id);
}

extension SeasonMetadataEntityByIndex on IsarCollection<SeasonMetadataEntity> {
  Future<SeasonMetadataEntity?> getBySeasonKey(String seasonKey) {
    return getByIndex(r'seasonKey', [seasonKey]);
  }

  SeasonMetadataEntity? getBySeasonKeySync(String seasonKey) {
    return getByIndexSync(r'seasonKey', [seasonKey]);
  }

  Future<bool> deleteBySeasonKey(String seasonKey) {
    return deleteByIndex(r'seasonKey', [seasonKey]);
  }

  bool deleteBySeasonKeySync(String seasonKey) {
    return deleteByIndexSync(r'seasonKey', [seasonKey]);
  }

  Future<List<SeasonMetadataEntity?>> getAllBySeasonKey(List<String> seasonKeyValues) {
    final values = seasonKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'seasonKey', values);
  }

  List<SeasonMetadataEntity?> getAllBySeasonKeySync(List<String> seasonKeyValues) {
    final values = seasonKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'seasonKey', values);
  }

  Future<int> deleteAllBySeasonKey(List<String> seasonKeyValues) {
    final values = seasonKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'seasonKey', values);
  }

  int deleteAllBySeasonKeySync(List<String> seasonKeyValues) {
    final values = seasonKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'seasonKey', values);
  }

  Future<Id> putBySeasonKey(SeasonMetadataEntity object) {
    return putByIndex(r'seasonKey', object);
  }

  Id putBySeasonKeySync(SeasonMetadataEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'seasonKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySeasonKey(List<SeasonMetadataEntity> objects) {
    return putAllByIndex(r'seasonKey', objects);
  }

  List<Id> putAllBySeasonKeySync(List<SeasonMetadataEntity> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'seasonKey', objects, saveLinks: saveLinks);
  }
}

extension SeasonMetadataEntityQueryWhereSort on QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QWhere> {
  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SeasonMetadataEntityQueryWhere on QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QWhereClause> {
  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: false))
            .addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: false));
      } else {
        return query
            .addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: false))
            .addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: false));
      }
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: include));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: include));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: lowerId, includeLower: includeLower, upper: upperId, includeUpper: includeUpper),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterWhereClause> seasonKeyEqualTo(String seasonKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(indexName: r'seasonKey', value: [seasonKey]));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterWhereClause> seasonKeyNotEqualTo(String seasonKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(indexName: r'seasonKey', lower: [], upper: [seasonKey], includeUpper: false),
            )
            .addWhereClause(
              IndexWhereClause.between(indexName: r'seasonKey', lower: [seasonKey], includeLower: false, upper: []),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(indexName: r'seasonKey', lower: [seasonKey], includeLower: false, upper: []),
            )
            .addWhereClause(
              IndexWhereClause.between(indexName: r'seasonKey', lower: [], upper: [seasonKey], includeUpper: false),
            );
      }
    });
  }
}

extension SeasonMetadataEntityQueryFilter
    on QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QFilterCondition> {
  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'id', value: value));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(include: include, property: r'id', value: value));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'id', value: value));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> numberOfEpisodesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'numberOfEpisodes'));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> numberOfEpisodesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'numberOfEpisodes'));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> numberOfEpisodesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'numberOfEpisodes', value: value));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> numberOfEpisodesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'numberOfEpisodes', value: value),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> numberOfEpisodesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'numberOfEpisodes', value: value),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> numberOfEpisodesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'numberOfEpisodes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> overviewIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'overview'));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> overviewIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'overview'));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> overviewEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'overview', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> overviewGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'overview',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> overviewLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'overview', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> overviewBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'overview',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> overviewStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'overview', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> overviewEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'overview', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> overviewContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'overview', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> overviewMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'overview', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> overviewIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'overview', value: ''));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> overviewIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'overview', value: ''));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> posterUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'posterUrl'));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> posterUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'posterUrl'));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> posterUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'posterUrl', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> posterUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'posterUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> posterUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'posterUrl', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> posterUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'posterUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> posterUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'posterUrl', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> posterUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'posterUrl', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> posterUrlContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'posterUrl', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> posterUrlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'posterUrl', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> posterUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'posterUrl', value: ''));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> posterUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'posterUrl', value: ''));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seasonKey', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seasonKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'seasonKey', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seasonKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'seasonKey', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'seasonKey', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonKeyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'seasonKey', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonKeyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'seasonKey', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'seasonKey', value: ''));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'seasonKey', value: ''));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'seasonNumber', value: value));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'seasonNumber', value: value),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'seasonNumber', value: value),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> seasonNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seasonNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'title', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'title', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'title', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'title', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'title', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'title', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'title', value: ''));
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'title', value: ''));
    });
  }
}

extension SeasonMetadataEntityQueryObject
    on QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QFilterCondition> {}

extension SeasonMetadataEntityQueryLinks on QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QFilterCondition> {
  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> tvShow(
    FilterQuery<TVShowMetadataEntity> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'tvShow');
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> tvShowIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tvShow', 0, true, 0, true);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> episodes(
    FilterQuery<EpisodeMetadataEntity> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'episodes');
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> episodesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'episodes', length, true, length, true);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> episodesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'episodes', 0, true, 0, true);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> episodesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'episodes', 0, false, 999999, true);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> episodesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'episodes', 0, true, length, include);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> episodesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'episodes', length, include, 999999, true);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterFilterCondition> episodesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'episodes', lower, includeLower, upper, includeUpper);
    });
  }
}

extension SeasonMetadataEntityQuerySortBy on QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QSortBy> {
  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> sortByNumberOfEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfEpisodes', Sort.asc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> sortByNumberOfEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfEpisodes', Sort.desc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> sortByOverview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.asc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> sortByOverviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.desc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> sortByPosterUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posterUrl', Sort.asc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> sortByPosterUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posterUrl', Sort.desc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> sortBySeasonKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonKey', Sort.asc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> sortBySeasonKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonKey', Sort.desc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> sortBySeasonNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonNumber', Sort.asc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> sortBySeasonNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonNumber', Sort.desc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension SeasonMetadataEntityQuerySortThenBy on QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QSortThenBy> {
  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenByNumberOfEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfEpisodes', Sort.asc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenByNumberOfEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfEpisodes', Sort.desc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenByOverview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.asc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenByOverviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.desc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenByPosterUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posterUrl', Sort.asc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenByPosterUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posterUrl', Sort.desc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenBySeasonKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonKey', Sort.asc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenBySeasonKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonKey', Sort.desc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenBySeasonNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonNumber', Sort.asc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenBySeasonNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonNumber', Sort.desc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension SeasonMetadataEntityQueryWhereDistinct
    on QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QDistinct> {
  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QDistinct> distinctByNumberOfEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numberOfEpisodes');
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QDistinct> distinctByOverview({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overview', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QDistinct> distinctByPosterUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'posterUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QDistinct> distinctBySeasonKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seasonKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QDistinct> distinctBySeasonNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seasonNumber');
    });
  }

  QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QDistinct> distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension SeasonMetadataEntityQueryProperty
    on QueryBuilder<SeasonMetadataEntity, SeasonMetadataEntity, QQueryProperty> {
  QueryBuilder<SeasonMetadataEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SeasonMetadataEntity, int?, QQueryOperations> numberOfEpisodesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numberOfEpisodes');
    });
  }

  QueryBuilder<SeasonMetadataEntity, String?, QQueryOperations> overviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overview');
    });
  }

  QueryBuilder<SeasonMetadataEntity, String?, QQueryOperations> posterUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'posterUrl');
    });
  }

  QueryBuilder<SeasonMetadataEntity, String, QQueryOperations> seasonKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonKey');
    });
  }

  QueryBuilder<SeasonMetadataEntity, int, QQueryOperations> seasonNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonNumber');
    });
  }

  QueryBuilder<SeasonMetadataEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
