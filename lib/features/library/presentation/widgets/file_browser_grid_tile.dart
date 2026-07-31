import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/layout/app_hover_surface.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';
import 'package:mochi_player/features/library/presentation/widgets/file_browser_item_presentation.dart';
import 'package:mochi_player/features/library/domain/file_browser_entry.dart';

class FileBrowserGridTile extends StatelessWidget {
  final FileBrowserEntry item;
  final VoidCallback? onTap;

  const FileBrowserGridTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = item.isDirectory
        ? item.browserTypeLabel
        : '${item.browserTypeLabel} · ${item.browserSizeLabel}';

    return AppHoverSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.control),
      padding: const EdgeInsets.all(AppSpacing.md),
      hoverColor: AppColors.hoverSurface(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Icon(
              item.browserIcon,
              size: 42,
              color: item.browserIconColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyMedium!.color,
            ),
          ),
          const SizedBox(height: 2),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: theme.textTheme.titleMedium!.color,
              ),
            ),
        ],
      ),
    );
  }
}
