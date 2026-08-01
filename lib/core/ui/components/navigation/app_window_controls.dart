import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:mochi_player/core/ui/theme/app_colors.dart';

/// Windows 无边框窗口使用的最小化、最大化和关闭按钮。
///
/// macOS 继续使用系统原生的交通灯按钮，其他平台不显示此组件。
class AppWindowControls extends StatefulWidget {
  static const double buttonWidth = 46;
  static const double height = 36;
  static const double width = buttonWidth * 3;
  static const double headerEndInset = width + 8;

  const AppWindowControls({super.key});

  static bool get isVisible =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

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
    windowManager.addListener(this);
    _syncMaximizedState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
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
    if (!AppWindowControls.isVisible || _isFullScreen) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: AppWindowControls.width,
      height: AppWindowControls.height,
      child: Row(
        children: [
          _WindowControlButton(
            label: '最小化',
            glyph: _WindowControlGlyph.minimize,
            onPressed: windowManager.minimize,
          ),
          _WindowControlButton(
            label: _isMaximized ? '还原' : '最大化',
            glyph: _isMaximized
                ? _WindowControlGlyph.restore
                : _WindowControlGlyph.maximize,
            onPressed: _toggleMaximized,
          ),
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
    final foreground = widget.isClose && _isHovering
        ? Colors.white
        : AppColors.textPrimary(context);
    final hoverColor = widget.isClose
        ? const Color(0xFFC42B1C)
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
            width: AppWindowControls.buttonWidth,
            height: AppWindowControls.height,
            color: _isHovering ? hoverColor : Colors.transparent,
            alignment: Alignment.center,
            child: CustomPaint(
              size: const Size.square(12),
              painter: _WindowControlGlyphPainter(
                glyph: widget.glyph,
                color: foreground,
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
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square;

    switch (glyph) {
      case _WindowControlGlyph.minimize:
        canvas.drawLine(
          Offset(1, size.height - 2),
          Offset(size.width - 1, size.height - 2),
          paint,
        );
      case _WindowControlGlyph.maximize:
        canvas.drawRect(
          Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3),
          paint,
        );
      case _WindowControlGlyph.restore:
        canvas.drawRect(
          Rect.fromLTWH(3.5, 1.5, size.width - 5, size.height - 5),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(1.5, 3.5, size.width - 5, size.height - 5),
          paint,
        );
      case _WindowControlGlyph.close:
        canvas.drawLine(
          const Offset(1.5, 1.5),
          Offset(size.width - 1.5, size.height - 1.5),
          paint,
        );
        canvas.drawLine(
          Offset(size.width - 1.5, 1.5),
          Offset(1.5, size.height - 1.5),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _WindowControlGlyphPainter oldDelegate) {
    return oldDelegate.glyph != glyph || oldDelegate.color != color;
  }
}
