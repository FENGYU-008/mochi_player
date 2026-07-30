import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/theme/app_spacing.dart';

class AppErrorState extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool showIcon;

  const AppErrorState({
    super.key,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 42, color: errorColor),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: errorColor),
          ),
        ],
      ),
    );
  }
}
