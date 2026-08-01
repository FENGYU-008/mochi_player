import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:mochi_player/core/ui/components/forms/search_bar.dart';
import 'package:mochi_player/core/ui/components/buttons/app_icon_button.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

class AppHeader extends StatelessWidget {
  static const double height = 60;

  final String title;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBack;
  final String? subtitle;
  final List<Widget> actions;
  final bool showSearch;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final double searchWidth;
  final double opacity;
  final bool ignoreWhenTransparent;

  const AppHeader({
    super.key,
    required this.title,
    this.leading,
    this.showBackButton = false,
    this.onBack,
    this.subtitle,
    this.actions = const [],
    this.showSearch = true,
    this.searchHint = '搜索...',
    this.onSearchChanged,
    this.searchWidth = 240,
    this.opacity = 1,
    this.ignoreWhenTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedOpacity = opacity.clamp(0.0, 1.0).toDouble();
    final backgroundColor = AppColors.headerBackground(context);
    final effectiveLeading =
        leading ??
        (showBackButton
            ? AppIconButton(
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                icon: Icons.arrow_back_rounded,
                tooltip: '返回',
                foregroundColor: AppColors.textPrimary(context),
                backgroundColor: AppColors.hoverSurface(context),
                size: 36,
                iconSize: 20,
              )
            : null);

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
                    if (effectiveLeading != null) ...[
                      effectiveLeading,
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: subtitle == null
                          ? Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subtitle!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                ),
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    if (actions.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      for (var index = 0; index < actions.length; index++) ...[
                        if (index > 0) const SizedBox(width: 8),
                        actions[index],
                      ],
                    ],
                    if (showSearch) ...[
                      const SizedBox(width: 20),
                      AppSearchBar(
                        hintText: searchHint,
                        onChanged: onSearchChanged,
                        width: searchWidth,
                      ),
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
