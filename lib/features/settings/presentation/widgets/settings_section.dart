import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.subtitle, required this.groups});

  /// The heading displayed above this tab's related settings cards.
  final String title;

  /// Explains the scope of this settings tab.
  final String subtitle;

  /// Visually independent groups of related settings.
  ///
  /// Each group is normally an [AppFormGroup], which supplies the card surface
  /// and dividers between its individual form rows.
  final List<Widget> groups;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context)),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context))),
        const SizedBox(height: AppSpacing.xxl),
        for (var index = 0; index < groups.length; index++) ...[
          if (index != 0) const SizedBox(height: AppSpacing.xl),
          groups[index],
        ],
      ],
    );
  }
}
