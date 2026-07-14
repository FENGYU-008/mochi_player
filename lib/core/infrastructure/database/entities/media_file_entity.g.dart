// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_file_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMediaFileEntityCollection on Isar {
  IsarCollection<MediaFileEntity> get mediaFileEntitys => this.collection();
}

const MediaFileEntitySchema = CollectionSchema(
  name: r'MediaFileEntity',
  id: 2590322350842057062,
  properties: {
    r'addedAt': PropertySchema(
      id: 0,
      name: r'addedAt',
      type: IsarType.dateTime,
    ),
    r'audioChannels': PropertySchema(
      id: 1,
      name: r'audioChannels',
      type: IsarType.string,
    ),
    r'audioCodec': PropertySchema(
      id: 2,
      name: r'audioCodec',
      type: IsarType.string,
    ),
    r'container': PropertySchema(
      id: 3,
      name: r'container',
      type: IsarType.string,
    ),
    r'duration': PropertySchema(id: 4, name: r'duration', type: IsarType.long),
    r'fileName': PropertySchema(
      id: 5,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'hdrFormat': PropertySchema(
      id: 6,
      name: r'hdrFormat',
      type: IsarType.string,
    ),
    r'height': PropertySchema(id: 7, name: r'height', type: IsarType.long),
    r'isFavorite': PropertySchema(
      id: 8,
      name: r'isFavorite',
      type: IsarType.bool,
    ),
    r'isHdr': PropertySchema(id: 9, name: r'isHdr', type: IsarType.bool),
    r'lastWatchedAt': PropertySchema(
      id: 10,
      name: r'lastWatchedAt',
      type: IsarType.dateTime,
    ),
    r'mediaType': PropertySchema(
      id: 11,
      name: r'mediaType',
      type: IsarType.byte,
      enumMap: _MediaFileEntitymediaTypeEnumValueMap,
    ),
    r'parsedEpisode': PropertySchema(
      id: 12,
      name: r'parsedEpisode',
      type: IsarType.long,
    ),
    r'parsedSeason': PropertySchema(
      id: 13,
      name: r'parsedSeason',
      type: IsarType.long,
    ),
    r'parsedTitle': PropertySchema(
      id: 14,
      name: r'parsedTitle',
      type: IsarType.string,
    ),
    r'parsedYear': PropertySchema(
      id: 15,
      name: r'parsedYear',
      type: IsarType.long,
    ),
    r'path': PropertySchema(id: 16, name: r'path', type: IsarType.string),
    r'position': PropertySchema(id: 17, name: r'position', type: IsarType.long),
    r'progress': PropertySchema(
      id: 18,
      name: r'progress',
      type: IsarType.double,
    ),
    r'quality': PropertySchema(id: 19, name: r'quality', type: IsarType.string),
    r'size': PropertySchema(id: 20, name: r'size', type: IsarType.long),
    r'tmdbId': PropertySchema(id: 21, name: r'tmdbId', type: IsarType.string),
    r'versionLabel': PropertySchema(
      id: 22,
      name: r'versionLabel',
      type: IsarType.string,
    ),
    r'videoCodec': PropertySchema(
      id: 23,
      name: r'videoCodec',
      type: IsarType.string,
    ),
    r'watchStatus': PropertySchema(
      id: 24,
      name: r'watchStatus',
      type: IsarType.byte,
      enumMap: _MediaFileEntitywatchStatusEnumValueMap,
    ),
    r'width': PropertySchema(id: 25, name: r'width', type: IsarType.long),
  },
  estimateSize: _mediaFileEntityEstimateSize,
  serialize: _mediaFileEntitySerialize,
  deserialize: _mediaFileEntityDeserialize,
  deserializeProp: _mediaFileEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'path': IndexSchema(
      id: 8756705481922369689,
      name: r'path',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'path',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'tmdbId': IndexSchema(
      id: 7174867214654401712,
      name: r'tmdbId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tmdbId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'watchStatus': IndexSchema(
      id: 419880354707165378,
      name: r'watchStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'watchStatus',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'lastWatchedAt': IndexSchema(
      id: -1422841304862671720,
      name: r'lastWatchedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastWatchedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'isFavorite': IndexSchema(
      id: 5742774614603939776,
      name: r'isFavorite',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isFavorite',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'addedAt': IndexSchema(
      id: -8595779697745674092,
      name: r'addedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'addedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _mediaFileEntityGetId,
  getLinks: _mediaFileEntityGetLinks,
  attach: _mediaFileEntityAttach,
  version: '3.1.0+1',
);

int _mediaFileEntityEstimateSize(
  MediaFileEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.audioChannels;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.audioCodec;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.container;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.fileName.length * 3;
  {
    final value = object.hdrFormat;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.parsedTitle.length * 3;
  bytesCount += 3 + object.path.length * 3;
  bytesCount += 3 + object.quality.length * 3;
  {
    final value = object.tmdbId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.versionLabel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.videoCodec;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _mediaFileEntitySerialize(
  MediaFileEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.addedAt);
  writer.writeString(offsets[1], object.audioChannels);
  writer.writeString(offsets[2], object.audioCodec);
  writer.writeString(offsets[3], object.container);
  writer.writeLong(offsets[4], object.duration);
  writer.writeString(offsets[5], object.fileName);
  writer.writeString(offsets[6], object.hdrFormat);
  writer.writeLong(offsets[7], object.height);
  writer.writeBool(offsets[8], object.isFavorite);
  writer.writeBool(offsets[9], object.isHdr);
  writer.writeDateTime(offsets[10], object.lastWatchedAt);
  writer.writeByte(offsets[11], object.mediaType.index);
  writer.writeLong(offsets[12], object.parsedEpisode);
  writer.writeLong(offsets[13], object.parsedSeason);
  writer.writeString(offsets[14], object.parsedTitle);
  writer.writeLong(offsets[15], object.parsedYear);
  writer.writeString(offsets[16], object.path);
  writer.writeLong(offsets[17], object.position);
  writer.writeDouble(offsets[18], object.progress);
  writer.writeString(offsets[19], object.quality);
  writer.writeLong(offsets[20], object.size);
  writer.writeString(offsets[21], object.tmdbId);
  writer.writeString(offsets[22], object.versionLabel);
  writer.writeString(offsets[23], object.videoCodec);
  writer.writeByte(offsets[24], object.watchStatus.index);
  writer.writeLong(offsets[25], object.width);
}

MediaFileEntity _mediaFileEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MediaFileEntity();
  object.addedAt = reader.readDateTime(offsets[0]);
  object.audioChannels = reader.readStringOrNull(offsets[1]);
  object.audioCodec = reader.readStringOrNull(offsets[2]);
  object.container = reader.readStringOrNull(offsets[3]);
  object.duration = reader.readLong(offsets[4]);
  object.fileName = reader.readString(offsets[5]);
  object.hdrFormat = reader.readStringOrNull(offsets[6]);
  object.height = reader.readLongOrNull(offsets[7]);
  object.id = id;
  object.isFavorite = reader.readBool(offsets[8]);
  object.isHdr = reader.readBool(offsets[9]);
  object.lastWatchedAt = reader.readDateTimeOrNull(offsets[10]);
  object.mediaType =
      _MediaFileEntitymediaTypeValueEnumMap[reader.readByteOrNull(
        offsets[11],
      )] ??
      MediaType.movie;
  object.parsedEpisode = reader.readLongOrNull(offsets[12]);
  object.parsedSeason = reader.readLongOrNull(offsets[13]);
  object.parsedTitle = reader.readString(offsets[14]);
  object.parsedYear = reader.readLongOrNull(offsets[15]);
  object.path = reader.readString(offsets[16]);
  object.position = reader.readLong(offsets[17]);
  object.size = reader.readLong(offsets[20]);
  object.tmdbId = reader.readStringOrNull(offsets[21]);
  object.versionLabel = reader.readStringOrNull(offsets[22]);
  object.videoCodec = reader.readStringOrNull(offsets[23]);
  object.watchStatus =
      _MediaFileEntitywatchStatusValueEnumMap[reader.readByteOrNull(
        offsets[24],
      )] ??
      WatchStatus.notStarted;
  object.width = reader.readLongOrNull(offsets[25]);
  return object;
}

P _mediaFileEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (_MediaFileEntitymediaTypeValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              MediaType.movie)
          as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readDouble(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readLong(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (_MediaFileEntitywatchStatusValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              WatchStatus.notStarted)
          as P;
    case 25:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MediaFileEntitymediaTypeEnumValueMap = {
  'movie': 0,
  'episode': 1,
  'unknown': 2,
};
const _MediaFileEntitymediaTypeValueEnumMap = {
  0: MediaType.movie,
  1: MediaType.episode,
  2: MediaType.unknown,
};
const _MediaFileEntitywatchStatusEnumValueMap = {
  'notStarted': 0,
  'watching': 1,
  'completed': 2,
};
const _MediaFileEntitywatchStatusValueEnumMap = {
  0: WatchStatus.notStarted,
  1: WatchStatus.watching,
  2: WatchStatus.completed,
};

Id _mediaFileEntityGetId(MediaFileEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mediaFileEntityGetLinks(MediaFileEntity object) {
  return [];
}

void _mediaFileEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  MediaFileEntity object,
) {
  object.id = id;
}

extension MediaFileEntityByIndex on IsarCollection<MediaFileEntity> {
  Future<MediaFileEntity?> getByPath(String path) {
    return getByIndex(r'path', [path]);
  }

  MediaFileEntity? getByPathSync(String path) {
    return getByIndexSync(r'path', [path]);
  }

  Future<bool> deleteByPath(String path) {
    return deleteByIndex(r'path', [path]);
  }

  bool deleteByPathSync(String path) {
    return deleteByIndexSync(r'path', [path]);
  }

  Future<List<MediaFileEntity?>> getAllByPath(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return getAllByIndex(r'path', values);
  }

  List<MediaFileEntity?> getAllByPathSync(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'path', values);
  }

  Future<int> deleteAllByPath(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'path', values);
  }

  int deleteAllByPathSync(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'path', values);
  }

  Future<Id> putByPath(MediaFileEntity object) {
    return putByIndex(r'path', object);
  }

  Id putByPathSync(MediaFileEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'path', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPath(List<MediaFileEntity> objects) {
    return putAllByIndex(r'path', objects);
  }

  List<Id> putAllByPathSync(
    List<MediaFileEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'path', objects, saveLinks: saveLinks);
  }
}

extension MediaFileEntityQueryWhereSort
    on QueryBuilder<MediaFileEntity, MediaFileEntity, QWhere> {
  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhere> anyWatchStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'watchStatus'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhere>
  anyLastWatchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastWatchedAt'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhere> anyIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isFavorite'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhere> anyAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'addedAt'),
      );
    });
  }
}

extension MediaFileEntityQueryWhere
    on QueryBuilder<MediaFileEntity, MediaFileEntity, QWhereClause> {
  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause> pathEqualTo(
    String path,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'path', value: [path]),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  pathNotEqualTo(String path) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'path',
                lower: [],
                upper: [path],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'path',
                lower: [path],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'path',
                lower: [path],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'path',
                lower: [],
                upper: [path],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  tmdbIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'tmdbId', value: [null]),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  tmdbIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'tmdbId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  tmdbIdEqualTo(String? tmdbId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'tmdbId', value: [tmdbId]),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  tmdbIdNotEqualTo(String? tmdbId) {
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  watchStatusEqualTo(WatchStatus watchStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'watchStatus',
          value: [watchStatus],
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  watchStatusNotEqualTo(WatchStatus watchStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'watchStatus',
                lower: [],
                upper: [watchStatus],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'watchStatus',
                lower: [watchStatus],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'watchStatus',
                lower: [watchStatus],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'watchStatus',
                lower: [],
                upper: [watchStatus],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  watchStatusGreaterThan(WatchStatus watchStatus, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'watchStatus',
          lower: [watchStatus],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  watchStatusLessThan(WatchStatus watchStatus, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'watchStatus',
          lower: [],
          upper: [watchStatus],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  watchStatusBetween(
    WatchStatus lowerWatchStatus,
    WatchStatus upperWatchStatus, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'watchStatus',
          lower: [lowerWatchStatus],
          includeLower: includeLower,
          upper: [upperWatchStatus],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  lastWatchedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'lastWatchedAt', value: [null]),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  lastWatchedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastWatchedAt',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  lastWatchedAtEqualTo(DateTime? lastWatchedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'lastWatchedAt',
          value: [lastWatchedAt],
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  lastWatchedAtNotEqualTo(DateTime? lastWatchedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastWatchedAt',
                lower: [],
                upper: [lastWatchedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastWatchedAt',
                lower: [lastWatchedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastWatchedAt',
                lower: [lastWatchedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastWatchedAt',
                lower: [],
                upper: [lastWatchedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  lastWatchedAtGreaterThan(DateTime? lastWatchedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastWatchedAt',
          lower: [lastWatchedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  lastWatchedAtLessThan(DateTime? lastWatchedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastWatchedAt',
          lower: [],
          upper: [lastWatchedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  lastWatchedAtBetween(
    DateTime? lowerLastWatchedAt,
    DateTime? upperLastWatchedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastWatchedAt',
          lower: [lowerLastWatchedAt],
          includeLower: includeLower,
          upper: [upperLastWatchedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  isFavoriteEqualTo(bool isFavorite) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'isFavorite', value: [isFavorite]),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  isFavoriteNotEqualTo(bool isFavorite) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isFavorite',
                lower: [],
                upper: [isFavorite],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isFavorite',
                lower: [isFavorite],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isFavorite',
                lower: [isFavorite],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isFavorite',
                lower: [],
                upper: [isFavorite],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  addedAtEqualTo(DateTime addedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'addedAt', value: [addedAt]),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  addedAtNotEqualTo(DateTime addedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'addedAt',
                lower: [],
                upper: [addedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'addedAt',
                lower: [addedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'addedAt',
                lower: [addedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'addedAt',
                lower: [],
                upper: [addedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  addedAtGreaterThan(DateTime addedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'addedAt',
          lower: [addedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  addedAtLessThan(DateTime addedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'addedAt',
          lower: [],
          upper: [addedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterWhereClause>
  addedAtBetween(
    DateTime lowerAddedAt,
    DateTime upperAddedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'addedAt',
          lower: [lowerAddedAt],
          includeLower: includeLower,
          upper: [upperAddedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension MediaFileEntityQueryFilter
    on QueryBuilder<MediaFileEntity, MediaFileEntity, QFilterCondition> {
  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  addedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'addedAt', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  addedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  addedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  addedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'addedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioChannelsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'audioChannels'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioChannelsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'audioChannels'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioChannelsEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'audioChannels',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioChannelsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'audioChannels',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioChannelsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'audioChannels',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioChannelsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'audioChannels',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioChannelsStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'audioChannels',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioChannelsEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'audioChannels',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioChannelsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'audioChannels',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioChannelsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'audioChannels',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioChannelsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'audioChannels', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioChannelsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'audioChannels', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioCodecIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'audioCodec'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioCodecIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'audioCodec'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioCodecEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'audioCodec',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioCodecGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'audioCodec',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioCodecLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'audioCodec',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioCodecBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'audioCodec',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioCodecStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'audioCodec',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioCodecEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'audioCodec',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioCodecContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'audioCodec',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioCodecMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'audioCodec',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioCodecIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'audioCodec', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  audioCodecIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'audioCodec', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  containerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'container'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  containerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'container'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  containerEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'container',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  containerGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'container',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  containerLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'container',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  containerBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'container',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  containerStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'container',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  containerEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'container',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  containerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'container',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  containerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'container',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  containerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'container', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  containerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'container', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  durationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'duration', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  durationGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'duration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  durationLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'duration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  durationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'duration',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  fileNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  fileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  fileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  fileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  fileNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  fileNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  fileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  fileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fileName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  hdrFormatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'hdrFormat'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  hdrFormatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'hdrFormat'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  hdrFormatEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hdrFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  hdrFormatGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hdrFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  hdrFormatLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hdrFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  hdrFormatBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hdrFormat',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  hdrFormatStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'hdrFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  hdrFormatEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'hdrFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  hdrFormatContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'hdrFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  hdrFormatMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'hdrFormat',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  hdrFormatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hdrFormat', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  hdrFormatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'hdrFormat', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  heightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'height'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  heightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'height'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  heightEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'height', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  heightGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'height',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  heightLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'height',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  heightBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'height',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  isFavoriteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isFavorite', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  isHdrEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isHdr', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  lastWatchedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastWatchedAt'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  lastWatchedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastWatchedAt'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  lastWatchedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastWatchedAt', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  lastWatchedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastWatchedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  lastWatchedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastWatchedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  lastWatchedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastWatchedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  mediaTypeEqualTo(MediaType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mediaType', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  mediaTypeGreaterThan(MediaType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mediaType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  mediaTypeLessThan(MediaType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mediaType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  mediaTypeBetween(
    MediaType lower,
    MediaType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mediaType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedEpisodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'parsedEpisode'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedEpisodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'parsedEpisode'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedEpisodeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parsedEpisode', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedEpisodeGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parsedEpisode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedEpisodeLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parsedEpisode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedEpisodeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parsedEpisode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedSeasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'parsedSeason'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedSeasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'parsedSeason'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedSeasonEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parsedSeason', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedSeasonGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parsedSeason',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedSeasonLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parsedSeason',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedSeasonBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parsedSeason',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedTitleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'parsedTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parsedTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parsedTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parsedTitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedTitleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'parsedTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedTitleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'parsedTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'parsedTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'parsedTitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parsedTitle', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'parsedTitle', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedYearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'parsedYear'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedYearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'parsedYear'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedYearEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parsedYear', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedYearGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parsedYear',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedYearLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parsedYear',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  parsedYearBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parsedYear',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  pathEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  pathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  pathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  pathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'path',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  pathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  pathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  pathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  pathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'path',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'path', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'path', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  positionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'position', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  positionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'position',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  positionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'position',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  positionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'position',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  progressEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'progress',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  progressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'progress',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  progressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'progress',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  progressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'progress',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  qualityEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'quality',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  qualityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quality',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  qualityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quality',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  qualityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quality',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  qualityStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'quality',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  qualityEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'quality',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  qualityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'quality',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  qualityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'quality',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  qualityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quality', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  qualityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'quality', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  sizeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'size', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  sizeGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'size',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  sizeLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'size',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  sizeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'size',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  tmdbIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'tmdbId'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  tmdbIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'tmdbId'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  tmdbIdEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  tmdbIdGreaterThan(
    String? value, {
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  tmdbIdLessThan(
    String? value, {
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  tmdbIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
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

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  tmdbIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tmdbId', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  tmdbIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tmdbId', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  versionLabelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'versionLabel'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  versionLabelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'versionLabel'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  versionLabelEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'versionLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  versionLabelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'versionLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  versionLabelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'versionLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  versionLabelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'versionLabel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  versionLabelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'versionLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  versionLabelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'versionLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  versionLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'versionLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  versionLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'versionLabel',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  versionLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'versionLabel', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  versionLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'versionLabel', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  videoCodecIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'videoCodec'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  videoCodecIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'videoCodec'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  videoCodecEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'videoCodec',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  videoCodecGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'videoCodec',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  videoCodecLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'videoCodec',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  videoCodecBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'videoCodec',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  videoCodecStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'videoCodec',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  videoCodecEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'videoCodec',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  videoCodecContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'videoCodec',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  videoCodecMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'videoCodec',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  videoCodecIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'videoCodec', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  videoCodecIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'videoCodec', value: ''),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  watchStatusEqualTo(WatchStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'watchStatus', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  watchStatusGreaterThan(WatchStatus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'watchStatus',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  watchStatusLessThan(WatchStatus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'watchStatus',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  watchStatusBetween(
    WatchStatus lower,
    WatchStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'watchStatus',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  widthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'width'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  widthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'width'),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  widthEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'width', value: value),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  widthGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'width',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  widthLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'width',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterFilterCondition>
  widthBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'width',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension MediaFileEntityQueryObject
    on QueryBuilder<MediaFileEntity, MediaFileEntity, QFilterCondition> {}

extension MediaFileEntityQueryLinks
    on QueryBuilder<MediaFileEntity, MediaFileEntity, QFilterCondition> {}

extension MediaFileEntityQuerySortBy
    on QueryBuilder<MediaFileEntity, MediaFileEntity, QSortBy> {
  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByAudioChannels() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioChannels', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByAudioChannelsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioChannels', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByAudioCodec() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioCodec', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByAudioCodecDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioCodec', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByContainer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'container', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByContainerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'container', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByHdrFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hdrFormat', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByHdrFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hdrFormat', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> sortByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> sortByIsHdr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHdr', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByIsHdrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHdr', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByLastWatchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWatchedAt', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByLastWatchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWatchedAt', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByParsedEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedEpisode', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByParsedEpisodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedEpisode', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByParsedSeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedSeason', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByParsedSeasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedSeason', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByParsedTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedTitle', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByParsedTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedTitle', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByParsedYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedYear', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByParsedYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedYear', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> sortByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> sortByQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quality', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quality', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> sortBySize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'size', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortBySizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'size', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> sortByTmdbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByTmdbIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByVersionLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'versionLabel', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByVersionLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'versionLabel', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByVideoCodec() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoCodec', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByVideoCodecDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoCodec', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByWatchStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'watchStatus', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByWatchStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'watchStatus', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> sortByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  sortByWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.desc);
    });
  }
}

extension MediaFileEntityQuerySortThenBy
    on QueryBuilder<MediaFileEntity, MediaFileEntity, QSortThenBy> {
  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByAudioChannels() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioChannels', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByAudioChannelsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioChannels', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByAudioCodec() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioCodec', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByAudioCodecDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioCodec', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByContainer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'container', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByContainerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'container', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByHdrFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hdrFormat', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByHdrFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hdrFormat', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> thenByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> thenByIsHdr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHdr', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByIsHdrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHdr', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByLastWatchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWatchedAt', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByLastWatchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWatchedAt', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByParsedEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedEpisode', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByParsedEpisodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedEpisode', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByParsedSeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedSeason', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByParsedSeasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedSeason', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByParsedTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedTitle', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByParsedTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedTitle', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByParsedYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedYear', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByParsedYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedYear', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> thenByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> thenByQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quality', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quality', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> thenBySize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'size', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenBySizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'size', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> thenByTmdbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByTmdbIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByVersionLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'versionLabel', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByVersionLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'versionLabel', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByVideoCodec() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoCodec', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByVideoCodecDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoCodec', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByWatchStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'watchStatus', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByWatchStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'watchStatus', Sort.desc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy> thenByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.asc);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QAfterSortBy>
  thenByWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.desc);
    });
  }
}

extension MediaFileEntityQueryWhereDistinct
    on QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct> {
  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByAudioChannels({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'audioChannels',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByAudioCodec({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioCodec', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByContainer({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'container', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct> distinctByFileName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByHdrFormat({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hdrFormat', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct> distinctByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'height');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct> distinctByIsHdr() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isHdr');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByLastWatchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastWatchedAt');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaType');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByParsedEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parsedEpisode');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByParsedSeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parsedSeason');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByParsedTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parsedTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByParsedYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parsedYear');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct> distinctByPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'position');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct> distinctByQuality({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quality', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct> distinctBySize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'size');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct> distinctByTmdbId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tmdbId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByVersionLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'versionLabel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByVideoCodec({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'videoCodec', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct>
  distinctByWatchStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'watchStatus');
    });
  }

  QueryBuilder<MediaFileEntity, MediaFileEntity, QDistinct> distinctByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'width');
    });
  }
}

extension MediaFileEntityQueryProperty
    on QueryBuilder<MediaFileEntity, MediaFileEntity, QQueryProperty> {
  QueryBuilder<MediaFileEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MediaFileEntity, DateTime, QQueryOperations> addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<MediaFileEntity, String?, QQueryOperations>
  audioChannelsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioChannels');
    });
  }

  QueryBuilder<MediaFileEntity, String?, QQueryOperations>
  audioCodecProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioCodec');
    });
  }

  QueryBuilder<MediaFileEntity, String?, QQueryOperations> containerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'container');
    });
  }

  QueryBuilder<MediaFileEntity, int, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<MediaFileEntity, String, QQueryOperations> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<MediaFileEntity, String?, QQueryOperations> hdrFormatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hdrFormat');
    });
  }

  QueryBuilder<MediaFileEntity, int?, QQueryOperations> heightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'height');
    });
  }

  QueryBuilder<MediaFileEntity, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<MediaFileEntity, bool, QQueryOperations> isHdrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isHdr');
    });
  }

  QueryBuilder<MediaFileEntity, DateTime?, QQueryOperations>
  lastWatchedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastWatchedAt');
    });
  }

  QueryBuilder<MediaFileEntity, MediaType, QQueryOperations>
  mediaTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaType');
    });
  }

  QueryBuilder<MediaFileEntity, int?, QQueryOperations>
  parsedEpisodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parsedEpisode');
    });
  }

  QueryBuilder<MediaFileEntity, int?, QQueryOperations> parsedSeasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parsedSeason');
    });
  }

  QueryBuilder<MediaFileEntity, String, QQueryOperations>
  parsedTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parsedTitle');
    });
  }

  QueryBuilder<MediaFileEntity, int?, QQueryOperations> parsedYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parsedYear');
    });
  }

  QueryBuilder<MediaFileEntity, String, QQueryOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }

  QueryBuilder<MediaFileEntity, int, QQueryOperations> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'position');
    });
  }

  QueryBuilder<MediaFileEntity, double, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<MediaFileEntity, String, QQueryOperations> qualityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quality');
    });
  }

  QueryBuilder<MediaFileEntity, int, QQueryOperations> sizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'size');
    });
  }

  QueryBuilder<MediaFileEntity, String?, QQueryOperations> tmdbIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tmdbId');
    });
  }

  QueryBuilder<MediaFileEntity, String?, QQueryOperations>
  versionLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'versionLabel');
    });
  }

  QueryBuilder<MediaFileEntity, String?, QQueryOperations>
  videoCodecProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'videoCodec');
    });
  }

  QueryBuilder<MediaFileEntity, WatchStatus, QQueryOperations>
  watchStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'watchStatus');
    });
  }

  QueryBuilder<MediaFileEntity, int?, QQueryOperations> widthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'width');
    });
  }
}
