// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tv_show_metadata_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTVShowMetadataEntityCollection on Isar {
  IsarCollection<TVShowMetadataEntity> get tVShowMetadataEntitys =>
      this.collection();
}

const TVShowMetadataEntitySchema = CollectionSchema(
  name: r'TVShowMetadataEntity',
  id: 1178599026096468220,
  properties: {
    r'backdropUrl': PropertySchema(
      id: 0,
      name: r'backdropUrl',
      type: IsarType.string,
    ),
    r'cast': PropertySchema(
      id: 1,
      name: r'cast',
      type: IsarType.objectList,
      target: r'ArtistEmbedded',
    ),
    r'certification': PropertySchema(
      id: 2,
      name: r'certification',
      type: IsarType.string,
    ),
    r'firstAirDate': PropertySchema(
      id: 3,
      name: r'firstAirDate',
      type: IsarType.dateTime,
    ),
    r'genres': PropertySchema(
      id: 4,
      name: r'genres',
      type: IsarType.stringList,
    ),
    r'logoUrl': PropertySchema(id: 5, name: r'logoUrl', type: IsarType.string),
    r'numberOfEpisodes': PropertySchema(
      id: 6,
      name: r'numberOfEpisodes',
      type: IsarType.long,
    ),
    r'numberOfSeasons': PropertySchema(
      id: 7,
      name: r'numberOfSeasons',
      type: IsarType.long,
    ),
    r'originalTitle': PropertySchema(
      id: 8,
      name: r'originalTitle',
      type: IsarType.string,
    ),
    r'overview': PropertySchema(
      id: 9,
      name: r'overview',
      type: IsarType.string,
    ),
    r'posterUrl': PropertySchema(
      id: 10,
      name: r'posterUrl',
      type: IsarType.string,
    ),
    r'rating': PropertySchema(id: 11, name: r'rating', type: IsarType.double),
    r'releaseYear': PropertySchema(
      id: 12,
      name: r'releaseYear',
      type: IsarType.long,
    ),
    r'status': PropertySchema(id: 13, name: r'status', type: IsarType.string),
    r'title': PropertySchema(id: 14, name: r'title', type: IsarType.string),
    r'tmdbId': PropertySchema(id: 15, name: r'tmdbId', type: IsarType.string),
  },
  estimateSize: _tVShowMetadataEntityEstimateSize,
  serialize: _tVShowMetadataEntitySerialize,
  deserialize: _tVShowMetadataEntityDeserialize,
  deserializeProp: _tVShowMetadataEntityDeserializeProp,
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
    r'seasons': LinkSchema(
      id: 5915743464547377751,
      name: r'seasons',
      target: r'SeasonMetadataEntity',
      single: false,
      linkName: r'tvShow',
    ),
  },
  embeddedSchemas: {r'ArtistEmbedded': ArtistEmbeddedSchema},
  getId: _tVShowMetadataEntityGetId,
  getLinks: _tVShowMetadataEntityGetLinks,
  attach: _tVShowMetadataEntityAttach,
  version: '3.1.0+1',
);

int _tVShowMetadataEntityEstimateSize(
  TVShowMetadataEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.backdropUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.cast.length * 3;
  {
    final offsets = allOffsets[ArtistEmbedded]!;
    for (var i = 0; i < object.cast.length; i++) {
      final value = object.cast[i];
      bytesCount += ArtistEmbeddedSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  {
    final value = object.certification;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.genres.length * 3;
  {
    for (var i = 0; i < object.genres.length; i++) {
      final value = object.genres[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.logoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.originalTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
  {
    final value = object.status;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.tmdbId.length * 3;
  return bytesCount;
}

void _tVShowMetadataEntitySerialize(
  TVShowMetadataEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.backdropUrl);
  writer.writeObjectList<ArtistEmbedded>(
    offsets[1],
    allOffsets,
    ArtistEmbeddedSchema.serialize,
    object.cast,
  );
  writer.writeString(offsets[2], object.certification);
  writer.writeDateTime(offsets[3], object.firstAirDate);
  writer.writeStringList(offsets[4], object.genres);
  writer.writeString(offsets[5], object.logoUrl);
  writer.writeLong(offsets[6], object.numberOfEpisodes);
  writer.writeLong(offsets[7], object.numberOfSeasons);
  writer.writeString(offsets[8], object.originalTitle);
  writer.writeString(offsets[9], object.overview);
  writer.writeString(offsets[10], object.posterUrl);
  writer.writeDouble(offsets[11], object.rating);
  writer.writeLong(offsets[12], object.releaseYear);
  writer.writeString(offsets[13], object.status);
  writer.writeString(offsets[14], object.title);
  writer.writeString(offsets[15], object.tmdbId);
}

TVShowMetadataEntity _tVShowMetadataEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TVShowMetadataEntity();
  object.backdropUrl = reader.readStringOrNull(offsets[0]);
  object.cast =
      reader.readObjectList<ArtistEmbedded>(
        offsets[1],
        ArtistEmbeddedSchema.deserialize,
        allOffsets,
        ArtistEmbedded(),
      ) ??
      [];
  object.certification = reader.readStringOrNull(offsets[2]);
  object.firstAirDate = reader.readDateTimeOrNull(offsets[3]);
  object.genres = reader.readStringList(offsets[4]) ?? [];
  object.id = id;
  object.logoUrl = reader.readStringOrNull(offsets[5]);
  object.numberOfEpisodes = reader.readLongOrNull(offsets[6]);
  object.numberOfSeasons = reader.readLongOrNull(offsets[7]);
  object.originalTitle = reader.readStringOrNull(offsets[8]);
  object.overview = reader.readStringOrNull(offsets[9]);
  object.posterUrl = reader.readStringOrNull(offsets[10]);
  object.rating = reader.readDouble(offsets[11]);
  object.releaseYear = reader.readLongOrNull(offsets[12]);
  object.status = reader.readStringOrNull(offsets[13]);
  object.title = reader.readString(offsets[14]);
  object.tmdbId = reader.readString(offsets[15]);
  return object;
}

P _tVShowMetadataEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readObjectList<ArtistEmbedded>(
                offset,
                ArtistEmbeddedSchema.deserialize,
                allOffsets,
                ArtistEmbedded(),
              ) ??
              [])
          as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tVShowMetadataEntityGetId(TVShowMetadataEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tVShowMetadataEntityGetLinks(
  TVShowMetadataEntity object,
) {
  return [object.seasons];
}

void _tVShowMetadataEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  TVShowMetadataEntity object,
) {
  object.id = id;
  object.seasons.attach(
    col,
    col.isar.collection<SeasonMetadataEntity>(),
    r'seasons',
    id,
  );
}

extension TVShowMetadataEntityByIndex on IsarCollection<TVShowMetadataEntity> {
  Future<TVShowMetadataEntity?> getByTmdbId(String tmdbId) {
    return getByIndex(r'tmdbId', [tmdbId]);
  }

  TVShowMetadataEntity? getByTmdbIdSync(String tmdbId) {
    return getByIndexSync(r'tmdbId', [tmdbId]);
  }

  Future<bool> deleteByTmdbId(String tmdbId) {
    return deleteByIndex(r'tmdbId', [tmdbId]);
  }

  bool deleteByTmdbIdSync(String tmdbId) {
    return deleteByIndexSync(r'tmdbId', [tmdbId]);
  }

  Future<List<TVShowMetadataEntity?>> getAllByTmdbId(
    List<String> tmdbIdValues,
  ) {
    final values = tmdbIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'tmdbId', values);
  }

  List<TVShowMetadataEntity?> getAllByTmdbIdSync(List<String> tmdbIdValues) {
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

  Future<Id> putByTmdbId(TVShowMetadataEntity object) {
    return putByIndex(r'tmdbId', object);
  }

  Id putByTmdbIdSync(TVShowMetadataEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'tmdbId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTmdbId(List<TVShowMetadataEntity> objects) {
    return putAllByIndex(r'tmdbId', objects);
  }

  List<Id> putAllByTmdbIdSync(
    List<TVShowMetadataEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'tmdbId', objects, saveLinks: saveLinks);
  }
}

extension TVShowMetadataEntityQueryWhereSort
    on QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QWhere> {
  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TVShowMetadataEntityQueryWhere
    on QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QWhereClause> {
  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterWhereClause>
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

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterWhereClause>
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

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterWhereClause>
  tmdbIdEqualTo(String tmdbId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'tmdbId', value: [tmdbId]),
      );
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterWhereClause>
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

extension TVShowMetadataEntityQueryFilter
    on
        QueryBuilder<
          TVShowMetadataEntity,
          TVShowMetadataEntity,
          QFilterCondition
        > {
  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  backdropUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'backdropUrl'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  backdropUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'backdropUrl'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  backdropUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'backdropUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  backdropUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'backdropUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  backdropUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'backdropUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  backdropUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'backdropUrl',
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  backdropUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'backdropUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  backdropUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'backdropUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  backdropUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'backdropUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  backdropUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'backdropUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  backdropUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'backdropUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  backdropUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'backdropUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  castLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cast', length, true, length, true);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  castIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cast', 0, true, 0, true);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  castIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cast', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  castLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cast', 0, true, length, include);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  castLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cast', length, include, 999999, true);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  castLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cast',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  certificationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'certification'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  certificationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'certification'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  certificationEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'certification',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  certificationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'certification',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  certificationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'certification',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  certificationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'certification',
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  certificationStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'certification',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  certificationEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'certification',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  certificationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'certification',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  certificationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'certification',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  certificationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'certification', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  certificationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'certification', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  firstAirDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'firstAirDate'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  firstAirDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'firstAirDate'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  firstAirDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'firstAirDate', value: value),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  firstAirDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'firstAirDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  firstAirDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'firstAirDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  firstAirDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'firstAirDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'genres',
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'genres',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'genres', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'genres', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'genres', length, true, length, true);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'genres', 0, true, 0, true);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'genres', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'genres', 0, true, length, include);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'genres', length, include, 999999, true);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  genresLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genres',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  logoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'logoUrl'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  logoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'logoUrl'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  logoUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'logoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  logoUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'logoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  logoUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'logoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  logoUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'logoUrl',
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  logoUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'logoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  logoUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'logoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  logoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'logoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  logoUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'logoUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  logoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'logoUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  logoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'logoUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  numberOfEpisodesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'numberOfEpisodes'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  numberOfEpisodesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'numberOfEpisodes'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  numberOfEpisodesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'numberOfEpisodes', value: value),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  numberOfEpisodesGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'numberOfEpisodes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  numberOfEpisodesLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'numberOfEpisodes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  numberOfEpisodesBetween(
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

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  numberOfSeasonsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'numberOfSeasons'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  numberOfSeasonsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'numberOfSeasons'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  numberOfSeasonsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'numberOfSeasons', value: value),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  numberOfSeasonsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'numberOfSeasons',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  numberOfSeasonsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'numberOfSeasons',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  numberOfSeasonsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'numberOfSeasons',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  originalTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'originalTitle'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  originalTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'originalTitle'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  originalTitleEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'originalTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  originalTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'originalTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  originalTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'originalTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  originalTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'originalTitle',
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  originalTitleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'originalTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  originalTitleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'originalTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  originalTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'originalTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  originalTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'originalTitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  originalTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'originalTitle', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  originalTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'originalTitle', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  posterUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'posterUrl'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  posterUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'posterUrl'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  posterUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'posterUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  posterUrlGreaterThan(
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

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  posterUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'posterUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  posterUrlBetween(
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

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  posterUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'posterUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  posterUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'posterUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  posterUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'posterUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  posterUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'posterUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  posterUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'posterUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  posterUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'posterUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  ratingEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rating',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  ratingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rating',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  ratingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rating',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  ratingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rating',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  releaseYearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'releaseYear'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  releaseYearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'releaseYear'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  releaseYearEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'releaseYear', value: value),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  releaseYearGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'releaseYear',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  releaseYearLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'releaseYear',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  releaseYearBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'releaseYear',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'status'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'status'),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  statusEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  statusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  statusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  statusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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
    TVShowMetadataEntity,
    TVShowMetadataEntity,
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

extension TVShowMetadataEntityQueryObject
    on
        QueryBuilder<
          TVShowMetadataEntity,
          TVShowMetadataEntity,
          QFilterCondition
        > {
  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  castElement(FilterQuery<ArtistEmbedded> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'cast');
    });
  }
}

extension TVShowMetadataEntityQueryLinks
    on
        QueryBuilder<
          TVShowMetadataEntity,
          TVShowMetadataEntity,
          QFilterCondition
        > {
  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  seasons(FilterQuery<SeasonMetadataEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'seasons');
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  seasonsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'seasons', length, true, length, true);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  seasonsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'seasons', 0, true, 0, true);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  seasonsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'seasons', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  seasonsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'seasons', 0, true, length, include);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  seasonsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'seasons', length, include, 999999, true);
    });
  }

  QueryBuilder<
    TVShowMetadataEntity,
    TVShowMetadataEntity,
    QAfterFilterCondition
  >
  seasonsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'seasons',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension TVShowMetadataEntityQuerySortBy
    on QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QSortBy> {
  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByBackdropUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdropUrl', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByBackdropUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdropUrl', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByCertification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certification', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByCertificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certification', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByFirstAirDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstAirDate', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByFirstAirDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstAirDate', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByLogoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoUrl', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByLogoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoUrl', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByNumberOfEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfEpisodes', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByNumberOfEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfEpisodes', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByNumberOfSeasons() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfSeasons', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByNumberOfSeasonsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfSeasons', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByOriginalTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalTitle', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByOriginalTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalTitle', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByOverview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByOverviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByPosterUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posterUrl', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByPosterUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posterUrl', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByReleaseYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseYear', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByReleaseYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseYear', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByTmdbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  sortByTmdbIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.desc);
    });
  }
}

extension TVShowMetadataEntityQuerySortThenBy
    on QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QSortThenBy> {
  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByBackdropUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdropUrl', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByBackdropUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdropUrl', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByCertification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certification', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByCertificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certification', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByFirstAirDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstAirDate', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByFirstAirDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstAirDate', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByLogoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoUrl', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByLogoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoUrl', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByNumberOfEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfEpisodes', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByNumberOfEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfEpisodes', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByNumberOfSeasons() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfSeasons', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByNumberOfSeasonsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfSeasons', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByOriginalTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalTitle', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByOriginalTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalTitle', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByOverview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByOverviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByPosterUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posterUrl', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByPosterUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posterUrl', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByReleaseYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseYear', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByReleaseYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseYear', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByTmdbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.asc);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QAfterSortBy>
  thenByTmdbIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.desc);
    });
  }
}

extension TVShowMetadataEntityQueryWhereDistinct
    on QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct> {
  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByBackdropUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backdropUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByCertification({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'certification',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByFirstAirDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstAirDate');
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByGenres() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genres');
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByLogoUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logoUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByNumberOfEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numberOfEpisodes');
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByNumberOfSeasons() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numberOfSeasons');
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByOriginalTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'originalTitle',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByOverview({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overview', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByPosterUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'posterUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rating');
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByReleaseYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'releaseYear');
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TVShowMetadataEntity, TVShowMetadataEntity, QDistinct>
  distinctByTmdbId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tmdbId', caseSensitive: caseSensitive);
    });
  }
}

extension TVShowMetadataEntityQueryProperty
    on
        QueryBuilder<
          TVShowMetadataEntity,
          TVShowMetadataEntity,
          QQueryProperty
        > {
  QueryBuilder<TVShowMetadataEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TVShowMetadataEntity, String?, QQueryOperations>
  backdropUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backdropUrl');
    });
  }

  QueryBuilder<TVShowMetadataEntity, List<ArtistEmbedded>, QQueryOperations>
  castProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cast');
    });
  }

  QueryBuilder<TVShowMetadataEntity, String?, QQueryOperations>
  certificationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'certification');
    });
  }

  QueryBuilder<TVShowMetadataEntity, DateTime?, QQueryOperations>
  firstAirDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstAirDate');
    });
  }

  QueryBuilder<TVShowMetadataEntity, List<String>, QQueryOperations>
  genresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genres');
    });
  }

  QueryBuilder<TVShowMetadataEntity, String?, QQueryOperations>
  logoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logoUrl');
    });
  }

  QueryBuilder<TVShowMetadataEntity, int?, QQueryOperations>
  numberOfEpisodesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numberOfEpisodes');
    });
  }

  QueryBuilder<TVShowMetadataEntity, int?, QQueryOperations>
  numberOfSeasonsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numberOfSeasons');
    });
  }

  QueryBuilder<TVShowMetadataEntity, String?, QQueryOperations>
  originalTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalTitle');
    });
  }

  QueryBuilder<TVShowMetadataEntity, String?, QQueryOperations>
  overviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overview');
    });
  }

  QueryBuilder<TVShowMetadataEntity, String?, QQueryOperations>
  posterUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'posterUrl');
    });
  }

  QueryBuilder<TVShowMetadataEntity, double, QQueryOperations>
  ratingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rating');
    });
  }

  QueryBuilder<TVShowMetadataEntity, int?, QQueryOperations>
  releaseYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'releaseYear');
    });
  }

  QueryBuilder<TVShowMetadataEntity, String?, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<TVShowMetadataEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<TVShowMetadataEntity, String, QQueryOperations>
  tmdbIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tmdbId');
    });
  }
}
