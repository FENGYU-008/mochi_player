/// 文件名解析结果
///
/// 从文件名中提取的所有信息，用于填充 MediaFileEntity
class ParsedResult {
  // ===== 基础信息 =====

  /// 解析后的标题（用于 TMDB 搜索）
  final String title;

  /// 年份
  final int? year;

  /// 季号（剧集用）
  final int? season;

  /// 集号（剧集用）
  final int? episode;

  /// 是否为剧集
  final bool isEpisode;

  /// 从路径中提取的 TMDB ID（如 {tmdbid-12345}）
  final String? tmdbId;

  // ===== 技术信息 =====

  /// 容器格式 (mkv, mp4, avi)
  final String? container;

  /// 分辨率标签 (720p, 1080p, 2160p, 4K)
  final String? resolution;

  /// 从分辨率推算的高度像素
  final int? height;

  /// 视频编码 (hevc, h264, x264, x265, av1)
  final String? videoCodec;

  /// 音频编码 (aac, dts, truehd, atmos, flac)
  final String? audioCodec;

  /// 音频声道 (2.0, 5.1, 7.1)
  final String? audioChannels;

  /// 是否 HDR
  final bool isHdr;

  /// HDR 格式 (hdr10, hdr10plus, dolby_vision)
  final String? hdrFormat;

  /// 来源 (bluray, webdl, webrip, hdtv, remux)
  final String? source;

  /// 版本标签（组合的技术信息，如 "1080p BluRay DTS"）
  final String versionLabel;

  const ParsedResult({
    required this.title,
    this.year,
    this.season,
    this.episode,
    this.isEpisode = false,
    this.tmdbId,
    this.container,
    this.resolution,
    this.height,
    this.videoCodec,
    this.audioCodec,
    this.audioChannels,
    this.isHdr = false,
    this.hdrFormat,
    this.source,
    this.versionLabel = '',
  });

  @override
  String toString() {
    return 'ParsedResult(title: $title, year: $year, S${season}E$episode, '
        'container: $container, resolution: $resolution, videoCodec: $videoCodec, '
        'audioCodec: $audioCodec, isHdr: $isHdr)';
  }
}

/// 文件名解析器
///
/// 从视频文件名中提取标题、年份、季集号、技术规格等信息
class FileNameParser {
  // ===== 正则表达式模式 =====

  // 季集号: S01E05, S01.E05, Season 1 Episode 5
  static final _seasonEpisodePattern = RegExp(
    r'[.\s_\[\(](?:S|Season\s?)(\d{1,2})[.\s_]?(?:E|Episode\s?)(\d{1,3})[.\s_\]\)]?',
    caseSensitive: false,
  );

  // 年份: (2024), .2024., _2024_
  static final _yearPattern = RegExp(r'[.\s_\(\[](\d{4})[.\s_\)\]]');

  // TMDB ID: {tmdbid-12345}
  static final _tmdbIdPattern = RegExp(
    r'\{tmdb(?:id)?[=-](\d+)\}',
    caseSensitive: false,
  );

  // 分辨率
  static final _resolutionPattern = RegExp(
    r'\b(720p|1080p|2160p|4k|uhd)\b',
    caseSensitive: false,
  );

  // 视频编码
  static final _videoCodecPattern = RegExp(
    r'\b(hevc|h\.?265|x265|h\.?264|x264|avc|av1|vp9|mpeg[24]?)\b',
    caseSensitive: false,
  );

  // 音频编码 (包括带声道的格式如 DDP5.1)
  static final _audioCodecPattern = RegExp(
    r'\b(aac|ac3|eac3|e-ac-3|dts(?:-hd)?(?:-ma)?|truehd|atmos|flac|opus|pcm|lpcm|dd\+?|ddp?)((?:5\.1|7\.1|2\.0)?)?\b',
    caseSensitive: false,
  );

  // 音频声道 (独立的声道标识，如 "5.1" 或 "DTS 5.1")
  static final _audioChannelsPattern = RegExp(
    r'(?<!\w)(2\.0|5\.1|7\.1|stereo|mono)(?!\d)',
    caseSensitive: false,
  );

  // HDR 格式
  static final _hdrPattern = RegExp(
    r'\b(hdr10\+?|hdr|dolby\s?vision|dv|dovi|hlg)\b',
    caseSensitive: false,
  );

  // 来源
  static final _sourcePattern = RegExp(
    r'\b(bluray|blu-ray|bdrip|brrip|remux|webdl|web-dl|webrip|web|hdtv|dvdrip|hdcam|cam|ts|tc)\b',
    caseSensitive: false,
  );

  // 视频扩展名
  static const _videoExtensions = {
    'mp4',
    'mkv',
    'avi',
    'mov',
    'wmv',
    'flv',
    'webm',
    'ts',
    'm2ts',
    'mpg',
    'mpeg',
  };

  /// 解析文件名
  static ParsedResult parse({required String fileName, String? filePath}) {
    // 提取容器格式（扩展名）
    String? container;
    if (fileName.contains('.')) {
      final ext = fileName.split('.').last.toLowerCase();
      if (_videoExtensions.contains(ext)) {
        container = ext;
      }
    }

    // 提取季集号
    int? season;
    int? episode;
    bool isEpisode = false;
    String nameForTitle = fileName;

    final seMatch = _seasonEpisodePattern.firstMatch(fileName);
    if (seMatch != null) {
      season = int.tryParse(seMatch.group(1)!);
      episode = int.tryParse(seMatch.group(2)!);
      isEpisode = season != null && episode != null;
      nameForTitle = fileName.substring(0, seMatch.start);
    }

    // 提取年份
    int? year;
    for (final match in _yearPattern.allMatches(fileName)) {
      final y = int.parse(match.group(1)!);
      if (y >= 1900 && y <= 2100) {
        year = y;
        // 如果年份在标题区域内，更新标题截取位置
        if (match.start < nameForTitle.length) {
          nameForTitle = fileName.substring(0, match.start);
        }
        break;
      }
    }

    // 清理标题
    String title = nameForTitle
        .replaceAll(RegExp(r'[._\[\]]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[\(\)\-]'), '')
        .trim();
    if (title.isEmpty) title = fileName;

    // 提取 TMDB ID（从文件路径）
    String? tmdbId;
    if (filePath != null) {
      final tmdbMatch = _tmdbIdPattern.firstMatch(filePath);
      tmdbId = tmdbMatch?.group(1);
    }

    // 提取分辨率
    String? resolution;
    int? height;
    final resMatch = _resolutionPattern.firstMatch(fileName);
    if (resMatch != null) {
      resolution = resMatch.group(1)!.toLowerCase();
      height = _parseResolutionToHeight(resolution);
    }

    // 提取视频编码
    String? videoCodec;
    final videoMatch = _videoCodecPattern.firstMatch(fileName);
    if (videoMatch != null) {
      videoCodec = _normalizeVideoCodec(videoMatch.group(1)!);
    }

    // 提取音频编码和可能嵌入的声道 (如 DDP5.1)
    String? audioCodec;
    String? embeddedChannels;
    final audioMatch = _audioCodecPattern.firstMatch(fileName);
    if (audioMatch != null) {
      audioCodec = _normalizeAudioCodec(audioMatch.group(1)!);
      // 检查是否有嵌入的声道信息 (group 2)
      if (audioMatch.group(2) != null && audioMatch.group(2)!.isNotEmpty) {
        embeddedChannels = audioMatch.group(2)!;
      }
    }

    // 提取音频声道 (独立的或从编码中嵌入的)
    String? audioChannels = embeddedChannels;
    if (audioChannels == null) {
      final channelsMatch = _audioChannelsPattern.firstMatch(fileName);
      if (channelsMatch != null) {
        audioChannels = _normalizeAudioChannels(channelsMatch.group(1)!);
      }
    }

    // 提取 HDR 信息
    bool isHdr = false;
    String? hdrFormat;
    final hdrMatch = _hdrPattern.firstMatch(fileName);
    if (hdrMatch != null) {
      isHdr = true;
      hdrFormat = _normalizeHdrFormat(hdrMatch.group(1)!);
    }

    // 提取来源
    String? source;
    final sourceMatch = _sourcePattern.firstMatch(fileName);
    if (sourceMatch != null) {
      source = _normalizeSource(sourceMatch.group(1)!);
    }

    // 构建版本标签
    final versionLabel = _buildVersionLabel(
      resolution: resolution,
      source: source,
      videoCodec: videoCodec,
      audioCodec: audioCodec,
      hdrFormat: hdrFormat,
    );

    return ParsedResult(
      title: title,
      year: year,
      season: season,
      episode: episode,
      isEpisode: isEpisode,
      tmdbId: tmdbId,
      container: container,
      resolution: resolution,
      height: height,
      videoCodec: videoCodec,
      audioCodec: audioCodec,
      audioChannels: audioChannels,
      isHdr: isHdr,
      hdrFormat: hdrFormat,
      source: source,
      versionLabel: versionLabel,
    );
  }

  // ===== 辅助方法 =====

  static int? _parseResolutionToHeight(String resolution) {
    switch (resolution.toLowerCase()) {
      case '720p':
        return 720;
      case '1080p':
        return 1080;
      case '2160p':
      case '4k':
      case 'uhd':
        return 2160;
      default:
        return null;
    }
  }

  static String _normalizeVideoCodec(String codec) {
    final c = codec.toLowerCase().replaceAll('.', '');
    if (c.contains('265') || c == 'hevc') return 'hevc';
    if (c.contains('264') || c == 'avc') return 'h264';
    if (c == 'av1') return 'av1';
    if (c == 'vp9') return 'vp9';
    return c;
  }

  static String _normalizeAudioCodec(String codec) {
    final c = codec.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
    if (c.contains('truehd')) return 'truehd';
    if (c.contains('atmos')) return 'atmos';
    if (c.contains('dtshd') || c.contains('dtshdma')) return 'dts-hd';
    if (c.contains('dts')) return 'dts';
    if (c.contains('eac3') || c == 'ddp' || c.contains('dd+')) return 'eac3';
    if (c.contains('ac3') || c == 'dd') return 'ac3';
    if (c == 'aac') return 'aac';
    if (c == 'flac') return 'flac';
    if (c == 'opus') return 'opus';
    return c;
  }

  static String _normalizeAudioChannels(String channels) {
    final c = channels.toLowerCase();
    if (c == 'stereo') return '2.0';
    if (c == 'mono') return '1.0';
    return c; // 2.0, 5.1, 7.1
  }

  static String _normalizeHdrFormat(String hdr) {
    final h = hdr.toLowerCase().replaceAll(' ', '');
    if (h.contains('dolbyvision') || h == 'dv' || h == 'dovi') {
      return 'dolby_vision';
    }
    if (h.contains('hdr10+') || h == 'hdr10plus') return 'hdr10plus';
    if (h == 'hdr10') return 'hdr10';
    if (h == 'hdr') return 'hdr';
    if (h == 'hlg') return 'hlg';
    return h;
  }

  static String _normalizeSource(String source) {
    final s = source.toLowerCase().replaceAll('-', '');
    if (s.contains('bluray') || s == 'bdrip' || s == 'brrip') return 'bluray';
    if (s == 'remux') return 'remux';
    if (s.contains('webdl')) return 'webdl';
    if (s.contains('webrip') || s == 'web') return 'webrip';
    if (s == 'hdtv') return 'hdtv';
    if (s.contains('dvd')) return 'dvdrip';
    return s;
  }

  static String _buildVersionLabel({
    String? resolution,
    String? source,
    String? videoCodec,
    String? audioCodec,
    String? hdrFormat,
  }) {
    final parts = <String>[];
    if (resolution != null) parts.add(resolution.toUpperCase());
    if (source != null) parts.add(_formatSource(source));
    if (videoCodec != null) parts.add(videoCodec.toUpperCase());
    if (hdrFormat != null) parts.add(_formatHdr(hdrFormat));
    if (audioCodec != null) parts.add(audioCodec.toUpperCase());
    return parts.join(' ');
  }

  static String _formatSource(String source) {
    switch (source) {
      case 'bluray':
        return 'BluRay';
      case 'remux':
        return 'REMUX';
      case 'webdl':
        return 'WEB-DL';
      case 'webrip':
        return 'WEBRip';
      default:
        return source.toUpperCase();
    }
  }

  static String _formatHdr(String hdr) {
    switch (hdr) {
      case 'dolby_vision':
        return 'DV';
      case 'hdr10plus':
        return 'HDR10+';
      case 'hdr10':
        return 'HDR10';
      default:
        return hdr.toUpperCase();
    }
  }
}
