import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/domain/models.dart';
import '../view_models/media_detail_view_model.dart';
import '../widgets/media_detail/media_detail_header.dart';

import '../widgets/media_detail/cast_list.dart';
import '../widgets/media_detail/episode_list.dart';

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

class _MediaDetailCardContent extends StatelessWidget {
  final dynamic item; // Movie or TVShow
  final MediaDetailViewModel viewModel;

  _MediaDetailCardContent({required this.item})
    : viewModel = MediaDetailViewModel(item);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // 1. Header (Backdrop, Title, Metadata, Actions)
            SliverToBoxAdapter(child: MediaDetailHeader(viewModel: viewModel)),

            // 2. Content Body
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
              sliver: SliverToBoxAdapter(child: CastList(viewModel: viewModel)),
            ),

            // TV Show Episodes
            if (viewModel.isTVShow)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                sliver: EpisodeList(tvShow: viewModel.originalItem as TVShow),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
        const Positioned(top: 24, right: 24, child: _CloseButton()),
      ],
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
