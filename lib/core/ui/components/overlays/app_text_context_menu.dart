import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/overlays/app_popup_menu.dart';

/// Compact text-editing menu shared by the application's text fields.
class AppTextContextMenu extends StatelessWidget {
  static const _screenMargin = 8.0;
  static const _menuWidth = 136.0;

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
          child: AppPopupMenuPanel(
            children: [
              for (final item in buttonItems)
                AppPopupMenuItem(
                  onPressed: item.onPressed,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_labelFor(item)),
                  ),
                ),
            ],
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
