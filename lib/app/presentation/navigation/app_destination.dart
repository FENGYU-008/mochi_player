import 'package:flutter/widgets.dart';
import 'package:mochi_player/core/ui/theme/app_icons.dart';

enum AppDestination {
  home(title: '首页', icon: AppIcons.libraryHome, showsHeader: true),
  movies(title: '电影', icon: AppIcons.movies, showsHeader: true),
  series(title: '剧集', icon: AppIcons.series, showsHeader: true),
  fileBrowser(title: '文件浏览', icon: AppIcons.fileBrowser),
  favorites(title: '收藏', icon: AppIcons.favorites, showsHeader: true),
  settings(title: '设置', icon: AppIcons.settings);

  final String title;
  final IconData icon;
  final bool showsHeader;

  const AppDestination({
    required this.title,
    required this.icon,
    this.showsHeader = false,
  });
}
