import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/components/forms/app_form_row.dart';
import 'package:mochi_player/core/ui/components/forms/app_text_field.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_control_metrics.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';
import 'package:mochi_player/core/ui/theme/app_typography.dart';

class AppFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final String? suffixText;
  final double maxWidth;
  final VoidCallback? onFocusLost;

  const AppFormTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.trailing,
    this.suffixText,
    this.maxWidth = AppControlMetrics.defaultFieldWidth,
    this.onFocusLost,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = AppColors.textSecondary(context);
    return AppFormRow(
      icon: icon,
      label: label,
      enabled: enabled,
      control: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller,
                  enabled: enabled,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  onFocusLost: onFocusLost,
                  textAlign: suffixText == null
                      ? TextAlign.start
                      : TextAlign.end,
                  maxWidth: double.infinity,
                ),
              ),
              if (suffixText != null) ...[
                const SizedBox(width: AppControlMetrics.iconLabelGap),
                Text(
                  suffixText!,
                  style: AppTypography.formSuffix.copyWith(
                    color: secondaryColor,
                  ),
                ),
              ],
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.xs),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
