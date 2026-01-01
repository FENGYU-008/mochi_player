import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:window_manager/window_manager.dart';

class MacosTrafficLights extends StatefulWidget {
  const MacosTrafficLights({super.key});

  @override
  State<MacosTrafficLights> createState() => _MacosTrafficLightsState();
}

class _MacosTrafficLightsState extends State<MacosTrafficLights>
    with WindowListener {
  bool _isMaximized = false;
  bool _isHovered = false;
  bool _isWindowFocused = true;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowFocus() {
    setState(() {
      _isWindowFocused = true;
    });
  }

  @override
  void onWindowBlur() {
    setState(() {
      _isWindowFocused = false;
    });
  }

  Future<void> _checkMaximized() async {
    final isMaximized = await windowManager.isMaximized();
    if (mounted && isMaximized != _isMaximized) {
      setState(() {
        _isMaximized = isMaximized;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TrafficLightButton(
              normalIcon: 'assets/icons/1-close-1-normal.svg',
              hoverIcon: 'assets/icons/2-close-2-hover.svg',
              pressIcon: 'assets/icons/2-close-3-press.svg',
              noFocusIcon: isDark
                  ? 'assets/icons/0-all-three-nofocus-dark.svg'
                  : 'assets/icons/0-all-three-nofocus.svg',
              onPressed: () => windowManager.close(),
              isGroupHovered: _isHovered,
              isWindowFocused: _isWindowFocused,
            ),
            const SizedBox(width: 8),
            _TrafficLightButton(
              normalIcon: 'assets/icons/2-minimize-1-normal.svg',
              hoverIcon: 'assets/icons/2-minimize-2-hover.svg',
              pressIcon: 'assets/icons/2-minimize-3-press.svg',
              noFocusIcon: isDark
                  ? 'assets/icons/0-all-three-nofocus-dark.svg'
                  : 'assets/icons/0-all-three-nofocus.svg',
              onPressed: () => windowManager.minimize(),
              isGroupHovered: _isHovered,
              isWindowFocused: _isWindowFocused,
            ),
            const SizedBox(width: 8),
            _TrafficLightButton(
              normalIcon: 'assets/icons/3-maximize-1-normal.svg',
              hoverIcon: 'assets/icons/3-maximize-2-hover.svg',
              pressIcon: 'assets/icons/3-maximize-3-press.svg',
              noFocusIcon: isDark
                  ? 'assets/icons/0-all-three-nofocus-dark.svg'
                  : 'assets/icons/0-all-three-nofocus.svg',
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
                _checkMaximized();
              },
              isGroupHovered: _isHovered,
              isWindowFocused: _isWindowFocused,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrafficLightButton extends StatefulWidget {
  final String normalIcon;
  final String hoverIcon;
  final String pressIcon;
  final String noFocusIcon;
  final VoidCallback onPressed;
  final bool isGroupHovered;
  final bool isWindowFocused;

  const _TrafficLightButton({
    required this.normalIcon,
    required this.hoverIcon,
    required this.pressIcon,
    required this.noFocusIcon,
    required this.onPressed,
    required this.isGroupHovered,
    required this.isWindowFocused,
  });

  @override
  State<_TrafficLightButton> createState() => _TrafficLightButtonState();
}

class _TrafficLightButtonState extends State<_TrafficLightButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    String iconToShow;
    if (!widget.isWindowFocused) {
      iconToShow = widget.noFocusIcon;
    } else if (_isPressed) {
      iconToShow = widget.pressIcon;
    } else if (widget.isGroupHovered) {
      iconToShow = widget.hoverIcon;
    } else {
      iconToShow = widget.normalIcon;
    }

    return GestureDetector(
      onTap: widget.onPressed,
      child: Listener(
        onPointerDown: (_) => setState(() => _isPressed = true),
        onPointerUp: (_) => setState(() => _isPressed = false),
        child: SizedBox(
          width: 12,
          height: 12,
          child: SvgPicture.asset(iconToShow),
        ),
      ),
    );
  }
}
