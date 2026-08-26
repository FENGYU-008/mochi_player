import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mochi_player/core/ui/components/input/internal/app_text_context_menu.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_control_metrics.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';
import 'package:mochi_player/core/ui/theme/app_theme.dart';
import 'package:mochi_player/core/ui/theme/app_typography.dart';

enum _AppInputVariant { standard, search }

/// The shared text input used by application forms and composed inputs.
class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    required this.controller,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onFocusLost,
    this.inputFormatters,
    this.placeholder,
    this.prefix,
    this.suffix,
  }) : _variant = _AppInputVariant.standard;

  const AppInput.search({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.prefix,
    this.suffix,
  }) : enabled = true,
       obscureText = false,
       keyboardType = null,
       textAlign = TextAlign.start,
       onFocusLost = null,
       inputFormatters = null,
       _variant = _AppInputVariant.search;

  final TextEditingController controller;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFocusLost;
  final List<TextInputFormatter>? inputFormatters;
  final String? placeholder;
  final Widget? prefix;
  final Widget? suffix;
  final _AppInputVariant _variant;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  bool _wasFocused = false;

  @override
  void initState() {
    super.initState();
    _attachFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(AppInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode == widget.focusNode) return;
    _detachFocusNode();
    _attachFocusNode(widget.focusNode);
  }

  @override
  void dispose() {
    _detachFocusNode();
    super.dispose();
  }

  void _attachFocusNode(FocusNode? focusNode) {
    _ownsFocusNode = focusNode == null;
    _focusNode = focusNode ?? FocusNode();
    _wasFocused = _focusNode.hasFocus;
    _focusNode.addListener(_handleFocusChange);
  }

  void _detachFocusNode() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
  }

  void _handleFocusChange() {
    final hasFocus = _focusNode.hasFocus;
    if (_wasFocused && !hasFocus) widget.onFocusLost?.call();
    _wasFocused = hasFocus;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSearch = widget._variant == _AppInputVariant.search;
    final primary = AppColors.primary(context);
    final textColor = AppColors.textPrimary(context);
    final inputBackground = AppColors.inputBackground(context);
    final searchBackground = theme
        .extension<AppThemeExtension>()!
        .searchBarColor;
    final focusedBorder = primary.withAlpha(isSearch ? 204 : 215);
    final restingBorder = isSearch
        ? Colors.transparent
        : widget.enabled
        ? focusedBorder.withAlpha(0)
        : AppColors.separator(context).withAlpha(90);
    final restingBackground = isSearch
        ? searchBackground
        : widget.enabled
        ? inputBackground.withAlpha(0)
        : inputBackground.withAlpha(85);
    final focusedBackground = isSearch ? searchBackground : inputBackground;
    final borderRadius = BorderRadius.circular(
      isSearch ? AppRadii.surface : AppRadii.small,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(end: widget.enabled && _focusNode.hasFocus ? 1 : 0),
      duration: AppControlMetrics.stateAnimationDuration,
      curve: Curves.easeOut,
      builder: (context, focusProgress, child) {
        return SizedBox(
          height: isSearch ? 35 : AppControlMetrics.inputHeight,
          child: ClipRRect(
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color.lerp(
                  restingBackground,
                  focusedBackground,
                  focusProgress,
                ),
                borderRadius: borderRadius,
                border: Border.all(
                  color: Color.lerp(
                    restingBorder,
                    focusedBorder,
                    focusProgress,
                  )!,
                  width: isSearch ? 1.5 : 1,
                ),
              ),
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSearch ? AppSpacing.compact : AppSpacing.sm,
        ),
        child: Row(
          children: [
            if (widget.prefix != null) ...[
              widget.prefix!,
              SizedBox(width: isSearch ? 8 : AppControlMetrics.iconLabelGap),
            ],
            Expanded(
              child: CupertinoTextField(
                controller: widget.controller,
                enabled: widget.enabled,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                contextMenuBuilder: AppTextContextMenu.buildForEditableText,
                cursorColor: primary,
                cursorHeight: 14,
                textAlign: widget.textAlign,
                textAlignVertical: TextAlignVertical.center,
                padding: EdgeInsets.zero,
                placeholder: widget.placeholder,
                placeholderStyle: isSearch
                    ? TextStyle(
                        color: theme
                            .extension<AppThemeExtension>()!
                            .searchBarHintColor,
                        fontSize: 14,
                      )
                    : AppTypography.formValue.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                style: isSearch
                    ? TextStyle(fontSize: 14, color: textColor)
                    : AppTypography.formValue.copyWith(color: textColor),
                decoration: null,
              ),
            ),
            if (widget.suffix != null) ...[
              SizedBox(width: isSearch ? 4 : AppControlMetrics.iconLabelGap),
              widget.suffix!,
            ],
          ],
        ),
      ),
    );
  }
}
