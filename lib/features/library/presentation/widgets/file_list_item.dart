import 'package:flutter/material.dart';
import 'package:mochi_player/core/domain/media/media_file.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';
import 'file_entry_presentation.dart';

class FileListItem extends StatelessWidget {
  final MediaFile item;
  final VoidCallback? onTap;

  const FileListItem({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presentation = FileEntryPresentation(item);

    return FileEntryHoverSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.small),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Icon
          Icon(
            presentation.icon,
            color: presentation.iconColor(context),
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          // Title
          Expanded(
            flex: 5, // Give more space to title
            child: Text(
              item.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium!.color,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Date Modified
          Expanded(
            flex: 2,
            child: Text(
              presentation.modifiedAt,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.titleMedium!.color,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Size
          SizedBox(
            width: 80,
            child: Text(
              presentation.size,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.titleMedium!.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
