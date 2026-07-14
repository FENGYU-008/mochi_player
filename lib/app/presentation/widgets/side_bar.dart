import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/app/presentation/widgets/macos_traffic_lights.dart';
import 'package:window_manager/window_manager.dart';

class SideBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground(context),
        border: Border(
          right: BorderSide(color: theme.dividerColor, width: 1), // 使用主题分割线颜色
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部拖动区域，为 macOS 原生红绿灯按钮留出空间
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) {
              windowManager.startDragging();
            },
            child: const SizedBox(
              height: 60,
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: MacosTrafficLights(),
              ),
            ),
          ),

          _buildSectionTitle("媒体库", context),
          _buildGroup([
            _ItemConfig(Icons.home_rounded, "首页", 0),
            _ItemConfig(Icons.movie_outlined, "电影", 1),
            _ItemConfig(Icons.tv, "剧集", 2),
          ]),

          const SizedBox(height: 24),

          _buildSectionTitle("来源", context),
          _buildGroup([_ItemConfig(Icons.folder_open_outlined, "文件浏览", 3)]),

          const SizedBox(height: 24),

          _buildSectionTitle("列表", context),
          _buildGroup([_ItemConfig(Icons.favorite_border, "收藏", 4)]),

          const Spacer(),
          Divider(height: 1, color: theme.dividerColor),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SideBarItem(
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: _SideBarItem(
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

class _SideBarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const _SideBarItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<_SideBarItem> createState() => _SideBarItemState();
}

class _SideBarItemState extends State<_SideBarItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.selectedIndex == widget.index;

    Color backgroundColor = Colors.transparent;
    if (isSelected) {
      backgroundColor = AppColors.primary(context);
    } else if (_isHovering) {
      backgroundColor = theme.textTheme.bodyMedium!.color!.withAlpha(
        (255 * 0.05).round(),
      );
    }

    final foregroundColor = isSelected
        ? Colors.white
        : theme.textTheme.titleMedium!.color!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onTap(widget.index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: foregroundColor),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
