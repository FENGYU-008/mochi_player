import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

class SettingsTestButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SettingsTestButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppActionButton(
      onPressed: onPressed,
      label: '测试连接',
      variant: AppButtonVariant.secondary,
      height: AppControlMetrics.inputHeight,
      borderRadius: AppRadii.control,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      textStyle: AppTypography.controlLabel,
    );
  }
}
