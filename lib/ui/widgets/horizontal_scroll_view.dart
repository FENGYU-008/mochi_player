import 'package:flutter/material.dart';
import 'dart:ui'; // 引入 dart:ui 以使用 ImageFilter

class HorizontalScrollView extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final double bottomPadding;

  const HorizontalScrollView({super.key, required this.child, required this.controller, this.bottomPadding = 0});

  @override
  State<HorizontalScrollView> createState() => _HorizontalScrollViewState();
}

class _HorizontalScrollViewState extends State<HorizontalScrollView> {
  bool _isHovering = false;
  bool _showLeftButton = false;
  bool _showRightButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.addListener(_updateButtonVisibility);
        _updateButtonVisibility();
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateButtonVisibility);
    super.dispose();
  }

  void _updateButtonVisibility() {
    if (!mounted || !widget.controller.hasClients) return;

    final position = widget.controller.position;
    // 增加一点容差 (pixels > 5)，避免刚开始滚动一点点就闪烁
    final bool canScrollLeft = position.pixels > 5;
    final bool canScrollRight = position.pixels < position.maxScrollExtent - 5;

    if (_showLeftButton != canScrollLeft || _showRightButton != canScrollRight) {
      setState(() {
        _showLeftButton = canScrollLeft;
        _showRightButton = canScrollRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        children: [
          widget.child,

          // 左侧按钮
          Positioned(
            left: 20, // 稍微靠里一点，不要贴边
            top: 0,
            bottom: widget.bottomPadding,
            child: Center(
              child: _GlassScrollButton(
                icon: Icons.arrow_back_ios_new,
                // 只有当鼠标悬停在区域内 且 可以向左滚动时才显示
                isVisible: _isHovering && _showLeftButton,
                onTap: () => _scroll(-600),
              ),
            ),
          ),

          // 右侧按钮
          Positioned(
            right: 20, // 稍微靠里一点
            top: 0,
            bottom: widget.bottomPadding,
            child: Center(
              child: _GlassScrollButton(
                icon: Icons.arrow_forward_ios,
                // 只有当鼠标悬停在区域内 且 可以向右滚动时才显示
                isVisible: _isHovering && _showRightButton,
                onTap: () => _scroll(600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _scroll(double offset) {
    final target = widget.controller.offset + offset;
    widget.controller.animateTo(
      target.clamp(0.0, widget.controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 600), // 稍微慢一点，更优雅
      curve: Curves.easeOutQuart, // 更平滑的曲线
    );
  }
}

// === 新增：磨砂玻璃风格悬浮按钮 ===
class _GlassScrollButton extends StatefulWidget {
  final IconData icon;
  final bool isVisible;
  final VoidCallback onTap;

  const _GlassScrollButton({required this.icon, required this.isVisible, required this.onTap});

  @override
  State<_GlassScrollButton> createState() => _GlassScrollButtonState();
}

class _GlassScrollButtonState extends State<_GlassScrollButton> {
  bool _isHoveringButton = false;

  @override
  Widget build(BuildContext context) {
    // 使用 AnimatedOpacity 实现淡入淡出
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: widget.isVisible ? 1.0 : 0.0,
      // 当不可见时，忽略点击事件
      child: IgnorePointer(
        ignoring: !widget.isVisible,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHoveringButton = true),
          onExit: (_) => setState(() => _isHoveringButton = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30), // 圆形
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 高斯模糊
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((255 * (_isHoveringButton ? 0.6 : 0.4)).round()), // 半透明黑底
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha((255 * 0.1).round()), // 极细的微光边框
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.2).round()),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: Colors.white.withAlpha((255 * 0.9).round()), size: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
