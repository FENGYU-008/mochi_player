import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

const _controlHeight = 36.0;
const _fieldGap = 6.0;
const _inputHeight = 26.0;
const _defaultMaxWidth = 360.0;

class AppFormTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final String? suffixText;
  final double maxWidth;

  const AppFormTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.trailing,
    this.suffixText,
    this.maxWidth = _defaultMaxWidth,
  });

  @override
  State<AppFormTextField> createState() => _AppFormTextFieldState();
}

class _AppFormTextFieldState extends State<AppFormTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final textColor = AppColors.textPrimary(context);
    final secondaryColor = AppColors.textSecondary(context);
    final inputBackground = Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withAlpha(36)
        : Colors.white.withAlpha(210);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: widget.enabled ? 1 : 0.5,
      child: Container(
        height: _controlHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.compact),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 17,
              color: widget.enabled
                  ? secondaryColor
                  : secondaryColor.withAlpha(100),
            ),
            const SizedBox(width: _fieldGap),
            SizedBox(
              width: 120,
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.enabled ? textColor : secondaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.compact),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widget.maxWidth),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    height: _inputHeight,
                    decoration: BoxDecoration(
                      color: inputBackground,
                      borderRadius: BorderRadius.circular(AppRadii.small),
                      border: Border.all(
                        color: _focusNode.hasFocus
                            ? primary.withAlpha(215)
                            : AppColors.separator(context).withAlpha(150),
                        width: _focusNode.hasFocus ? 1.2 : 1,
                      ),
                    ),
                    child: CupertinoTextField(
                      controller: widget.controller,
                      enabled: widget.enabled,
                      focusNode: _focusNode,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      cursorColor: primary,
                      cursorHeight: 14,
                      textAlign: widget.suffixText == null
                          ? TextAlign.start
                          : TextAlign.end,
                      textAlignVertical: TextAlignVertical.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: null,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.suffixText != null) ...[
              const SizedBox(width: _fieldGap),
              Text(
                widget.suffixText!,
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (widget.trailing != null) ...[
              const SizedBox(width: AppSpacing.xs),
              widget.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
