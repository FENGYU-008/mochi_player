import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/basic/app_clickable_area.dart';
import 'package:mochi_player/core/ui/components/layout/app_glass_surface.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';

typedef AppHorizontalScrollContentBuilder =
    Widget Function(BuildContext context, ScrollController controller);

/// Adds desktop previous/next controls to horizontally scrollable content.
///
/// The content receives this component's controller through [contentBuilder],
/// so the controls and the scrollable cannot accidentally use different
/// controllers.
class AppHorizontalScroller extends StatefulWidget {
  const AppHorizontalScroller({
    super.key,
    required this.controller,
    required this.contentBuilder,
    this.controlsBottomInset = 0,
  });

  final ScrollController controller;
  final AppHorizontalScrollContentBuilder contentBuilder;

  /// Space below the visual scrolling area, such as labels under posters.
  final double controlsBottomInset;

  @override
  State<AppHorizontalScroller> createState() => _AppHorizontalScrollerState();
}

class _AppHorizontalScrollerState extends State<AppHorizontalScroller> {
  bool _hovering = false;
  bool _canScrollBack = false;
  bool _canScrollForward = false;
  bool _visibilityUpdateScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateControlVisibility);
    _scheduleControlVisibilityUpdate();
  }

  @override
  void didUpdateWidget(covariant AppHorizontalScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_updateControlVisibility);
    widget.controller.addListener(_updateControlVisibility);
    _scheduleControlVisibilityUpdate();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateControlVisibility);
    super.dispose();
  }

  void _scheduleControlVisibilityUpdate() {
    if (_visibilityUpdateScheduled) return;
    _visibilityUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visibilityUpdateScheduled = false;
      _updateControlVisibility();
    });
  }

  void _updateControlVisibility() {
    if (!mounted || !widget.controller.hasClients) return;
    final position = widget.controller.position;
    final canScrollBack = position.pixels > _edgeTolerance;
    final canScrollForward =
        position.pixels < position.maxScrollExtent - _edgeTolerance;
    if (_canScrollBack == canScrollBack &&
        _canScrollForward == canScrollForward) {
      return;
    }
    setState(() {
      _canScrollBack = canScrollBack;
      _canScrollForward = canScrollForward;
    });
  }

  bool _handleMetricsChange(ScrollMetricsNotification notification) {
    _scheduleControlVisibilityUpdate();
    return false;
  }

  Future<void> _scroll(int direction) async {
    if (!widget.controller.hasClients) return;
    final position = widget.controller.position;
    final distance = position.viewportDimension * _viewportScrollFraction;
    final target = (position.pixels + direction * distance).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    await widget.controller.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Stack(
        children: [
          NotificationListener<ScrollMetricsNotification>(
            onNotification: _handleMetricsChange,
            child: widget.contentBuilder(context, widget.controller),
          ),
          Positioned(
            left: _controlInset,
            top: 0,
            bottom: widget.controlsBottomInset,
            child: Center(
              child: _ScrollControl(
                icon: Icons.arrow_back_ios_new_rounded,
                visible: _hovering && _canScrollBack,
                onPressed: () => _scroll(-1),
              ),
            ),
          ),
          Positioned(
            right: _controlInset,
            top: 0,
            bottom: widget.controlsBottomInset,
            child: Center(
              child: _ScrollControl(
                icon: Icons.arrow_forward_ios_rounded,
                visible: _hovering && _canScrollForward,
                onPressed: () => _scroll(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollControl extends StatelessWidget {
  const _ScrollControl({
    required this.icon,
    required this.visible,
    required this.onPressed,
  });

  final IconData icon;
  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      opacity: visible ? 1 : 0,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AppGlassSurface(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.full)),
          color: Colors.black.withAlpha(102),
          borderColor: Colors.white.withAlpha(26),
          blur: 10,
          child: AppClickableArea(
            onTap: visible ? onPressed : null,
            width: _controlSize,
            height: _controlSize,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppRadii.full),
            ),
            hoverColor: Colors.white.withAlpha(26),
            child: Center(
              child: Icon(icon, color: Colors.white.withAlpha(230), size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

const double _edgeTolerance = 1;
const double _viewportScrollFraction = 0.8;
const double _controlInset = 20;
const double _controlSize = 44;
