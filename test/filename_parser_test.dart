// 测试 FileNameParser 的解析结果
// 运行方式: dart run test/filename_parser_test.dart

import '../lib/utils/filename_parser.dart';

void main() {
  final testCases = [
    '怪奇物语.S05E04.2016.2160p.WEB-DL.Netflix.DV.H.265.DDP.5.1.Atmos-JZMM.mkv',
    '长安的荔枝.The Lychee Road.2025.2160p.WEB-DL.WEB-DL.DoVi.DoVi.DTS 5.1.H.265.10-bit.mp4',
    'Pluribus.S01E02.2160p.ATVP.WEB-DL.DDP5.1.Atmos.DV.H.265.mkv',
    '我的大叔.2018.S01E14.2160p.WEB-DL.High Frame Rate.H.265.AAC.mkv',
    '孤单又灿烂的神：鬼怪.2016.S01E16.死生契阔 与子成说.1080p.BluRay.Remux.PCM.2.0.AVC.mkv',
    '黑白厨师Culinary.Class.Wars.S01E08.2024.1080p.NF.WEB-DL.x264.DDP5.1.mkv',
  ];

  for (int i = 0; i < testCases.length; i++) {
    final fileName = testCases[i];
    final result = FileNameParser.parse(fileName: fileName);

    print('\n${'=' * 60}');
    print('【测试 ${i + 1}】$fileName');
    print('${'=' * 60}');
    print('  标题:     ${result.title}');
    print('  年份:     ${result.year}');
    print('  季:       ${result.season}');
    print('  集:       ${result.episode}');
    print('  是否剧集: ${result.isEpisode}');
    print('  容器:     ${result.container}');
    print('  分辨率:   ${result.resolution} (height: ${result.height})');
    print('  视频编码: ${result.videoCodec}');
    print('  音频编码: ${result.audioCodec}');
    print('  声道:     ${result.audioChannels}');
    print('  HDR:      ${result.isHdr} (${result.hdrFormat})');
    print('  来源:     ${result.source}');
    print('  版本标签: ${result.versionLabel}');
  }
}
