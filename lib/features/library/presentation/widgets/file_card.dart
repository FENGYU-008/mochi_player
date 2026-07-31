import 'package:flutter/material.dart';
import 'package:mochi_player/core/domain/media/media_file.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';
import 'file_entry_presentation.dart';

class FileCard extends StatelessWidget {
  final MediaFile item;
  final VoidCallback? onTap;

  const FileCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presentation = FileEntryPresentation(item);
    final subtitle = presentation.isFolder ? '文件夹' : presentation.size;

    return FileEntryHoverSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.control),
      padding: const EdgeInsets.all(AppSpacing.md),
      showBorder: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Icon(
              presentation.icon,
              size: 56,
              color: presentation.iconColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.fileName,
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
