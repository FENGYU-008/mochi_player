import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/domain/models.dart';
import '../../providers/media_library_provider.dart';
import '../theme/app_colors.dart';
import '../view_models/media_detail_view_model.dart';
import '../widgets/app_header.dart';
import '../widgets/macos_controls.dart';
import '../widgets/media_detail/cast_list.dart';
import '../widgets/media_detail/episode_list.dart';
import '../widgets/media_detail/media_detail_header.dart';
import '../widgets/media_detail/playback_helper.dart';

typedef OpenMediaDetail = void Function(dynamic item);

void openMediaDetailPage(BuildContext context, dynamic item) {
  assert(item is Movie || item is TVShow, 'Item must be Movie or TVShow');
  final scope = MediaDetailNavigationScope.maybeOf(context);
  if (scope != null) {
    scope.openMediaDetail(item);
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => MediaDetailPage(item: item)),
  );
}

class MediaDetailNavigationScope extends InheritedWidget {
  final OpenMediaDetail openMediaDetail;

  const MediaDetailNavigationScope({
    super.key,
    required this.openMediaDetail,
    required super.child,
  });

  static MediaDetailNavigationScope? maybeOf(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<MediaDetailNavigationScope>()
        ?.widget;
    return widget is MediaDetailNavigationScope ? widget : null;
  }

  @override
  bool updateShouldNotify(MediaDetailNavigationScope oldWidget) {
    return openMediaDetail != oldWidget.openMediaDetail;
  }
}

class MediaDetailPage extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onBack;

  const MediaDetailPage({super.key, required this.item, this.onBack})
    : assert(item is Movie || item is TVShow, 'Item must be Movie or TVShow');

  @override
  Widget build(BuildContext context) {
    final viewModel = MediaDetailViewModel(item);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(child: _MediaDetailContent(viewModel: viewModel)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: AppHeader.height,
            child: _DetailTopBar(viewModel: viewModel, onBack: onBack),
          ),
        ],
      ),
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  final MediaDetailViewModel viewModel;
  final VoidCallback? onBack;

  const _DetailTopBar({required this.viewModel, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      title: viewModel.title,
      leading: MacosIconButton(
        onPressed: () => _goBack(context),
        icon: Icons.arrow_back_rounded,
        tooltip: '返回',
        foregroundColor: AppColors.textPrimary(context),
        backgroundColor: AppColors.hoverSurface(context),
        size: 36,
        iconSize: 20,
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }
}

class _MediaDetailContent extends StatelessWidget {
  final MediaDetailViewModel viewModel;

  const _MediaDetailContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      cacheExtent: 320,
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: AppHeader.height)),
        SliverToBoxAdapter(child: MediaDetailHeader(viewModel: viewModel)),

        if (viewModel.isTVShow) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 24),
            sliver: EpisodeList(tvShow: viewModel.originalItem as TVShow),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 44),
            sliver: SliverToBoxAdapter(
              child: CastList(viewModel: viewModel, topPadding: 0),
            ),
          ),
        ] else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(40, 28, 40, 0),
            sliver: SliverToBoxAdapter(
              child: _MovieMediaInfoSection(viewModel: viewModel),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(40, 28, 40, 0),
            sliver: SliverToBoxAdapter(
              child: _OverviewSection(viewModel: viewModel),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 44),
            sliver: SliverToBoxAdapter(
              child: CastList(viewModel: viewModel, topPadding: 20),
            ),
          ),
        ],
      ],
    );
  }
}

class _MovieMediaInfoSection extends StatelessWidget {
  final MediaDetailViewModel viewModel;

  const _MovieMediaInfoSection({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final files = context.read<MediaLibraryProvider>().getVersions(
      viewModel.tmdbId,
    )..sort(_compareVersions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: '版本',
          trailing: files.isEmpty
              ? null
              : files.length == 1
              ? '1 个本地文件'
              : '${files.length} 个本地文件',
        ),
        const SizedBox(height: 12),
        if (files.isEmpty)
          _EmptyInfoBox(message: '未找到可播放的本地文件')
        else
          Column(
            children: [
              for (var index = 0; index < files.length; index++) ...[
                _VersionRow(
                  file: files[index],
                  theme: theme,
                  onTap: () => PlaybackHelper.playFile(context, files[index]),
                ),
                if (index != files.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
      ],
    );
  }

  int _compareVersions(MediaFile a, MediaFile b) {
    final heightCompare = (b.height ?? 0).compareTo(a.height ?? 0);
    if (heightCompare != 0) return heightCompare;
    return b.size.compareTo(a.size);
  }
}

class _OverviewSection extends StatelessWidget {
  final MediaDetailViewModel viewModel;

  const _OverviewSection({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: '简介'),
        const SizedBox(height: 10),
        Text(
          viewModel.overview,
          style: TextStyle(
            fontSize: 14,
            height: 1.55,
            color: theme.textTheme.bodyMedium?.color?.withAlpha(220),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          Text(
            trailing!,
            style: TextStyle(
              fontSize: 13,
              color: theme.textTheme.bodySmall?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _VersionRow extends StatelessWidget {
  final MediaFile file;
  final ThemeData theme;
  final VoidCallback onTap;

  const _VersionRow({
    required this.file,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final progress = file.progress.clamp(0.0, 1.0);

    return Material(
      color: isDark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(6),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                Icons.movie_creation_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _versionTitle(file),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _versionSubtitle(file),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    if (progress > 0 && progress < 0.95) ...[
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: theme.dividerColor.withAlpha(80),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.play_arrow_rounded, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  String _versionTitle(MediaFile file) {
    final parts = [
      file.quality,
      file.videoCodec,
      if (file.isHdr) file.hdrFormat ?? 'HDR',
      file.versionLabel,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).toList();
    return parts.isEmpty ? file.fileName : parts.join(' • ');
  }

  String _versionSubtitle(MediaFile file) {
    final parts = <String>[];
    if (file.audioCodec != null && file.audioCodec!.isNotEmpty) {
      parts.add(file.audioCodec!);
    }
    if (file.audioChannels != null && file.audioChannels!.isNotEmpty) {
      parts.add(file.audioChannels!);
    }
    if (file.container != null && file.container!.isNotEmpty) {
      parts.add(file.container!.toUpperCase());
    }
    if (file.size > 0) parts.add(_formatFileSize(file.size));
    if (file.position > 0 && file.duration > 0 && file.progress < 0.95) {
      parts.add(
        '从 ${_formatDuration(Duration(milliseconds: file.position))} 继续',
      );
    }
    return parts.isEmpty ? file.fileName : parts.join(' • ');
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }
}

class _EmptyInfoBox extends StatelessWidget {
  final String message;

  const _EmptyInfoBox({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white.withAlpha(12)
            : Colors.black.withAlpha(6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(color: theme.textTheme.bodySmall?.color),
      ),
    );
  }
}
