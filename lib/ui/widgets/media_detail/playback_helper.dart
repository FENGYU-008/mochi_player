import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mochi_player/models/domain/models.dart';
import 'package:mochi_player/providers/media_library_provider.dart';
import 'package:mochi_player/services/webdav_service.dart';
import 'package:mochi_player/ui/pages/player_page.dart';

class PlaybackHelper {
  static void playFile(
    BuildContext context,
    MediaFile file, {
    String? contextTitle,
    String? loadingMessage,
    String? failureMessage,
    List<MediaFile> playlist = const [],
  }) {
    _openPlayer(
      context,
      file,
      contextTitle: contextTitle,
      loadingMessage: loadingMessage,
      failureMessage: failureMessage,
      playlist: playlist,
    );
  }

  static void playLibraryItem(BuildContext context, Object item) {
    if (item is Movie) {
      playMovie(context, item);
      return;
    }

    if (item is TVShow) {
      playTVShow(context, item);
      return;
    }

    _showError(context, "不支持播放此资源");
  }

  /// 播放电影：查找文件并播放（支持多版本选择）
  static void playMovie(BuildContext context, Movie movie) {
    final provider = Provider.of<MediaLibraryProvider>(context, listen: false);
    final versions = provider.getVersions(movie.tmdbId);

    if (versions.isEmpty) {
      _showError(context, "未找到这部电影的本地文件");
      return;
    }

    if (versions.length > 1) {
      _showVersionPicker(context, versions);
    } else {
      _openPlayer(context, versions.first);
    }
  }

  /// 播放剧集：选择第一集本地文件并播放。
  static void playTVShow(BuildContext context, TVShow show) {
    final provider = Provider.of<MediaLibraryProvider>(context, listen: false);
    final versions = provider.getVersions(show.tmdbId);
    final targetFile = _firstPlayableEpisodeFile(versions);

    if (targetFile == null) {
      _showError(context, "未找到可播放剧集");
      return;
    }

    _openPlayer(context, targetFile, contextTitle: show.title);
  }

  /// 播放剧集：查找对应 Episode 的文件并播放
  static void playEpisode(
    BuildContext context,
    Episode episode, {
    required String showTitle,
  }) {
    final provider = Provider.of<MediaLibraryProvider>(context, listen: false);

    MediaFile? targetFile;
    try {
      targetFile = provider.mediaFiles.firstWhere(
        (f) => f.tmdbId == episode.tmdbId,
      );
    } catch (_) {}

    if (targetFile == null) {
      _showError(context, "未找到这一集的本地文件");
      return;
    }

    _openPlayer(context, targetFile, contextTitle: showTitle);
  }

  /// 核心播放逻辑：获取直链 -> 跳转 PlayerPage
  static void _openPlayer(
    BuildContext context,
    MediaFile file, {
    String? contextTitle,
    String? loadingMessage,
    String? failureMessage,
    List<MediaFile> playlist = const [],
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(width: 16),
            Expanded(child: Text(loadingMessage ?? "正在获取播放链接...")),
          ],
        ),
        duration: const Duration(minutes: 1),
      ),
    );

    final directLink = await WebDavService().getDirectLink(file.path);
    if (!context.mounted) return;

    messenger.hideCurrentSnackBar();

    if (directLink != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerPage(
            videoItem: file,
            url: directLink,
            contextTitle: contextTitle,
            playlist: playlist,
          ),
        ),
      );
    } else {
      _showError(context, failureMessage ?? "获取播放链接失败，请检查网络或服务器");
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  /// 版本选择弹窗
  static void _showVersionPicker(
    BuildContext context,
    List<MediaFile> versions,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext); // 获取 Sheet 的 Theme
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "选择版本",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: versions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final file = versions[index];
                  final label = _buildVersionLabel(file);
                  return ListTile(
                    leading: Icon(
                      Icons.movie_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      label.isNotEmpty ? label : file.fileName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _buildVersionSubtitle(file),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext); // 关闭 Sheet
                      _openPlayer(context, file); // 使用外部 context
                    },
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(sheetContext).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  static String _buildVersionLabel(MediaFile file) {
    return [
      file.quality,
      file.videoCodec,
      if (file.isHdr) file.hdrFormat ?? 'HDR',
    ].whereType<String>().where((s) => s.isNotEmpty).join(' • ');
  }

  static String _buildVersionSubtitle(MediaFile file) {
    final parts = <String>[];
    if (file.audioCodec != null) parts.add(file.audioCodec!);
    if (file.audioChannels != null) parts.add(file.audioChannels!);
    if (file.size > 0) parts.add(_formatFileSize(file.size));
    return parts.join(' • ');
  }

  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static MediaFile? _firstPlayableEpisodeFile(List<MediaFile> files) {
    final candidates = files
        .where((file) => file.mediaType == MediaType.episode)
        .toList();
    if (candidates.isEmpty) return files.isEmpty ? null : files.first;

    candidates.sort((a, b) {
      final season = (a.parsedSeason ?? 999999).compareTo(
        b.parsedSeason ?? 999999,
      );
      if (season != 0) return season;
      return (a.parsedEpisode ?? 999999).compareTo(b.parsedEpisode ?? 999999);
    });
    return candidates.first;
  }
}
