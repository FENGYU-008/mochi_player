import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
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
          // 顶部拖动区域同时为 macOS 原生窗口按钮留出空间。
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
            _ItemConfig(Icons.home_rounded, "首页", 0),
            _ItemConfig(Icons.movie_outlined, "电影", 1),
            _ItemConfig(Icons.tv, "剧集", 2),
          ]),

          const SizedBox(height: _SidebarMetrics.sectionGap),

          _buildSectionTitle("来源", context),
          _buildGroup([_ItemConfig(Icons.folder_open_outlined, "文件浏览", 3)]),

          const SizedBox(height: _SidebarMetrics.sectionGap),

          _buildSectionTitle("列表", context),
          _buildGroup([_ItemConfig(Icons.favorite_border, "收藏", 4)]),

          const Spacer(),
          Divider(height: 1, color: theme.dividerColor),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _SidebarMetrics.horizontalInset,
            ),
            child: _SidebarItem(
              icon: Icons.settings_outlined,
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

class _SidebarItem extends StatefulWidget {
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
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.selectedIndex == widget.index;
    final primary = AppColors.primary(context);
    final restingForeground = theme.textTheme.titleMedium!.color!;
    final hoverBackground = theme.textTheme.bodyMedium!.color!.withAlpha(
      (255 * 0.05).round(),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onTap(widget.index),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: isSelected ? 1 : 0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (context, selectionProgress, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween(end: _isHovering && !isSelected ? 1 : 0),
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              builder: (context, hoverProgress, child) {
                final unselectedBackground = Color.lerp(
                  Colors.transparent,
                  hoverBackground,
                  hoverProgress,
                )!;
                final backgroundColor = Color.lerp(
                  unselectedBackground,
                  primary,
                  selectionProgress,
                )!;
                final foregroundColor = Color.lerp(
                  restingForeground,
                  Colors.white,
                  selectionProgress,
                )!;
                return Container(
                  height: _SidebarMetrics.itemHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: _SidebarMetrics.itemHorizontalPadding,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(
                      _SidebarMetrics.itemRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.icon,
                        size: _SidebarMetrics.itemIconSize,
                        color: foregroundColor,
                      ),
                      const SizedBox(width: _SidebarMetrics.itemIconLabelGap),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: foregroundColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: child,
            );
          },
        ),
      ),
    );
  }
}
