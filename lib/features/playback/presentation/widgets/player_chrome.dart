import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/app_ui.dart';

/// 播放器顶部信息栏和底部控制栏共用的布局规格。
class PlayerChromeLayout {
  const PlayerChromeLayout._();

  static const double topBarHeight = 60;
  static const double topButtonHeight = 36;
  static const double controlHeight = 34;
  static const Duration visibilityDuration = Duration(milliseconds: 200);

  /// 为左上角的系统窗口按钮预留空间。
  static double topLeftInset({
    required TargetPlatform platform,
    required bool isFullScreen,
  }) {
    if (isFullScreen) return AppSpacing.xxl;
    return switch (platform) {
      TargetPlatform.macOS ||
      TargetPlatform.windows => AppWindowChromeMetrics.leadingContentInset,
      _ => AppSpacing.xxl,
    };
  }
}

/// 播放器顶部信息栏。
///
/// 只负责返回入口、媒体标题和系统时间，不持有播放状态。
class PlayerTopBar extends StatelessWidget {
  final String title;
  final String? secondaryTitle;
  final String systemTime;
  final bool isFullScreen;
  final VoidCallback onBack;

  const PlayerTopBar({
    super.key,
    required this.title,
    required this.systemTime,
    required this.isFullScreen,
    required this.onBack,
    this.secondaryTitle,
  });

  @override
  Widget build(BuildContext context) {
    final leftInset = PlayerChromeLayout.topLeftInset(
      platform: Theme.of(context).platform,
      isFullScreen: isFullScreen,
    );

    return SizedBox(
      height: PlayerChromeLayout.topBarHeight,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xC9000000), Color(0x82000000), Color(0x00000000)],
            stops: [0, 0.72, 1],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: leftInset,
              right: AppSpacing.xxl,
              top: AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PlayerBackButton(onPressed: onBack),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 9),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (secondaryTitle case final value?
                            when value.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.md),
                          Flexible(
                            child: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                height: 1.2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xxl),
                Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Text(
                    systemTime,
                    key: const ValueKey('player-system-time'),
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      height: 1.2,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PlayerBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(AppRadii.control));
    return SizedBox(
      key: const ValueKey('player-back-button'),
      width: 38,
      height: PlayerChromeLayout.topButtonHeight,
      child: GlassSurface(
        borderRadius: radius,
        color: const Color(0x52000000),
        borderColor: const Color(0x2EFFFFFF),
        blur: 18,
        child: AppClickableArea(
          onTap: onPressed,
          borderRadius: radius,
          hoverColor: const Color(0x1FFFFFFF),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),
        ),
      ),
    );
  }
}

/// 播放器底部玻璃控制面板。
///
/// 进度与具体按钮由上层注入，因此播放器状态和视觉容器保持解耦。
class PlayerBottomControlBar extends StatelessWidget {
  final Widget progress;
  final Widget controls;

  const PlayerBottomControlBar({
    super.key,
    required this.progress,
    required this.controls,
  });

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = (windowWidth * 0.7).clamp(620.0, 1520.0).toDouble();
    final horizontalPadding = windowWidth <= 1000
        ? AppSpacing.md
        : AppSpacing.xl;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: SizedBox(
          width: panelWidth,
          child: GlassSurface(
            key: const ValueKey('player-bottom-control-bar'),
            borderRadius: const BorderRadius.all(
              Radius.circular(AppRadii.large),
            ),
            color: const Color(0x80000000),
            borderColor: const Color(0x1AFFFFFF),
            blur: 16,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppSpacing.sm,
              horizontalPadding,
              AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                progress,
                const SizedBox(height: AppSpacing.xs),
                controls,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 播放器控制按钮，只提供悬停反馈，不绘制 Material 水波纹或按压底色。
class PlayerControlButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double width;
  final String? tooltip;

  const PlayerControlButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.width = PlayerChromeLayout.controlHeight,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = AppClickableArea(
      width: width,
      height: PlayerChromeLayout.controlHeight,
      onTap: onPressed,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.control)),
      hoverColor: const Color(0x1FFFFFFF),
      child: Center(child: child),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// 弹出菜单触发器使用的悬停表面。
///
/// 点击由外层菜单组件处理，这里只统一尺寸、圆角和悬停颜色。
class PlayerMenuButtonSurface extends StatefulWidget {
  final Widget child;
  final double width;

  const PlayerMenuButtonSurface({
    super.key,
    required this.child,
    this.width = PlayerChromeLayout.controlHeight,
  });

  @override
  State<PlayerMenuButtonSurface> createState() =>
      _PlayerMenuButtonSurfaceState();
}

class _PlayerMenuButtonSurfaceState extends State<PlayerMenuButtonSurface> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    const hoverColor = Color(0x1FFFFFFF);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: _hovering ? 1 : 0),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) => Container(
          width: widget.width,
          height: PlayerChromeLayout.controlHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color.lerp(hoverColor.withAlpha(0), hoverColor, progress),
            borderRadius: const BorderRadius.all(
              Radius.circular(AppRadii.control),
            ),
          ),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
