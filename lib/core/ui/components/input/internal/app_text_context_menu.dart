import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/components/overlay/internal/menu_parts.dart';

/// Internal adapter from Flutter text-editing actions to the application menu.
class AppTextContextMenu extends StatelessWidget {
  const AppTextContextMenu({super.key, required this.editableTextState});

  static const _screenMargin = 8.0;
  static const _menuWidth = 136.0;

  final EditableTextState editableTextState;

  static Widget buildForEditableText(BuildContext context, EditableTextState editableTextState) {
    return AppTextContextMenu(editableTextState: editableTextState);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ClipboardStatus>(
      valueListenable: editableTextState.clipboardStatus,
      builder: (context, clipboardStatus, child) {
        final topPadding = MediaQuery.paddingOf(context).top + _screenMargin;
        final localAdjustment = Offset(_screenMargin, topPadding);
        final buttonItems = _resolvedButtonItems(clipboardStatus);
        return Padding(
          padding: EdgeInsets.fromLTRB(_screenMargin, topPadding, _screenMargin, _screenMargin),
          child: CustomSingleChildLayout(
            delegate: DesktopTextSelectionToolbarLayoutDelegate(
              anchor: editableTextState.contextMenuAnchors.primaryAnchor - localAdjustment,
            ),
            child: SizedBox(
              width: _menuWidth,
              child: MenuPanel(
                children: [
                  for (final item in buttonItems)
                    MenuOptionRow(onPressed: item.onPressed, child: Text(_labelFor(item))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<ContextMenuButtonItem> _resolvedButtonItems(ClipboardStatus clipboardStatus) {
    final items = [...editableTextState.contextMenuButtonItems];
    final value = editableTextState.textEditingValue;
    final selection = value.selection;

    if (!items.any((item) => item.type == ContextMenuButtonType.paste)) {
      items.add(
        ContextMenuButtonItem(
          type: ContextMenuButtonType.paste,
          onPressed: clipboardStatus == ClipboardStatus.pasteable && !editableTextState.widget.readOnly
              ? () => editableTextState.pasteText(SelectionChangedCause.toolbar)
              : null,
        ),
      );
    }

    if (!items.any((item) => item.type == ContextMenuButtonType.selectAll)) {
      final allTextSelected = selection.isValid && selection.start == 0 && selection.end == value.text.length;
      items.add(
        ContextMenuButtonItem(
          type: ContextMenuButtonType.selectAll,
          onPressed: value.text.isNotEmpty && !allTextSelected
              ? () => editableTextState.selectAll(SelectionChangedCause.toolbar)
              : null,
        ),
      );
    }

    return items;
  }

  static String _labelFor(ContextMenuButtonItem item) {
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
