import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_control_metrics.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';
import 'package:mochi_player/core/ui/theme/app_typography.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final double maxWidth;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.maxWidth = AppControlMetrics.defaultFieldWidth,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  late bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _attachFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
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
    _focusNode.addListener(_handleFocusChange);
  }

  void _detachFocusNode() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final textColor = AppColors.textPrimary(context);
    final inputBackground = AppColors.inputBackground(context);
    final focusedBorder = primary.withAlpha(215);
    final restingBorder = widget.enabled
        ? focusedBorder.withAlpha(0)
        : AppColors.separator(context).withAlpha(90);
    final restingBackground = widget.enabled
        ? inputBackground.withAlpha(0)
        : inputBackground.withAlpha(85);
    final borderRadius = BorderRadius.circular(AppRadii.small);

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: widget.enabled && _focusNode.hasFocus ? 1 : 0),
          duration: AppControlMetrics.stateAnimationDuration,
          curve: Curves.easeOut,
          builder: (context, focusProgress, child) {
            return SizedBox(
              height: AppControlMetrics.inputHeight,
              child: ClipRRect(
                borderRadius: borderRadius,
                clipBehavior: Clip.antiAlias,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      restingBackground,
                      inputBackground,
                      focusProgress,
                    ),
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: Color.lerp(
                        restingBorder,
                        focusedBorder,
                        focusProgress,
                      )!,
                    ),
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: CupertinoTextField(
            controller: widget.controller,
            enabled: widget.enabled,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            cursorColor: primary,
            cursorHeight: 14,
            textAlign: widget.textAlign,
            textAlignVertical: TextAlignVertical.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            style: AppTypography.formValue.copyWith(color: textColor),
            decoration: null,
          ),
        ),
      ),
    );
  }
}
