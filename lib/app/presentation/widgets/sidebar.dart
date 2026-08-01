import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/components/layout/app_clickable_area.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_icons.dart';
import 'package:window_manager/window_manager.dart';

class _SidebarMetrics {
  const _SidebarMetrics._();

  static const width = 224.0;
  static const topDragAreaHeight = 60.0;
  static const horizontalInset = 16.0;
  static const sectionGap = 16.0;
  static const itemHeight = 36.0;
  static const itemVerticalGap = 1.0;
  static const itemHorizontalPadding = 12.0;
  static const itemRadius = 8.0;
  static const itemIconSize = 17.0;
  static const itemIconLabelGap = 10.0;
}

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: _SidebarMetrics.width,
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground(context),
        border: Border(
          right: BorderSide(color: theme.dividerColor, width: 1), // 使用主题分割线颜色
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部拖动区域为 macOS 原生按钮和 Windows 自绘按钮留出空间。
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (_) => windowManager.startDragging(),
            child: const SizedBox(
              height: _SidebarMetrics.topDragAreaHeight,
              width: double.infinity,
            ),
          ),

          _buildSectionTitle("媒体库", context),
          _buildGroup([
            _ItemConfig(AppIcons.libraryHome, "首页", 0),
            _ItemConfig(AppIcons.movies, "电影", 1),
            _ItemConfig(AppIcons.series, "剧集", 2),
          ]),

          const SizedBox(height: _SidebarMetrics.sectionGap),

          _buildSectionTitle("来源", context),
          _buildGroup([_ItemConfig(AppIcons.fileBrowser, "文件浏览", 3)]),

          const SizedBox(height: _SidebarMetrics.sectionGap),

          _buildSectionTitle("列表", context),
          _buildGroup([_ItemConfig(AppIcons.favorites, "收藏", 4)]),

          const Spacer(),
          Divider(height: 1, color: theme.dividerColor),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _SidebarMetrics.horizontalInset,
            ),
            child: _SidebarItem(
              icon: AppIcons.settings,
              title: "设置",
              index: 5,
              selectedIndex: selectedIndex,
              onTap: onItemSelected,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(
            context,
          ).textTheme.titleMedium?.color?.withAlpha((255 * 0.6).round()),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _buildGroup(List<_ItemConfig> items) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _SidebarMetrics.horizontalInset,
            vertical: _SidebarMetrics.itemVerticalGap,
          ),
          child: _SidebarItem(
            icon: item.icon,
            title: item.title,
            index: item.index,
            selectedIndex: selectedIndex,
            onTap: onItemSelected,
          ),
        );
      }).toList(),
    );
  }
}

class _ItemConfig {
  final IconData icon;
  final String title;
  final int index;

  _ItemConfig(this.icon, this.title, this.index);
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = selectedIndex == index;
    final primary = AppColors.primary(context);
    final selectedBackground = AppColors.selectedSurface(context);
    final restingForeground = theme.textTheme.titleMedium!.color!;
    final foregroundColor = isSelected ? primary : restingForeground;

    return AppClickableArea(
      onTap: () => onTap(index),
      height: _SidebarMetrics.itemHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: _SidebarMetrics.itemHorizontalPadding,
      ),
      borderRadius: BorderRadius.circular(_SidebarMetrics.itemRadius),
      backgroundColor: isSelected ? selectedBackground : Colors.transparent,
      hoverColor: isSelected
          ? Colors.transparent
          : AppColors.hoverSurface(context),
      child: Row(
        children: [
          Icon(
            icon,
            size: _SidebarMetrics.itemIconSize,
            color: foregroundColor,
          ),
          const SizedBox(width: _SidebarMetrics.itemIconLabelGap),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
