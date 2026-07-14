// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_metadata_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEpisodeMetadataEntityCollection on Isar {
  IsarCollection<EpisodeMetadataEntity> get episodeMetadataEntitys =>
      this.collection();
}

const EpisodeMetadataEntitySchema = CollectionSchema(
  name: r'EpisodeMetadataEntity',
  id: -156287308057323980,
  properties: {
    r'airDate': PropertySchema(
      id: 0,
      name: r'airDate',
      type: IsarType.dateTime,
    ),
    r'episodeNumber': PropertySchema(
      id: 1,
      name: r'episodeNumber',
      type: IsarType.long,
    ),
    r'guestStars': PropertySchema(
      id: 2,
      name: r'guestStars',
      type: IsarType.objectList,
      target: r'ArtistEmbedded',
    ),
    r'overview': PropertySchema(
      id: 3,
      name: r'overview',
      type: IsarType.string,
    ),
    r'stillUrl': PropertySchema(
      id: 4,
      name: r'stillUrl',
      type: IsarType.string,
    ),
    r'title': PropertySchema(id: 5, name: r'title', type: IsarType.string),
    r'tmdbId': PropertySchema(id: 6, name: r'tmdbId', type: IsarType.string),
  },
  estimateSize: _episodeMetadataEntityEstimateSize,
  serialize: _episodeMetadataEntitySerialize,
  deserialize: _episodeMetadataEntityDeserialize,
  deserializeProp: _episodeMetadataEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'tmdbId': IndexSchema(
      id: 7174867214654401712,
      name: r'tmdbId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tmdbId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {
    r'season': LinkSchema(
      id: 8200288874779803552,
      name: r'season',
      target: r'SeasonMetadataEntity',
      single: true,
    ),
  },
  embeddedSchemas: {r'ArtistEmbedded': ArtistEmbeddedSchema},
  getId: _episodeMetadataEntityGetId,
  getLinks: _episodeMetadataEntityGetLinks,
  attach: _episodeMetadataEntityAttach,
  version: '3.1.0+1',
);

int _episodeMetadataEntityEstimateSize(
  EpisodeMetadataEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.guestStars.length * 3;
  {
    final offsets = allOffsets[ArtistEmbedded]!;
    for (var i = 0; i < object.guestStars.length; i++) {
      final value = object.guestStars[i];
      bytesCount += ArtistEmbeddedSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  {
    final value = object.overview;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.stillUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.tmdbId.length * 3;
  return bytesCount;
}

void _episodeMetadataEntitySerialize(
  EpisodeMetadataEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.airDate);
  writer.writeLong(offsets[1], object.episodeNumber);
  writer.writeObjectList<ArtistEmbedded>(
    offsets[2],
    allOffsets,
    ArtistEmbeddedSchema.serialize,
    object.guestStars,
  );
  writer.writeString(offsets[3], object.overview);
  writer.writeString(offsets[4], object.stillUrl);
  writer.writeString(offsets[5], object.title);
  writer.writeString(offsets[6], object.tmdbId);
}

EpisodeMetadataEntity _episodeMetadataEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EpisodeMetadataEntity();
  object.airDate = reader.readDateTimeOrNull(offsets[0]);
  object.episodeNumber = reader.readLong(offsets[1]);
  object.guestStars =
      reader.readObjectList<ArtistEmbedded>(
        offsets[2],
        ArtistEmbeddedSchema.deserialize,
        allOffsets,
        ArtistEmbedded(),
      ) ??
      [];
  object.id = id;
  object.overview = reader.readStringOrNull(offsets[3]);
  object.stillUrl = reader.readStringOrNull(offsets[4]);
  object.title = reader.readString(offsets[5]);
  object.tmdbId = reader.readString(offsets[6]);
  return object;
}

P _episodeMetadataEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readObjectList<ArtistEmbedded>(
                offset,
                ArtistEmbeddedSchema.deserialize,
                allOffsets,
                ArtistEmbedded(),
              ) ??
              [])
          as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _episodeMetadataEntityGetId(EpisodeMetadataEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _episodeMetadataEntityGetLinks(
  EpisodeMetadataEntity object,
) {
  return [object.season];
}

void _episodeMetadataEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  EpisodeMetadataEntity object,
) {
  object.id = id;
  object.season.attach(
    col,
    col.isar.collection<SeasonMetadataEntity>(),
    r'season',
    id,
  );
}

extension EpisodeMetadataEntityByIndex
    on IsarCollection<EpisodeMetadataEntity> {
  Future<EpisodeMetadataEntity?> getByTmdbId(String tmdbId) {
    return getByIndex(r'tmdbId', [tmdbId]);
  }

  EpisodeMetadataEntity? getByTmdbIdSync(String tmdbId) {
    return getByIndexSync(r'tmdbId', [tmdbId]);
  }

  Future<bool> deleteByTmdbId(String tmdbId) {
    return deleteByIndex(r'tmdbId', [tmdbId]);
  }

  bool deleteByTmdbIdSync(String tmdbId) {
    return deleteByIndexSync(r'tmdbId', [tmdbId]);
  }

  Future<List<EpisodeMetadataEntity?>> getAllByTmdbId(
    List<String> tmdbIdValues,
  ) {
    final values = tmdbIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'tmdbId', values);
  }

  List<EpisodeMetadataEntity?> getAllByTmdbIdSync(List<String> tmdbIdValues) {
    final values = tmdbIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'tmdbId', values);
  }

  Future<int> deleteAllByTmdbId(List<String> tmdbIdValues) {
    final values = tmdbIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'tmdbId', values);
  }

  int deleteAllByTmdbIdSync(List<String> tmdbIdValues) {
    final values = tmdbIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'tmdbId', values);
  }

  Future<Id> putByTmdbId(EpisodeMetadataEntity object) {
    return putByIndex(r'tmdbId', object);
  }

  Id putByTmdbIdSync(EpisodeMetadataEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'tmdbId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTmdbId(List<EpisodeMetadataEntity> objects) {
    return putAllByIndex(r'tmdbId', objects);
  }

  List<Id> putAllByTmdbIdSync(
    List<EpisodeMetadataEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'tmdbId', objects, saveLinks: saveLinks);
  }
}

extension EpisodeMetadataEntityQueryWhereSort
    on QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QWhere> {
  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EpisodeMetadataEntityQueryWhere
    on
        QueryBuilder<
          EpisodeMetadataEntity,
          EpisodeMetadataEntity,
          QWhereClause
        > {
  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterWhereClause>
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

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterWhereClause>
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

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterWhereClause>
  tmdbIdEqualTo(String tmdbId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'tmdbId', value: [tmdbId]),
      );
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterWhereClause>
  tmdbIdNotEqualTo(String tmdbId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tmdbId',
                lower: [],
                upper: [tmdbId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tmdbId',
                lower: [tmdbId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tmdbId',
                lower: [tmdbId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tmdbId',
                lower: [],
                upper: [tmdbId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension EpisodeMetadataEntityQueryFilter
    on
        QueryBuilder<
          EpisodeMetadataEntity,
          EpisodeMetadataEntity,
          QFilterCondition
        > {
  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  airDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'airDate'),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  airDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'airDate'),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  airDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'airDate', value: value),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  airDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'airDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  airDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'airDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  airDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'airDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  episodeNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeNumber', value: value),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  episodeNumberGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  episodeNumberLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  episodeNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  guestStarsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'guestStars', length, true, length, true);
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  guestStarsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'guestStars', 0, true, 0, true);
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  guestStarsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'guestStars', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  guestStarsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'guestStars', 0, true, length, include);
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  guestStarsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'guestStars', length, include, 999999, true);
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  guestStarsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'guestStars',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  overviewIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'overview'),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  overviewIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'overview'),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  overviewEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'overview',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  overviewGreaterThan(
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

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  overviewLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'overview',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  overviewBetween(
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

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  overviewStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'overview',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  overviewEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'overview',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  overviewContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'overview',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  overviewMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'overview',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  overviewIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'overview', value: ''),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  overviewIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'overview', value: ''),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  stillUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'stillUrl'),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  stillUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'stillUrl'),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  stillUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'stillUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  stillUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stillUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  stillUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stillUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  stillUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stillUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  stillUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'stillUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  stillUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'stillUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  stillUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'stillUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  stillUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'stillUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  stillUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stillUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  stillUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'stillUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  tmdbIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tmdbId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  tmdbIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tmdbId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  tmdbIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tmdbId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  tmdbIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tmdbId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  tmdbIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tmdbId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  tmdbIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tmdbId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  tmdbIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tmdbId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  tmdbIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tmdbId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  tmdbIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tmdbId', value: ''),
      );
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  tmdbIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tmdbId', value: ''),
      );
    });
  }
}

extension EpisodeMetadataEntityQueryObject
    on
        QueryBuilder<
          EpisodeMetadataEntity,
          EpisodeMetadataEntity,
          QFilterCondition
        > {
  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  guestStarsElement(FilterQuery<ArtistEmbedded> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'guestStars');
    });
  }
}

extension EpisodeMetadataEntityQueryLinks
    on
        QueryBuilder<
          EpisodeMetadataEntity,
          EpisodeMetadataEntity,
          QFilterCondition
        > {
  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  season(FilterQuery<SeasonMetadataEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'season');
    });
  }

  QueryBuilder<
    EpisodeMetadataEntity,
    EpisodeMetadataEntity,
    QAfterFilterCondition
  >
  seasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'season', 0, true, 0, true);
    });
  }
}

extension EpisodeMetadataEntityQuerySortBy
    on QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QSortBy> {
  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  sortByAirDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'airDate', Sort.asc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  sortByAirDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'airDate', Sort.desc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  sortByEpisodeNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeNumber', Sort.asc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  sortByEpisodeNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeNumber', Sort.desc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  sortByOverview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.asc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  sortByOverviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.desc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  sortByStillUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stillUrl', Sort.asc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  sortByStillUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stillUrl', Sort.desc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  sortByTmdbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.asc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  sortByTmdbIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.desc);
    });
  }
}

extension EpisodeMetadataEntityQuerySortThenBy
    on QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QSortThenBy> {
  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenByAirDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'airDate', Sort.asc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenByAirDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'airDate', Sort.desc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenByEpisodeNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeNumber', Sort.asc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenByEpisodeNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeNumber', Sort.desc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenByOverview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.asc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenByOverviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.desc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenByStillUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stillUrl', Sort.asc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenByStillUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stillUrl', Sort.desc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenByTmdbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.asc);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QAfterSortBy>
  thenByTmdbIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.desc);
    });
  }
}

extension EpisodeMetadataEntityQueryWhereDistinct
    on QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QDistinct> {
  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QDistinct>
  distinctByAirDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'airDate');
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QDistinct>
  distinctByEpisodeNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeNumber');
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QDistinct>
  distinctByOverview({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overview', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QDistinct>
  distinctByStillUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stillUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QDistinct>
  distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeMetadataEntity, EpisodeMetadataEntity, QDistinct>
  distinctByTmdbId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tmdbId', caseSensitive: caseSensitive);
    });
  }
}

extension EpisodeMetadataEntityQueryProperty
    on
        QueryBuilder<
          EpisodeMetadataEntity,
          EpisodeMetadataEntity,
          QQueryProperty
        > {
  QueryBuilder<EpisodeMetadataEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EpisodeMetadataEntity, DateTime?, QQueryOperations>
  airDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'airDate');
    });
  }

  QueryBuilder<EpisodeMetadataEntity, int, QQueryOperations>
  episodeNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeNumber');
    });
  }

  QueryBuilder<EpisodeMetadataEntity, List<ArtistEmbedded>, QQueryOperations>
  guestStarsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guestStars');
    });
  }

  QueryBuilder<EpisodeMetadataEntity, String?, QQueryOperations>
  overviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overview');
    });
  }

  QueryBuilder<EpisodeMetadataEntity, String?, QQueryOperations>
  stillUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stillUrl');
    });
  }

  QueryBuilder<EpisodeMetadataEntity, String, QQueryOperations>
  titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<EpisodeMetadataEntity, String, QQueryOperations>
  tmdbIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tmdbId');
    });
  }
}
