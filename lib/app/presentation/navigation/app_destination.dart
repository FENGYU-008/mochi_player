import 'package:flutter/widgets.dart';
import 'package:mochi_player/core/ui/theme/app_icons.dart';

enum AppDestination {
  home(pathSegment: 'home', title: '首页', icon: AppIcons.libraryHome, showsHeader: true),
  movies(pathSegment: 'movies', title: '电影', icon: AppIcons.movies, showsHeader: true),
  series(pathSegment: 'series', title: '剧集', icon: AppIcons.series, showsHeader: true),
  fileBrowser(pathSegment: 'files', title: '文件浏览', icon: AppIcons.fileBrowser),
  favorites(pathSegment: 'favorites', title: '收藏', icon: AppIcons.favorites, showsHeader: true),
  settings(pathSegment: 'settings', title: '设置', icon: AppIcons.settings);

  final String pathSegment;
  final String title;
  final IconData icon;
  final bool showsHeader;

  const AppDestination({required this.pathSegment, required this.title, required this.icon, this.showsHeader = false});

  String get path => '/$pathSegment';
}
