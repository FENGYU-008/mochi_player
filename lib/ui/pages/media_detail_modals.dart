import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mochi_player/services/webdav_service.dart';
import 'package:mochi_player/ui/pages/player_page.dart';
import 'package:mochi_player/ui/widgets/horizontal_scroll_view.dart';
import '../../models/domain/models.dart';
import '../../providers/media_library_provider.dart';

// 通用入口
void showMediaDetailModal(BuildContext context, dynamic item) {
  assert(item is Movie || item is TVShow, 'Item must be Movie or TVShow');
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInCubic,
      );
      return Stack(
        children: [
          FadeTransition(
            opacity: curvedAnimation,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.black.withAlpha((255 * 0.2).round()),
                ),
              ),
            ),
          ),
          ScaleTransition(
            scale: Tween<double>(
              begin: 0.92,
              end: 1.0,
            ).animate(curvedAnimation),
            child: FadeTransition(opacity: curvedAnimation, child: child),
          ),
        ],
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      return Center(
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {},
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 950,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((255 * 0.2).round()),
                      blurRadius: 50,
                      offset: const Offset(0, 30),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _MediaDetailCardContent(item: item),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _MediaDetailCardContent extends StatefulWidget {
  final dynamic item; // Movie or TVShow

  const _MediaDetailCardContent({required this.item});

  @override
  State<_MediaDetailCardContent> createState() =>
      _MediaDetailCardContentState();
}

class _MediaDetailCardContentState extends State<_MediaDetailCardContent> {
  // 电视剧状态
  List<Season> _sortedSeasons = [];
  Season? _selectedSeason;
  List<Episode> _sortedEpisodes = [];

  // 演职员表滚动控制器
  final ScrollController _castScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.item is TVShow) {
      final show = widget.item as TVShow;

      // 1. 获取并排序季 (从小到大)
      _sortedSeasons = List.from(show.seasons)
        ..sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));

      if (_sortedSeasons.isNotEmpty) {
        // 默认选中第一季
        _selectSeason(_sortedSeasons.first);
      }
    }
  }

  void _selectSeason(Season season) {
    setState(() {
      _selectedSeason = season;
      // 2. 获取并排序该季的集 (从小到大)
      _sortedEpisodes = List.from(season.episodes)
        ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
    });
  }

  @override
  void dispose() {
    _castScrollController.dispose();
    super.dispose();
  }

  // 获取从 Domain 模型中读取属性
  String get _title {
    if (widget.item is Movie) return (widget.item as Movie).title;
    if (widget.item is TVShow) return (widget.item as TVShow).title;
    return "";
  }

  String get _backdropUrl {
    String? url;
    if (widget.item is Movie) url = (widget.item as Movie).backdropUrl;
    if (widget.item is TVShow) url = (widget.item as TVShow).backdropUrl;
    return url ?? "";
  }

  String get _posterUrl {
    String? url;
    if (widget.item is Movie) url = (widget.item as Movie).posterUrl;
    if (widget.item is TVShow) url = (widget.item as TVShow).posterUrl;
    return url ?? "";
  }

  String get _rating {
    double r = 0.0;
    if (widget.item is Movie) r = (widget.item as Movie).rating;
    if (widget.item is TVShow) r = (widget.item as TVShow).rating;
    return r.toStringAsFixed(1);
  }

  String get _overview {
    String? s;
    if (widget.item is Movie) s = (widget.item as Movie).overview;
    if (widget.item is TVShow) s = (widget.item as TVShow).overview;
    return s ?? "No overview available.";
  }

  List<String> get _genres {
    if (widget.item is Movie) return (widget.item as Movie).genres;
    if (widget.item is TVShow) return (widget.item as TVShow).genres;
    return [];
  }

  List<Artist> get _cast {
    if (widget.item is Movie) return (widget.item as Movie).cast;
    if (widget.item is TVShow) return (widget.item as TVShow).cast;
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // 1. 顶部大图区域
            SliverToBoxAdapter(
              child: SizedBox(
                height: 400,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: _backdropUrl.isNotEmpty
                          ? _backdropUrl
                          : _posterUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[100]),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.grey[300]),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 250,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha((255 * 0.6).round()),
                              Colors.black.withAlpha((255 * 0.8).round()),
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 40,
                      right: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title,
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: -1.0,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 4),
                                  blurRadius: 10,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _rating,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // TODO: 显示电源/剧集特定的时长信息？
                              // if (widget.item is Movie) ...
                              if (widget.item is TVShow)
                                Text(
                                  "${(widget.item as TVShow).seasons.length} Seasons",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. 内容区域
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(40, 30, 40, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 标签
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [..._genres.map((g) => _buildBadge(g))],
                  ),
                  const SizedBox(height: 32),

                  // 简介
                  Text(
                    "Storyline",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _overview,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 演职员表 (使用 HorizontalScrollView)
                  if (_cast.isNotEmpty) ...[
                    Text(
                      "Cast",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140, // 足够容纳头像和名字
                      child: HorizontalScrollView(
                        controller: _castScrollController,
                        bottomPadding: 58,
                        child: ListView.separated(
                          controller: _castScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: _cast.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 20),
                          itemBuilder: (context, index) =>
                              _buildCastItem(_cast[index]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],

                  // 操作区 (播放或选集)
                  if (widget.item is Movie)
                    _buildMovieActions(context, widget.item as Movie)
                  else if (widget.item is TVShow)
                    _buildTVShowActions(context, widget.item as TVShow),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
        const Positioned(top: 24, right: 24, child: _CloseButton()),
      ],
    );
  }

  // --- 子组件构建方法 ---

  Widget _buildMovieActions(BuildContext context, Movie movie) {
    final provider = Provider.of<MediaLibraryProvider>(context, listen: false);
    final versions = provider.getVersions(movie.tmdbId);
    final hasMultipleVersions = versions.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => hasMultipleVersions
                  ? _showVersionPicker(context, movie, versions)
                  : _playMovie(context, movie),
              icon: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
              label: Text(
                hasMultipleVersions ? "Play" : "Play Now",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(
                  0xFF007AFF,
                ).withAlpha((255 * 0.4).round()),
              ),
            ),
            const SizedBox(width: 16),
            _FavoriteButton(tmdbId: movie.tmdbId),
          ],
        ),
        // 版本信息
        if (hasMultipleVersions) ...[
          const SizedBox(height: 16),
          Text(
            "${versions.length} versions available",
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ],
    );
  }

  void _showVersionPicker(
    BuildContext modalContext,
    Movie movie,
    List<MediaFile> versions,
  ) {
    showModalBottomSheet(
      context: modalContext,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
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
                itemBuilder: (context, index) {
                  final file = versions[index];
                  final label =
                      file.versionLabel ??
                      [
                            file.quality,
                            file.videoCodec,
                            if (file.isHdr) file.hdrFormat ?? 'HDR',
                          ]
                          .whereType<String>()
                          .where((s) => s.isNotEmpty)
                          .join(' • ');
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
                      Navigator.pop(sheetContext);
                      // 使用 modalContext 而不是 sheetContext，因为 sheet 已关闭
                      _openPlayer(modalContext, file);
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

  String _buildVersionSubtitle(MediaFile file) {
    final parts = <String>[];
    if (file.audioCodec != null) parts.add(file.audioCodec!);
    if (file.audioChannels != null) parts.add(file.audioChannels!);
    if (file.size > 0) parts.add(_formatFileSize(file.size));
    return parts.join(' • ');
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Widget _buildTVShowActions(BuildContext context, TVShow show) {
    if (_sortedSeasons.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [_FavoriteButton(tmdbId: show.tmdbId)]),
          const SizedBox(height: 20),
          const Text(
            "No seasons available.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 收藏按钮
        Row(children: [_FavoriteButton(tmdbId: show.tmdbId)]),
        const SizedBox(height: 24),
        // 季选择器
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _sortedSeasons.map((season) {
              final isSelected = _selectedSeason == season;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text("Season ${season.seasonNumber}"),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) _selectSeason(season);
                  },
                  selectedColor: const Color(0xFF007AFF),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide.none,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // 集列表
        if (_selectedSeason != null)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sortedEpisodes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final episode = _sortedEpisodes[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF007AFF),
                  ),
                ),
                title: Text(
                  "${episode.episodeNumber}. ${episode.title}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  episode.overview != null && episode.overview!.isNotEmpty
                      ? episode.overview!
                      : (episode.airDate != null
                            ? episode.airDate.toString().substring(0, 10)
                            : ''),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _playEpisode(context, episode, show.title),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCastItem(Artist artist) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            image: artist.profileUrl != null
                ? DecorationImage(
                    image: CachedNetworkImageProvider(artist.profileUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: artist.profileUrl == null
              ? const Icon(Icons.person, color: Colors.grey, size: 40)
              : null,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 90,
          child: Text(
            artist.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
        SizedBox(
          width: 90,
          child: Text(
            artist.character ?? "",
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withAlpha((255 * 0.05).round())),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // --- 播放逻辑 ---

  // 播放电影
  void _playMovie(BuildContext context, Movie movie) async {
    final provider = Provider.of<MediaLibraryProvider>(context, listen: false);

    // 查找该电影对应的文件
    final files = provider.getVersions(movie.tmdbId);
    if (files.isEmpty) {
      _showError(context, "Cannot find media file for this movie.");
      return;
    }

    // 如果有多个版本，默认播放第一个，或者这里可以弹窗选择版本
    final file = files.first;
    _openPlayer(context, file);
  }

  // 播放剧集
  void _playEpisode(
    BuildContext context,
    Episode episode,
    String showTitle,
  ) async {
    final provider = Provider.of<MediaLibraryProvider>(context, listen: false);

    // 查找该集对应的文件
    // 注意：假设 MediaLibraryProvider 已经正确关联了 tmdbId
    // Episode 的 tmdbId 可能是 "{showTmdbId}-s{S}e{E}" 格式，需要和 MediaFile 的 tmdbId 匹配
    // 在 MediaLibraryProvider 中 _scrapeMetadata 应该处理了 id 格式统一

    // 我们遍历 mediaFiles 查找
    // 效率较低，但在详情页点击播放时还可以接受
    MediaFile? targetFile;
    try {
      targetFile = provider.mediaFiles.firstWhere(
        (f) => f.tmdbId == episode.tmdbId,
      );
    } catch (_) {
      // ignore
    }

    if (targetFile == null) {
      _showError(context, "Cannot find media file for this episode.");
      return;
    }

    _openPlayer(context, targetFile, contextTitle: showTitle);
  }

  void _openPlayer(
    BuildContext context,
    MediaFile file, {
    String? contextTitle,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(width: 16),
            const Expanded(child: Text("Getting playback link...")),
          ],
        ),
        duration: const Duration(minutes: 1),
      ),
    );

    final directLink = await WebDavService().getDirectLink(file.path);

    messenger.hideCurrentSnackBar();

    if (directLink != null) {
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
    } else {
      _showError(
        context,
        "Failed to get playback link. Check network or server.",
      );
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }
}

class _CloseButton extends StatefulWidget {
  const _CloseButton();

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _isHovering
                ? Colors.black.withAlpha((255 * 0.5).round())
                : Colors.black.withAlpha((255 * 0.3).round()),
            shape: BoxShape.circle,
            border: Border.all(
              color: _isHovering
                  ? Colors.white.withAlpha((255 * 0.2).round())
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

/// 收藏按钮
class _FavoriteButton extends StatefulWidget {
  final String tmdbId;

  const _FavoriteButton({required this.tmdbId});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isFavorite = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _checkFavoriteStatus();
    }
  }

  void _checkFavoriteStatus() {
    final provider = Provider.of<MediaLibraryProvider>(context, listen: false);
    final files = provider.getVersions(widget.tmdbId);
    if (files.isNotEmpty) {
      setState(() => _isFavorite = files.any((f) => f.isFavorite));
    }
  }

  Future<void> _toggleFavorite() async {
    final provider = Provider.of<MediaLibraryProvider>(context, listen: false);
    final files = provider.getVersions(widget.tmdbId);
    if (files.isEmpty) return;

    for (final file in files) {
      await provider.toggleFavorite(file);
    }

    setState(() => _isFavorite = !_isFavorite);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _toggleFavorite,
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Colors.red : const Color(0xFF007AFF),
        size: 22,
      ),
      label: Text(
        _isFavorite ? "Favorited" : "Favorite",
        style: TextStyle(
          color: _isFavorite ? Colors.red : const Color(0xFF007AFF),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        side: BorderSide(
          color: _isFavorite ? Colors.red : const Color(0xFF007AFF),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
