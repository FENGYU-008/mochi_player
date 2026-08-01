import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/layout/app_clickable_area.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';

/// Compact text-editing menu shared by the application's text fields.
class AppTextContextMenu extends StatelessWidget {
  static const _screenMargin = 8.0;
  static const _menuWidth = 136.0;
  static const _itemHeight = 32.0;

  final TextSelectionToolbarAnchors anchors;
  final List<ContextMenuButtonItem> buttonItems;

  const AppTextContextMenu({
    super.key,
    required this.anchors,
    required this.buttonItems,
  });

  static Widget buildForEditableText(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    return AppTextContextMenu(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: editableTextState.contextMenuButtonItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top + _screenMargin;
    final localAdjustment = Offset(_screenMargin, topPadding);
    final shadowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withAlpha(112)
        : Colors.black.withAlpha(24);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _screenMargin,
        topPadding,
        _screenMargin,
        _screenMargin,
      ),
      child: CustomSingleChildLayout(
        delegate: DesktopTextSelectionToolbarLayoutDelegate(
          anchor: anchors.primaryAnchor - localAdjustment,
        ),
        child: SizedBox(
          width: _menuWidth,
          child: DefaultTextStyle(
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.selectMenuSurface(context),
                borderRadius: BorderRadius.circular(AppRadii.control),
                border: Border.all(color: AppColors.selectBorder(context)),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final item in buttonItems)
                      AppClickableArea(
                        onTap: item.onPressed,
                        height: _itemHeight,
                        borderRadius: BorderRadius.circular(AppRadii.small),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        hoverColor: AppColors.hoverSurface(context),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_labelFor(item)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _labelFor(ContextMenuButtonItem item) {
    return switch (item.type) {
      ContextMenuButtonType.cut => '剪切',
      ContextMenuButtonType.copy => '复制',
      ContextMenuButtonType.paste => '粘贴',
      ContextMenuButtonType.selectAll => '全选',
      ContextMenuButtonType.delete => '删除',
      ContextMenuButtonType.lookUp => '查询',
      ContextMenuButtonType.searchWeb => '网页搜索',
      ContextMenuButtonType.share => '分享',
      ContextMenuButtonType.liveTextInput => '实况文本',
      ContextMenuButtonType.custom => item.label ?? '操作',
    };
  }
}
