import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/domain/media/media_file.dart';
import 'package:mochi_player/core/ui/formatters/media_format.dart';

MediaFile _file({
  int size = 0,
  int duration = 0,
  int position = 0,
  int? season,
  int? episode,
  int? height,
  String? videoCodec,
  String? audioCodec,
  String? audioChannels,
  String? container,
  bool isHdr = false,
  String? hdrFormat,
  String? versionLabel,
}) => MediaFile(
  id: 1,
  path: '/media/item.mkv',
  fileName: 'item.mkv',
  parsedTitle: 'Item',
  parsedSeason: season,
  parsedEpisode: episode,
  size: size,
  duration: duration,
  position: position,
  height: height,
  videoCodec: videoCodec,
  audioCodec: audioCodec,
  audioChannels: audioChannels,
  container: container,
  isHdr: isHdr,
  hdrFormat: hdrFormat,
  versionLabel: versionLabel,
  addedAt: DateTime(2026),
);

void main() {
  test('formats file sizes consistently through terabytes', () {
    expect(MediaFormat.fileSize(0), isEmpty);
    expect(MediaFormat.fileSize(1023), '1023 B');
    expect(MediaFormat.fileSize(1024), '1.0 KB');
    expect(MediaFormat.fileSize(1024 * 1024 * 1024), '1.00 GB');
    expect(MediaFormat.fileSize(1024 * 1024 * 1024 * 1024), '1.00 TB');
  });

  test('formats clock, compact, and episode labels', () {
    expect(
      MediaFormat.clockDuration(
        const Duration(hours: 1, minutes: 2, seconds: 3),
      ),
      '1:02:03',
    );
    expect(MediaFormat.compactDuration(const Duration(minutes: 42)), '42m');
    expect(
      MediaFormat.episodeLabel(_file(season: 2, episode: 7)),
      '第 2 季 第 7 集',
    );
  });

  test('builds one canonical version title and subtitle', () {
    final file = _file(
      size: 1024 * 1024 * 1024,
      duration: 100000,
      position: 25000,
      height: 2160,
      videoCodec: 'HEVC',
      audioCodec: 'EAC3',
      audioChannels: '5.1',
      container: 'mkv',
      isHdr: true,
      hdrFormat: 'HDR10',
      versionLabel: '4K BluRay HEVC HDR10 EAC3',
    );

    expect(
      MediaFilePresentation.versionTitle(file),
      '4K BluRay HEVC HDR10 EAC3',
    );
    expect(
      MediaFilePresentation.versionSubtitle(file, includeResumePosition: true),
      'EAC3 • 5.1 • MKV • 1.00 GB • 从 00:25 继续',
    );
  });
}
