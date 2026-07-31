import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/library/presentation/view_models/media_detail_view_model.dart';
import 'package:mochi_player/features/library/presentation/widgets/media_detail/cast_list.dart';
import 'package:mochi_player/features/library/presentation/widgets/media_detail/episode_list.dart';
import 'package:mochi_player/features/library/presentation/widgets/media_detail/media_detail_header.dart';
import 'package:mochi_player/features/playback/presentation/playback_launcher.dart';
import 'package:mochi_player/core/domain/media/models.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

typedef OpenMediaDetail = void Function(LibraryItem item);

void openMediaDetailPage(BuildContext context, LibraryItem item) {
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
  final LibraryItem item;
  final VoidCallback? onBack;

  const MediaDetailPage({super.key, required this.item, this.onBack});

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
            child: AppHeader(
              title: viewModel.title,
              showBackButton: true,
              onBack: onBack,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaDetailContent extends StatelessWidget {
  final MediaDetailViewModel viewModel;

  const _MediaDetailContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final tvShow = viewModel.tvShow;
    return CustomScrollView(
      cacheExtent: 320,
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: AppHeader.height)),
        SliverToBoxAdapter(child: MediaDetailHeader(viewModel: viewModel)),

        if (tvShow != null) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              0,
              AppSpacing.page,
              AppSpacing.xxl,
            ),
            sliver: EpisodeList(tvShow: tvShow),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              0,
              AppSpacing.page,
              44,
            ),
            sliver: SliverToBoxAdapter(
              child: CastList(viewModel: viewModel, topPadding: 0),
            ),
          ),
        ] else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              28,
              AppSpacing.page,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _MovieMediaInfoSection(viewModel: viewModel),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              28,
              AppSpacing.page,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _OverviewSection(viewModel: viewModel),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              0,
              AppSpacing.page,
              44,
            ),
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
    context.select<MediaLibraryProvider, (int, int)>(
      (provider) =>
          (provider.mediaCatalogRevision, provider.watchProgressRevision),
    );
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
          SizedBox(
            width: double.infinity,
            child: AppSurface(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                '未找到可播放的本地文件',
                style: TextStyle(color: theme.textTheme.bodySmall?.color),
              ),
            ),
          )
        else
          Column(
            children: [
              for (var index = 0; index < files.length; index++) ...[
                _VersionRow(
                  file: files[index],
                  theme: theme,
                  onTap: () => PlaybackLauncher.playFile(context, files[index]),
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
    final progress = file.progress.clamp(0.0, 1.0);

    return AppSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.movie_creation_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MediaFilePresentation.versionTitle(file),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  MediaFilePresentation.versionSubtitle(
                    file,
                    includeResumePosition: true,
                  ),
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
                    borderRadius: BorderRadius.circular(AppRadii.full),
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
    );
  }
}
