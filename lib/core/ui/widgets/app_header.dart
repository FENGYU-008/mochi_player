import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_spacing.dart';
import 'search_bar.dart';

class AppHeader extends StatelessWidget {
  static const double height = 60;

  final String title;
  final Widget? leading;
  final bool showSearch;
  final double opacity;
  final bool ignoreWhenTransparent;

  const AppHeader({
    super.key,
    required this.title,
    this.leading,
    this.showSearch = true,
    this.opacity = 1,
    this.ignoreWhenTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedOpacity = opacity.clamp(0.0, 1.0).toDouble();
    final backgroundColor = theme.brightness == Brightness.light
        ? Colors.white.withAlpha((255 * 0.85).round())
        : const Color(0xFF2C2C2E).withAlpha((255 * 0.85).round());

    return IgnorePointer(
      ignoring: ignoreWhenTransparent && clampedOpacity < 0.1,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: clampedOpacity,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (_) => windowManager.startDragging(),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: height,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor.withAlpha(
                        (255 * clampedOpacity).round(),
                      ),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    if (showSearch) ...[
                      const SizedBox(width: 20),
                      const AppSearchBar(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
