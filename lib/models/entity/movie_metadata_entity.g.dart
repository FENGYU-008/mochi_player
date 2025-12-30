// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_metadata_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMovieMetadataEntityCollection on Isar {
  IsarCollection<MovieMetadataEntity> get movieMetadataEntitys =>
      this.collection();
}

const MovieMetadataEntitySchema = CollectionSchema(
  name: r'MovieMetadataEntity',
  id: -1664830990599016952,
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
    r'genres': PropertySchema(
      id: 3,
      name: r'genres',
      type: IsarType.stringList,
    ),
    r'originalTitle': PropertySchema(
      id: 4,
      name: r'originalTitle',
      type: IsarType.string,
    ),
    r'overview': PropertySchema(
      id: 5,
      name: r'overview',
      type: IsarType.string,
    ),
    r'posterUrl': PropertySchema(
      id: 6,
      name: r'posterUrl',
      type: IsarType.string,
    ),
    r'rating': PropertySchema(
      id: 7,
      name: r'rating',
      type: IsarType.double,
    ),
    r'releaseDate': PropertySchema(
      id: 8,
      name: r'releaseDate',
      type: IsarType.dateTime,
    ),
    r'releaseYear': PropertySchema(
      id: 9,
      name: r'releaseYear',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 10,
      name: r'title',
      type: IsarType.string,
    ),
    r'tmdbId': PropertySchema(
      id: 11,
      name: r'tmdbId',
      type: IsarType.string,
    )
  },
  estimateSize: _movieMetadataEntityEstimateSize,
  serialize: _movieMetadataEntitySerialize,
  deserialize: _movieMetadataEntityDeserialize,
  deserializeProp: _movieMetadataEntityDeserializeProp,
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
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'ArtistEmbedded': ArtistEmbeddedSchema},
  getId: _movieMetadataEntityGetId,
  getLinks: _movieMetadataEntityGetLinks,
  attach: _movieMetadataEntityAttach,
  version: '3.1.0+1',
);

int _movieMetadataEntityEstimateSize(
  MovieMetadataEntity object,
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
      bytesCount +=
          ArtistEmbeddedSchema.estimateSize(value, offsets, allOffsets);
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
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.tmdbId.length * 3;
  return bytesCount;
}

void _movieMetadataEntitySerialize(
  MovieMetadataEntity object,
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
  writer.writeStringList(offsets[3], object.genres);
  writer.writeString(offsets[4], object.originalTitle);
  writer.writeString(offsets[5], object.overview);
  writer.writeString(offsets[6], object.posterUrl);
  writer.writeDouble(offsets[7], object.rating);
  writer.writeDateTime(offsets[8], object.releaseDate);
  writer.writeLong(offsets[9], object.releaseYear);
  writer.writeString(offsets[10], object.title);
  writer.writeString(offsets[11], object.tmdbId);
}

MovieMetadataEntity _movieMetadataEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MovieMetadataEntity();
  object.backdropUrl = reader.readStringOrNull(offsets[0]);
  object.cast = reader.readObjectList<ArtistEmbedded>(
        offsets[1],
        ArtistEmbeddedSchema.deserialize,
        allOffsets,
        ArtistEmbedded(),
      ) ??
      [];
  object.certification = reader.readStringOrNull(offsets[2]);
  object.genres = reader.readStringList(offsets[3]) ?? [];
  object.id = id;
  object.originalTitle = reader.readStringOrNull(offsets[4]);
  object.overview = reader.readStringOrNull(offsets[5]);
  object.posterUrl = reader.readStringOrNull(offsets[6]);
  object.rating = reader.readDouble(offsets[7]);
  object.releaseDate = reader.readDateTimeOrNull(offsets[8]);
  object.releaseYear = reader.readLongOrNull(offsets[9]);
  object.title = reader.readString(offsets[10]);
  object.tmdbId = reader.readString(offsets[11]);
  return object;
}

P _movieMetadataEntityDeserializeProp<P>(
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
          []) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _movieMetadataEntityGetId(MovieMetadataEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _movieMetadataEntityGetLinks(
    MovieMetadataEntity object) {
  return [];
}

void _movieMetadataEntityAttach(
    IsarCollection<dynamic> col, Id id, MovieMetadataEntity object) {
  object.id = id;
}

extension MovieMetadataEntityByIndex on IsarCollection<MovieMetadataEntity> {
  Future<MovieMetadataEntity?> getByTmdbId(String tmdbId) {
    return getByIndex(r'tmdbId', [tmdbId]);
  }

  MovieMetadataEntity? getByTmdbIdSync(String tmdbId) {
    return getByIndexSync(r'tmdbId', [tmdbId]);
  }

  Future<bool> deleteByTmdbId(String tmdbId) {
    return deleteByIndex(r'tmdbId', [tmdbId]);
  }

  bool deleteByTmdbIdSync(String tmdbId) {
    return deleteByIndexSync(r'tmdbId', [tmdbId]);
  }

  Future<List<MovieMetadataEntity?>> getAllByTmdbId(List<String> tmdbIdValues) {
    final values = tmdbIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'tmdbId', values);
  }

  List<MovieMetadataEntity?> getAllByTmdbIdSync(List<String> tmdbIdValues) {
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

  Future<Id> putByTmdbId(MovieMetadataEntity object) {
    return putByIndex(r'tmdbId', object);
  }

  Id putByTmdbIdSync(MovieMetadataEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'tmdbId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTmdbId(List<MovieMetadataEntity> objects) {
    return putAllByIndex(r'tmdbId', objects);
  }

  List<Id> putAllByTmdbIdSync(List<MovieMetadataEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'tmdbId', objects, saveLinks: saveLinks);
  }
}

extension MovieMetadataEntityQueryWhereSort
    on QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QWhere> {
  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MovieMetadataEntityQueryWhere
    on QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QWhereClause> {
  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterWhereClause>
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

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterWhereClause>
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

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterWhereClause>
      tmdbIdEqualTo(String tmdbId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tmdbId',
        value: [tmdbId],
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterWhereClause>
      tmdbIdNotEqualTo(String tmdbId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tmdbId',
              lower: [],
              upper: [tmdbId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tmdbId',
              lower: [tmdbId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tmdbId',
              lower: [tmdbId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tmdbId',
              lower: [],
              upper: [tmdbId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MovieMetadataEntityQueryFilter on QueryBuilder<MovieMetadataEntity,
    MovieMetadataEntity, QFilterCondition> {
  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      backdropUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'backdropUrl',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      backdropUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'backdropUrl',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      backdropUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backdropUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      backdropUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backdropUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      backdropUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backdropUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      backdropUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backdropUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      backdropUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'backdropUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      backdropUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'backdropUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      backdropUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'backdropUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      backdropUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'backdropUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      backdropUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backdropUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      backdropUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'backdropUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      castLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cast',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      castIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cast',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      castIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cast',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      castLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cast',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      castLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cast',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
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

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      certificationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'certification',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      certificationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'certification',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      certificationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'certification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      certificationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'certification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      certificationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'certification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      certificationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'certification',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      certificationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'certification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      certificationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'certification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      certificationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'certification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      certificationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'certification',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      certificationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'certification',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      certificationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'certification',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'genres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'genres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'genres',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'genres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'genres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'genres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'genres',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genres',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'genres',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genres',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genres',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genres',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genres',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      genresLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genres',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
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

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
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

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
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

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
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

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      originalTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'originalTitle',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      originalTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'originalTitle',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      originalTitleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      originalTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      originalTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      originalTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      originalTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      originalTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      originalTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      originalTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      originalTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      originalTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      overviewIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'overview',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      overviewIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'overview',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      overviewEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      overviewGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'overview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      overviewLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'overview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      overviewBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'overview',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      overviewStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'overview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      overviewEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'overview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      overviewContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'overview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      overviewMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'overview',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      overviewIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overview',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      overviewIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'overview',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      posterUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'posterUrl',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      posterUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'posterUrl',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      posterUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'posterUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      posterUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'posterUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      posterUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'posterUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      posterUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'posterUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      posterUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'posterUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      posterUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'posterUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      posterUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'posterUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      posterUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'posterUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      posterUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'posterUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      posterUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'posterUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      ratingEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rating',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      ratingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rating',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      ratingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rating',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      ratingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rating',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      releaseDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'releaseDate',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      releaseDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'releaseDate',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      releaseDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'releaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      releaseDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'releaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      releaseDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'releaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      releaseDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'releaseDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      releaseYearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'releaseYear',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      releaseYearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'releaseYear',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      releaseYearEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'releaseYear',
        value: value,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      releaseYearGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'releaseYear',
        value: value,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      releaseYearLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'releaseYear',
        value: value,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      releaseYearBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'releaseYear',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      tmdbIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tmdbId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      tmdbIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tmdbId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      tmdbIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tmdbId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      tmdbIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tmdbId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      tmdbIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tmdbId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      tmdbIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tmdbId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      tmdbIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tmdbId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      tmdbIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tmdbId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      tmdbIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tmdbId',
        value: '',
      ));
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      tmdbIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tmdbId',
        value: '',
      ));
    });
  }
}

extension MovieMetadataEntityQueryObject on QueryBuilder<MovieMetadataEntity,
    MovieMetadataEntity, QFilterCondition> {
  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterFilterCondition>
      castElement(FilterQuery<ArtistEmbedded> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'cast');
    });
  }
}

extension MovieMetadataEntityQueryLinks on QueryBuilder<MovieMetadataEntity,
    MovieMetadataEntity, QFilterCondition> {}

extension MovieMetadataEntityQuerySortBy
    on QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QSortBy> {
  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByBackdropUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdropUrl', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByBackdropUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdropUrl', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByCertification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certification', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByCertificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certification', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByOriginalTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalTitle', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByOriginalTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalTitle', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByOverview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByOverviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByPosterUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posterUrl', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByPosterUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posterUrl', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByReleaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseDate', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByReleaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseDate', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByReleaseYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseYear', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByReleaseYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseYear', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByTmdbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      sortByTmdbIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.desc);
    });
  }
}

extension MovieMetadataEntityQuerySortThenBy
    on QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QSortThenBy> {
  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByBackdropUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdropUrl', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByBackdropUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdropUrl', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByCertification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certification', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByCertificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certification', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByOriginalTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalTitle', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByOriginalTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalTitle', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByOverview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByOverviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overview', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByPosterUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posterUrl', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByPosterUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posterUrl', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByReleaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseDate', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByReleaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseDate', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByReleaseYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseYear', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByReleaseYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseYear', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByTmdbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.asc);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QAfterSortBy>
      thenByTmdbIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.desc);
    });
  }
}

extension MovieMetadataEntityQueryWhereDistinct
    on QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QDistinct> {
  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QDistinct>
      distinctByBackdropUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backdropUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QDistinct>
      distinctByCertification({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'certification',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QDistinct>
      distinctByGenres() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genres');
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QDistinct>
      distinctByOriginalTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalTitle',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QDistinct>
      distinctByOverview({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overview', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QDistinct>
      distinctByPosterUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'posterUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QDistinct>
      distinctByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rating');
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QDistinct>
      distinctByReleaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'releaseDate');
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QDistinct>
      distinctByReleaseYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'releaseYear');
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QDistinct>
      distinctByTmdbId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tmdbId', caseSensitive: caseSensitive);
    });
  }
}

extension MovieMetadataEntityQueryProperty
    on QueryBuilder<MovieMetadataEntity, MovieMetadataEntity, QQueryProperty> {
  QueryBuilder<MovieMetadataEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MovieMetadataEntity, String?, QQueryOperations>
      backdropUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backdropUrl');
    });
  }

  QueryBuilder<MovieMetadataEntity, List<ArtistEmbedded>, QQueryOperations>
      castProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cast');
    });
  }

  QueryBuilder<MovieMetadataEntity, String?, QQueryOperations>
      certificationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'certification');
    });
  }

  QueryBuilder<MovieMetadataEntity, List<String>, QQueryOperations>
      genresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genres');
    });
  }

  QueryBuilder<MovieMetadataEntity, String?, QQueryOperations>
      originalTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalTitle');
    });
  }

  QueryBuilder<MovieMetadataEntity, String?, QQueryOperations>
      overviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overview');
    });
  }

  QueryBuilder<MovieMetadataEntity, String?, QQueryOperations>
      posterUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'posterUrl');
    });
  }

  QueryBuilder<MovieMetadataEntity, double, QQueryOperations> ratingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rating');
    });
  }

  QueryBuilder<MovieMetadataEntity, DateTime?, QQueryOperations>
      releaseDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'releaseDate');
    });
  }

  QueryBuilder<MovieMetadataEntity, int?, QQueryOperations>
      releaseYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'releaseYear');
    });
  }

  QueryBuilder<MovieMetadataEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<MovieMetadataEntity, String, QQueryOperations> tmdbIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tmdbId');
    });
  }
}
