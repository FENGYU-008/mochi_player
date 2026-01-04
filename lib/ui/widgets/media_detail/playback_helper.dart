import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mochi_player/models/domain/models.dart';
import 'package:mochi_player/providers/media_library_provider.dart';
import 'package:mochi_player/services/webdav_service.dart';
import 'package:mochi_player/ui/pages/player_page.dart';

class PlaybackHelper {
  /// 播放电影：查找文件并播放（支持多版本选择）
  static void playMovie(BuildContext context, Movie movie) {
    final provider = Provider.of<MediaLibraryProvider>(context, listen: false);
    final versions = provider.getVersions(movie.tmdbId);

    if (versions.isEmpty) {
      _showError(context, "Cannot find media file for this movie.");
      return;
    }

    if (versions.length > 1) {
      _showVersionPicker(context, versions);
    } else {
      _openPlayer(context, versions.first);
    }
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
      _showError(context, "Cannot find media file for this episode.");
      return;
    }

    _openPlayer(context, targetFile, contextTitle: showTitle);
  }

  /// 核心播放逻辑：获取直链 -> 跳转 PlayerPage
  static void _openPlayer(
    BuildContext context,
    MediaFile file, {
    String? contextTitle,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(width: 16),
            Expanded(child: Text("Getting playback link...")),
          ],
        ),
        duration: Duration(minutes: 1),
      ),
    );

    final directLink = await WebDavService().getDirectLink(file.path);
    messenger.hideCurrentSnackBar();

    if (directLink != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerPage(
            videoItem: file,
            url: directLink,
            contextTitle: contextTitle,
          ),
        ),
      );
    } else if (context.mounted) {
      _showError(
        context,
        "Failed to get playback link. Check network or server.",
      );
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
                  "Select Version",
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
                separatorBuilder: (_, __) => const Divider(height: 1),
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
}
