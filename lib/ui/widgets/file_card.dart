import 'package:flutter/material.dart';
import '../../models/domain/media_file.dart';
import '../../models/domain/media_type.dart';

class FileCard extends StatefulWidget {
  final MediaFile item;
  final VoidCallback? onTap;

  const FileCard({super.key, required this.item, this.onTap});

  @override
  State<FileCard> createState() => _FileCardState();
}

class _FileCardState extends State<FileCard> {
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

    String subtitle = "";
    if (isFolder) {
      subtitle = "文件夹";
    } else {
      String sizeText = widget.item.size > 0
          ? _formatSize(widget.item.size)
          : "";
      subtitle = sizeText;
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
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _isHovering
                ? theme.primaryColor.withAlpha(25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovering
                  ? theme.primaryColor.withAlpha(77)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // === 图标区域 ===
              Expanded(
                child: Icon(
                  iconData,
                  size: 56, // 稍微减小图标尺寸
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 8),
              // === 标题 ===
              Text(
                widget.item.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _isHovering
                      ? theme.primaryColor
                      : theme.textTheme.bodyMedium!.color,
                ),
              ),
              const SizedBox(height: 2),
              // === 副标题 ===
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
