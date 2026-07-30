import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/buttons/app_button.dart';
import 'package:mochi_player/core/ui/components/overlays/app_modal.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';
import 'package:mochi_player/core/ui/theme/app_typography.dart';

Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  IconData icon = Icons.help_outline_rounded,
  bool destructive = false,
}) {
  return showAppModal<bool>(
    context: context,
    barrierLabel: '关闭确认对话框',
    maxWidth: 440,
    maxHeightFactor: 0.7,
    child: Builder(
      builder: (dialogContext) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        icon: icon,
        destructive: destructive,
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    ),
  );
}

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final IconData icon;
  final bool destructive;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.icon = Icons.help_outline_rounded,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? Colors.redAccent : AppColors.primary(context);
    final borderRadius = BorderRadius.circular(AppRadii.card);

    return Container(
      width: 440,
      decoration: BoxDecoration(
        color: AppColors.modalSurface(context),
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.separator(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(54),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: accent.withAlpha(24),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 17, color: accent),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                message,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 96,
                    child: AppActionButton(
                      onPressed: onCancel,
                      label: '取消',
                      variant: AppButtonVariant.secondary,
                      height: 34,
                      borderRadius: AppRadii.control,
                      padding: EdgeInsets.zero,
                      textStyle: AppTypography.controlLabel,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 96,
                    child: AppActionButton(
                      onPressed: onConfirm,
                      label: confirmLabel,
                      destructive: destructive,
                      height: 34,
                      borderRadius: AppRadii.control,
                      padding: EdgeInsets.zero,
                      textStyle: AppTypography.controlLabel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
