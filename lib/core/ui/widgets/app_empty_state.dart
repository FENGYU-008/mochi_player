import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final double iconSize;

  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.movie_outlined,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.textPrimary(context);
    final secondaryColor = AppColors.textSecondary(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: secondaryColor.withAlpha(120)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: TextStyle(fontSize: 18, color: textColor.withAlpha(210)),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              description!,
              style: TextStyle(fontSize: 14, color: secondaryColor),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
