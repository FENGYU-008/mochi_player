import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mochi_player/models/domain/media_file.dart';
import 'package:mochi_player/models/domain/media_type.dart';

class FileListItem extends StatefulWidget {
  final MediaFile item;
  final VoidCallback? onTap;

  const FileListItem({super.key, required this.item, this.onTap});

  @override
  State<FileListItem> createState() => _FileListItemState();
}

class _FileListItemState extends State<FileListItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isFolder = widget.item.mediaType == MediaType.folder;
    IconData iconData = isFolder
        ? Icons.folder_rounded
        : Icons.insert_drive_file_outlined;
    Color iconColor = isFolder
        ? theme.primaryColor
        : theme.textTheme.titleMedium!.color!;

    // 使用 lastWatchedAt 作为修改时间 (Provider 中已映射)
    final date = widget.item.lastWatchedAt ?? widget.item.addedAt;
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);

    String sizeText = '';
    if (!isFolder) {
      sizeText = widget.item.size > 0 ? _formatSize(widget.item.size) : '';
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isHovering
                ? theme.primaryColor.withAlpha(25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Icon
              Icon(iconData, color: iconColor, size: 24),
              const SizedBox(width: 12),
              // Title
              Expanded(
                flex: 5, // Give more space to title
                child: Text(
                  widget.item.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium!.color,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Date Modified
              Expanded(
                flex: 2,
                child: Text(
                  formattedDate,
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
                  sizeText,
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
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return "";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = 0;
    double size = bytes.toDouble();
    while (size > 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return "${size.toStringAsFixed(1)} ${suffixes[i]}";
  }
}
