import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mochi_player/core/domain/media/models.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

class FileEntryPresentation {
  final MediaFile item;

  const FileEntryPresentation(this.item);

  bool get isFolder => item.mediaType == MediaType.folder;
  IconData get icon =>
      isFolder ? Icons.folder_rounded : Icons.insert_drive_file_outlined;
  String get size => isFolder ? '' : MediaFormat.fileSize(item.size);
  String get modifiedAt =>
      DateFormat('yyyy-MM-dd HH:mm').format(item.lastWatchedAt ?? item.addedAt);

  Color iconColor(BuildContext context) => isFolder
      ? Theme.of(context).primaryColor
      : Theme.of(context).textTheme.titleMedium!.color!;
}

class FileEntryHoverSurface extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool showBorder;
  final Duration duration;

  const FileEntryHoverSurface({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.padding,
    this.onTap,
    this.showBorder = false,
    this.duration = const Duration(milliseconds: 160),
  });

  @override
  State<FileEntryHoverSurface> createState() => _FileEntryHoverSurfaceState();
}

class _FileEntryHoverSurfaceState extends State<FileEntryHoverSurface> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        borderRadius: widget.borderRadius,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _hovering ? primary.withAlpha(25) : Colors.transparent,
            borderRadius: widget.borderRadius,
            border: widget.showBorder
                ? Border.all(
                    color: _hovering
                        ? primary.withAlpha(77)
                        : Colors.transparent,
                  )
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
