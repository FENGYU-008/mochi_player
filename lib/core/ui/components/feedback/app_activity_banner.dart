import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

enum AppActivityBannerTone { progress, success, error, info }

class AppActivityBanner extends StatelessWidget {
  final String message;
  final double? progress;
  final AppActivityBannerTone tone;

  const AppActivityBanner({
    super.key,
    required this.message,
    this.progress,
    this.tone = AppActivityBannerTone.info,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseSurfaceColor = theme.brightness == Brightness.light
        ? Colors.white.withAlpha(235)
        : const Color(0xFF1F1F22).withAlpha(242);
    final accentColor = _accentColor(context);
    final isStatusMessage =
        tone == AppActivityBannerTone.success ||
        tone == AppActivityBannerTone.error;
    final surfaceColor = isStatusMessage
        ? Color.alphaBlend(accentColor.withAlpha(26), baseSurfaceColor)
        : baseSurfaceColor;
    final borderColor = isStatusMessage
        ? accentColor.withAlpha(150)
        : theme.dividerColor;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.compact,
          AppSpacing.md,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppRadii.control),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: (isStatusMessage ? accentColor : Colors.black).withAlpha(
                isStatusMessage ? 42 : 30,
              ),
              blurRadius: isStatusMessage ? 22 : 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _buildLeading(accentColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  value: progress,
                  color: accentColor,
                  backgroundColor: theme.dividerColor.withAlpha(115),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(Color accentColor) {
    switch (tone) {
      case AppActivityBannerTone.progress:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: progress,
            color: accentColor,
          ),
        );
      case AppActivityBannerTone.success:
        return Icon(
          Icons.check_circle_outline_rounded,
          size: 18,
          color: accentColor,
        );
      case AppActivityBannerTone.error:
        return Icon(Icons.error_outline_rounded, size: 18, color: accentColor);
      case AppActivityBannerTone.info:
        return Icon(Icons.info_outline_rounded, size: 18, color: accentColor);
    }
  }

  Color _accentColor(BuildContext context) {
    switch (tone) {
      case AppActivityBannerTone.progress:
      case AppActivityBannerTone.info:
        return Theme.of(context).colorScheme.primary;
      case AppActivityBannerTone.success:
        return Colors.green;
      case AppActivityBannerTone.error:
        return Theme.of(context).colorScheme.error;
    }
  }
}
