import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mochi_player/core/domain/media/media_file_kind.dart';
import 'package:mochi_player/core/formatters/media_format.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_icons.dart';
import 'package:mochi_player/features/library/domain/file_browser_entry.dart';

extension FileBrowserEntryDisplay on FileBrowserEntry {
  IconData get browserIcon => switch (kind) {
    MediaFileKind.directory => AppIcons.folder,
    MediaFileKind.video => AppIcons.video,
    MediaFileKind.other => AppIcons.file,
  };

  String get browserTypeLabel => switch (kind) {
    MediaFileKind.directory => '文件夹',
    MediaFileKind.video => '视频',
    MediaFileKind.other => '文件',
  };

  String get browserSizeLabel => isDirectory ? '' : MediaFormat.fileSize(size);

  String get browserModifiedAtLabel => modifiedAt == null ? '—' : DateFormat('yyyy-MM-dd HH:mm').format(modifiedAt!);

  Color browserIconColor(BuildContext context) {
    return switch (kind) {
      MediaFileKind.video => Theme.of(context).colorScheme.primary,
      MediaFileKind.directory || MediaFileKind.other => AppColors.textSecondary(context),
    };
  }
}
