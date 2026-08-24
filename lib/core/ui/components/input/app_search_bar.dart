import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mochi_player/core/ui/components/overlay/app_text_context_menu.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';
import 'package:mochi_player/core/ui/theme/app_theme.dart';

class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final double width;

  const AppSearchBar({
    super.key,
    this.hintText = '搜索...',
    this.onChanged,
    this.width = 240,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _focusNode.removeListener(_handleFocusChange);
    _controller.removeListener(_handleTextChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final hasFocus = _focusNode.hasFocus;
    if (_hasFocus == hasFocus) return;
    setState(() {
      _hasFocus = hasFocus;
    });
  }

  void _handleTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText == hasText) return;
    setState(() {
      _hasText = hasText;
    });
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (!TickerMode.of(context)) return false;
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
      if (!isCurrentRoute) return false;

      if (event.logicalKey == LogicalKeyboardKey.keyK &&
          (HardwareKeyboard.instance.isMetaPressed ||
              HardwareKeyboard.instance.isControlPressed)) {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
          return true;
        }
      }

      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<AppThemeExtension>()!;
    final themeColor = theme.primaryColor;
    final borderRadius = BorderRadius.circular(AppRadii.surface);

    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        height: 35,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: customTheme.searchBarColor,
                borderRadius: borderRadius,
              ),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                opacity: _hasFocus ? 1 : 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: themeColor.withAlpha(204),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.compact,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.search,
                    size: 18,
                    color: _hasFocus
                        ? theme.textTheme.bodyMedium?.color
                        : customTheme.searchBarIconColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: widget.onChanged,
                      contextMenuBuilder:
                          AppTextContextMenu.buildForEditableText,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: customTheme.searchBarHintColor,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      cursorColor: themeColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: _hasText ? _buildClearButton() : _buildKeyCapHint(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _controller.clear();
          widget.onChanged?.call('');
        },
        child: Container(
          key: const ValueKey('clear_button'),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.grey[300]?.withAlpha((255 * 0.5).round()),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close, size: 12, color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildKeyCapHint() {
    final isMac = Theme.of(context).platform == TargetPlatform.macOS;
    final modifierKey = isMac ? "⌘" : "Ctrl";

    return Row(
      key: const ValueKey('key_cap_hint'),
      children: [
        _buildKeyCap(modifierKey),
        const SizedBox(width: 4),
        _buildKeyCap("K"),
      ],
    );
  }

  Widget _buildKeyCap(String text) {
    final customTheme = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      width: text.length > 1 ? 28 : 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: customTheme.keyCapColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
        border: Border.all(color: Colors.black.withAlpha(13)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: customTheme.keyCapTextColor,
        ),
      ),
    );
  }
}
