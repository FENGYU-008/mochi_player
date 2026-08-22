import 'package:mochi_player/features/library/infrastructure/filename_parser.dart';

void main() {
  _parsesCommonEpisodeFilenames();
  _usesSeasonFolders();
  _infersSeasonOneForEpisodeOnlyFiles();
  _usesParentTitleForTaggedEpisodeOnlyFiles();
  _usesMovieFolderTitleAndYear();
  _parsesShortMovieTitlesWithTechnicalTags();
}

void _parsesCommonEpisodeFilenames() {
  final cases = [
    _ExpectedParse(
      '怪奇物语.S05E04.2016.2160p.WEB-DL.Netflix.DV.H.265.DDP.5.1.Atmos-JZMM.mkv',
      title: '怪奇物语',
      year: 2016,
      season: 5,
      episode: 4,
      container: 'mkv',
      height: 2160,
    ),
    _ExpectedParse(
      'Pluribus.S01E02.2160p.ATVP.WEB-DL.DDP5.1.Atmos.DV.H.265.mkv',
      title: 'Pluribus',
      season: 1,
      episode: 2,
      container: 'mkv',
      height: 2160,
    ),
    _ExpectedParse(
      '我的大叔.2018.S01E14.2160p.WEB-DL.High Frame Rate.H.265.AAC.mkv',
      title: '我的大叔',
      year: 2018,
      season: 1,
      episode: 14,
      container: 'mkv',
      height: 2160,
    ),
  ];

  for (final testCase in cases) {
    final result = FilenameParser.parse(fileName: testCase.fileName);
    _expectParse(result, testCase);
  }
}

void _usesSeasonFolders() {
  final cases = [
    _ExpectedParse(
      '进击的巨人01.mp4',
      path: '/media/进击的巨人/进击的巨人 S01/进击的巨人01.mp4',
      title: '进击的巨人',
      season: 1,
      episode: 1,
      container: 'mp4',
    ),
    _ExpectedParse(
      '1.mp4',
      path: '/media/进击的巨人/第一季/1.mp4',
      title: '进击的巨人',
      season: 1,
      episode: 1,
      container: 'mp4',
    ),
    _ExpectedParse(
      '第3集.mkv',
      path: '/media/进击的巨人/第十二季/第3集.mkv',
      title: '进击的巨人',
      season: 12,
      episode: 3,
      container: 'mkv',
    ),
  ];

  for (final testCase in cases) {
    final result = FilenameParser.parse(
      fileName: testCase.fileName,
      filePath: testCase.path,
    );
    _expectParse(result, testCase);
  }
}

void _infersSeasonOneForEpisodeOnlyFiles() {
  final result = FilenameParser.parse(
    fileName: '01.mp4',
    filePath: '/media/进击的巨人/01.mp4',
  );

  _expectEquals(result.title, '进击的巨人', 'title');
  _expectEquals(result.season, 1, 'season');
  _expectEquals(result.episode, 1, 'episode');
  _expectEquals(result.isEpisode, true, 'isEpisode');
}

void _usesParentTitleForTaggedEpisodeOnlyFiles() {
  for (var episode = 1; episode <= 6; episode++) {
    final episodeLabel = episode.toString().padLeft(2, '0');
    final fileName = '【tvzongheba】E$episodeLabel.mkv';
    final result = FilenameParser.parse(
      fileName: fileName,
      filePath: '/dav/quark/来自：分享/街头餐厅斗士/$fileName',
    );

    _expectEquals(result.title, '街头餐厅斗士', 'title');
    _expectEquals(result.season, 1, 'season');
    _expectEquals(result.episode, episode, 'episode');
    _expectEquals(result.isEpisode, true, 'isEpisode');
  }
}

void _usesMovieFolderTitleAndYear() {
  final result = FilenameParser.parse(
    fileName: 'movie.mkv',
    filePath: '/media/Movies/Inception (2010)/movie.mkv',
  );

  _expectEquals(result.title, 'Inception', 'title');
  _expectEquals(result.year, 2010, 'year');
  _expectEquals(result.isEpisode, false, 'isEpisode');
}

void _parsesShortMovieTitlesWithTechnicalTags() {
  final result = FilenameParser.parse(
    fileName:
        'Saw.2004.2160p.BluRay.REMUX.DV.HDR.HEVC.DTS-HD.MA.TrueHD.7.1.Atmos.mkv',
    filePath:
        '/quark/来自：分享/电锯惊魂系列/电锯惊魂1 4K原盘REMUX 杜比视界 内封字幕/Saw.2004.2160p.BluRay.REMUX.DV.HDR.HEVC.DTS-HD.MA.TrueHD.7.1.Atmos.mkv',
  );

  _expectEquals(result.title, 'Saw', 'title');
  _expectEquals(result.year, 2004, 'year');
  _expectEquals(result.height, 2160, 'height');
  _expectEquals(result.container, 'mkv', 'container');
  _expectEquals(result.isEpisode, false, 'isEpisode');
}

void _expectParse(ParsedMediaFilename result, _ExpectedParse expected) {
  _expectEquals(result.title, expected.title, 'title');
  _expectEquals(result.year, expected.year, 'year');
  _expectEquals(result.season, expected.season, 'season');
  _expectEquals(result.episode, expected.episode, 'episode');
  _expectEquals(
    result.isEpisode,
    expected.season != null || expected.episode != null,
    'isEpisode',
  );
  _expectEquals(result.container, expected.container, 'container');
  _expectEquals(result.height, expected.height, 'height');
}

void _expectEquals(Object? actual, Object? expected, String field) {
  if (actual == expected) return;
  throw StateError('Expected $field to be "$expected", got "$actual".');
}

class _ExpectedParse {
  final String fileName;
  final String? path;
  final String title;
  final int? year;
  final int? season;
  final int? episode;
  final String? container;
  final int? height;

  const _ExpectedParse(
    this.fileName, {
    this.path,
    required this.title,
    this.year,
    this.season,
    this.episode,
    this.container,
    this.height,
  });
}
