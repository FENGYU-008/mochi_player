import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

enum AppActivityBannerTone { progress, success, error, info }

class AppActivityBannerController {
  OverlayEntry? _entry;
  Timer? _dismissTimer;

  AppActivityBannerController._();

  void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    final entry = _entry;
    _entry = null;
    if (entry?.mounted ?? false) entry!.remove();
  }
}

AppActivityBannerController showAppActivityBanner({
  required BuildContext context,
  required String message,
  AppActivityBannerTone tone = AppActivityBannerTone.info,
  Duration? duration,
  double top = 70,
}) {
  final controller = AppActivityBannerController._();
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return controller;

  final entry = OverlayEntry(
    builder: (context) => Positioned(
      top: top,
      left: AppSpacing.page,
      right: AppSpacing.page,
      child: SafeArea(
        bottom: false,
        child: IgnorePointer(
          child: AppActivityBanner(message: message, tone: tone),
        ),
      ),
    ),
  );
  controller._entry = entry;
  overlay.insert(entry);

  if (duration != null) {
    controller._dismissTimer = Timer(duration, controller.dismiss);
  }
  return controller;
}

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
    final baseSurfaceColor = AppColors.activitySurface(context);
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

    return DefaultTextStyle.merge(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Align(
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
