import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import 'package:mochi_player/core/ui/theme/app_colors.dart';

/// macOS 原生窗口按钮与 Windows 自绘按钮共用的左上角布局规格。
abstract final class AppWindowChromeMetrics {
  static const double leadingInset = 8;
  static const double leadingContentInset = 104;
}

/// Windows 无边框窗口使用的最小化、最大化和关闭按钮。
///
/// macOS 继续使用系统原生的交通灯按钮，其他平台不显示此组件。
class AppWindowControls extends StatefulWidget {
  static const _nativeChannel = MethodChannel('mochi_player/window_controls');
  static final ValueNotifier<bool> _miniPlayerMode = ValueNotifier(false);

  static const double buttonSize = 28;
  static const double buttonGap = 2;
  static const double height = 60;
  static const double width = buttonSize * 3 + buttonGap * 2;

  const AppWindowControls({super.key});

  static bool get isVisible =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  static Future<void> positionNativeWindowButtons() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.macOS) return;
    await _nativeChannel.invokeMethod<void>('positionNativeWindowButtons');
  }

  static Future<void> setMiniPlayerMode(bool enabled) async {
    if (_miniPlayerMode.value != enabled) {
      _miniPlayerMode.value = enabled;
    }
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.macOS) return;
    await _nativeChannel.invokeMethod<void>(
      'setNativeWindowButtonsVisible',
      !enabled,
    );
  }

  @override
  State<AppWindowControls> createState() => _AppWindowControlsState();
}

class _AppWindowControlsState extends State<AppWindowControls>
    with WindowListener {
  bool _isMaximized = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    AppWindowControls._miniPlayerMode.addListener(_handleModeChanged);
    windowManager.addListener(this);
    _syncMaximizedState();
  }

  @override
  void dispose() {
    AppWindowControls._miniPlayerMode.removeListener(_handleModeChanged);
    windowManager.removeListener(this);
    super.dispose();
  }

  void _handleModeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _syncMaximizedState() async {
    final states = await Future.wait([
      windowManager.isMaximized(),
      windowManager.isFullScreen(),
    ]);
    if (!mounted) return;
    final isMaximized = states[0];
    final isFullScreen = states[1];
    if (isMaximized == _isMaximized && isFullScreen == _isFullScreen) return;
    setState(() {
      _isMaximized = isMaximized;
      _isFullScreen = isFullScreen;
    });
  }

  Future<void> _toggleMaximized() async {
    if (_isMaximized) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  void onWindowMaximize() {
    if (mounted && !_isMaximized) setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    if (mounted && _isMaximized) setState(() => _isMaximized = false);
  }

  @override
  void onWindowEnterFullScreen() {
    if (mounted && !_isFullScreen) setState(() => _isFullScreen = true);
  }

  @override
  void onWindowLeaveFullScreen() {
    if (mounted && _isFullScreen) setState(() => _isFullScreen = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!AppWindowControls.isVisible ||
        _isFullScreen ||
        AppWindowControls._miniPlayerMode.value) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: AppWindowControls.width,
      height: AppWindowControls.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _WindowControlButton(
            label: '最小化',
            glyph: _WindowControlGlyph.minimize,
            onPressed: windowManager.minimize,
          ),
          const SizedBox(width: AppWindowControls.buttonGap),
          _WindowControlButton(
            label: _isMaximized ? '还原' : '最大化',
            glyph: _isMaximized
                ? _WindowControlGlyph.restore
                : _WindowControlGlyph.maximize,
            onPressed: _toggleMaximized,
          ),
          const SizedBox(width: AppWindowControls.buttonGap),
          _WindowControlButton(
            label: '关闭',
            glyph: _WindowControlGlyph.close,
            isClose: true,
            onPressed: windowManager.close,
          ),
        ],
      ),
    );
  }
}

enum _WindowControlGlyph { minimize, maximize, restore, close }

class _WindowControlButton extends StatefulWidget {
  final String label;
  final _WindowControlGlyph glyph;
  final bool isClose;
  final VoidCallback onPressed;

  const _WindowControlButton({
    required this.label,
    required this.glyph,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.favorite(context);
    final restingForeground = AppColors.textSecondary(context);
    final hoverForeground = widget.isClose
        ? accent
        : AppColors.textPrimary(context);
    final hoverColor = widget.isClose
        ? accent.withAlpha(34)
        : AppColors.hoverSurface(context);

    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: _isHovering ? 1 : 0),
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            builder: (context, hoverProgress, child) => Container(
              width: AppWindowControls.buttonSize,
              height: AppWindowControls.buttonSize,
              decoration: BoxDecoration(
                color: Color.lerp(
                  hoverColor.withAlpha(0),
                  hoverColor,
                  hoverProgress,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: CustomPaint(
                size: const Size.square(12),
                painter: _WindowControlGlyphPainter(
                  glyph: widget.glyph,
                  color: Color.lerp(
                    restingForeground,
                    hoverForeground,
                    hoverProgress,
                  )!,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WindowControlGlyphPainter extends CustomPainter {
  final _WindowControlGlyph glyph;
  final Color color;

  const _WindowControlGlyphPainter({required this.glyph, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (glyph) {
      case _WindowControlGlyph.minimize:
        canvas.drawLine(
          Offset(2, size.height - 3),
          Offset(size.width - 2, size.height - 3),
          paint,
        );
      case _WindowControlGlyph.maximize:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
            const Radius.circular(1),
          ),
          paint,
        );
      case _WindowControlGlyph.restore:
        final backWindow = Path()
          ..moveTo(4, 2)
          ..lineTo(size.width - 2, 2)
          ..lineTo(size.width - 2, size.height - 4);
        canvas.drawPath(backWindow, paint);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(2, 4, size.width - 6, size.height - 6),
            const Radius.circular(1),
          ),
          paint,
        );
      case _WindowControlGlyph.close:
        canvas.drawLine(
          const Offset(2, 2),
          Offset(size.width - 2, size.height - 2),
          paint,
        );
        canvas.drawLine(
          Offset(size.width - 2, 2),
          Offset(2, size.height - 2),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _WindowControlGlyphPainter oldDelegate) {
    return oldDelegate.glyph != glyph || oldDelegate.color != color;
  }
}
