import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import 'package:mochi_player/core/ui/theme/app_colors.dart';

/// Custom minimize, maximize and close buttons for the borderless Windows app.
class WindowsWindowButtons extends StatefulWidget {
  const WindowsWindowButtons({super.key});

  static bool get isSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  @override
  State<WindowsWindowButtons> createState() => _WindowsWindowButtonsState();
}

class _WindowsWindowButtonsState extends State<WindowsWindowButtons> with WindowListener {
  bool _isMaximized = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _syncWindowState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _syncWindowState() async {
    final states = await Future.wait([windowManager.isMaximized(), windowManager.isFullScreen()]);
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
    if (!WindowsWindowButtons.isSupported || _isFullScreen) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _buttonGroupWidth,
      height: _buttonAreaHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _WindowButton(label: '最小化', glyph: _WindowButtonGlyph.minimize, onPressed: windowManager.minimize),
          const SizedBox(width: _buttonGap),
          _WindowButton(
            label: _isMaximized ? '还原' : '最大化',
            glyph: _isMaximized ? _WindowButtonGlyph.restore : _WindowButtonGlyph.maximize,
            onPressed: _toggleMaximized,
          ),
          const SizedBox(width: _buttonGap),
          _WindowButton(label: '关闭', glyph: _WindowButtonGlyph.close, isClose: true, onPressed: windowManager.close),
        ],
      ),
    );
  }
}

enum _WindowButtonGlyph { minimize, maximize, restore, close }

class _WindowButton extends StatefulWidget {
  const _WindowButton({required this.label, required this.glyph, required this.onPressed, this.isClose = false});

  final String label;
  final _WindowButtonGlyph glyph;
  final bool isClose;
  final VoidCallback onPressed;

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovering = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.favorite(context);
    final restingForeground = AppColors.textSecondary(context);
    final hoverForeground = widget.isClose ? accent : AppColors.textPrimary(context);
    final hoverColor = widget.isClose ? accent.withAlpha(34) : AppColors.hoverSurface(context);
    final highlighted = _isHovering || _isFocused;

    return Semantics(
      button: true,
      label: widget.label,
      onTap: widget.onPressed,
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.basic,
        onShowHoverHighlight: (value) => setState(() => _isHovering = value),
        onShowFocusHighlight: (value) => setState(() => _isFocused = value),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: highlighted ? 1 : 0),
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            builder: (context, highlightProgress, child) => Container(
              width: _buttonSize,
              height: _buttonSize,
              decoration: BoxDecoration(
                color: Color.lerp(hoverColor.withAlpha(0), hoverColor, highlightProgress),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: CustomPaint(
                size: const Size.square(12),
                painter: _WindowButtonGlyphPainter(
                  glyph: widget.glyph,
                  color: Color.lerp(restingForeground, hoverForeground, highlightProgress)!,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WindowButtonGlyphPainter extends CustomPainter {
  const _WindowButtonGlyphPainter({required this.glyph, required this.color});

  final _WindowButtonGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (glyph) {
      case _WindowButtonGlyph.minimize:
        canvas.drawLine(Offset(2, size.height - 3), Offset(size.width - 2, size.height - 3), paint);
      case _WindowButtonGlyph.maximize:
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, size.width - 4, size.height - 4), const Radius.circular(1)),
          paint,
        );
      case _WindowButtonGlyph.restore:
        final backWindow = Path()
          ..moveTo(4, 2)
          ..lineTo(size.width - 2, 2)
          ..lineTo(size.width - 2, size.height - 4);
        canvas.drawPath(backWindow, paint);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(2, 4, size.width - 6, size.height - 6), const Radius.circular(1)),
          paint,
        );
      case _WindowButtonGlyph.close:
        canvas.drawLine(const Offset(2, 2), Offset(size.width - 2, size.height - 2), paint);
        canvas.drawLine(Offset(size.width - 2, 2), Offset(2, size.height - 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WindowButtonGlyphPainter oldDelegate) {
    return oldDelegate.glyph != glyph || oldDelegate.color != color;
  }
}

const double _buttonSize = 28;
const double _buttonGap = 2;
const double _buttonAreaHeight = 60;
const double _buttonGroupWidth = _buttonSize * 3 + _buttonGap * 2;
