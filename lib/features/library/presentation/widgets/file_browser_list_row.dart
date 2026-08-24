import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mochi_player/core/ui/components/basic/app_clickable_area.dart';
import 'package:mochi_player/core/ui/components/overlay/app_menu_button.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_icons.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';
import 'package:mochi_player/features/library/presentation/widgets/file_browser_entry_display.dart';
import 'package:mochi_player/features/library/domain/file_browser_entry.dart';

class FileBrowserListRow extends StatelessWidget {
  final FileBrowserEntry item;
  final VoidCallback? onTap;

  const FileBrowserListRow({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppClickableArea(
      onTap: onTap,
      borderRadius: BorderRadius.zero,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      hoverColor: AppColors.hoverSurface(context),
      child: Row(
        children: [
          Icon(
            item.browserIcon,
            color: item.browserIconColor(context),
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium!.color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.browserTypeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          SizedBox(
            width: 120,
            child: Text(
              item.isDirectory ? '—' : item.browserSizeLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.browserModifiedAtLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          SizedBox(
            width: 38,
            child: AppMenuButton<_FileBrowserItemAction>(
              tooltip: '更多操作',
              onSelected: _handleAction,
              options: [
                if (item.isDirectory || item.isPlayable)
                  AppMenuOption(
                    value: _FileBrowserItemAction.open,
                    label: item.isDirectory ? '打开' : '播放',
                  ),
                const AppMenuOption(
                  value: _FileBrowserItemAction.copyPath,
                  label: '复制路径',
                ),
              ],
              child: SizedBox(
                width: 38,
                height: 34,
                child: Icon(
                  AppIcons.more,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(_FileBrowserItemAction action) {
    switch (action) {
      case _FileBrowserItemAction.open:
        onTap?.call();
      case _FileBrowserItemAction.copyPath:
        Clipboard.setData(ClipboardData(text: item.path));
    }
  }
}

enum _FileBrowserItemAction { open, copyPath }
