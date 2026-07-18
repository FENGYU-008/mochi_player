import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const SettingsSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(width: AppSpacing.compact),
            Expanded(
              child: Divider(
                color: AppColors.separator(context).withAlpha(120),
                height: 1,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.compact),
              trailing!,
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.compact),
        child,
      ],
    );
  }
}
