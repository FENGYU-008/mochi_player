import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/library/application/file_browser_provider.dart';

class FileBrowserToolbar extends StatelessWidget {
  final String currentPath;
  final bool canGoBack;
  final bool canGoForward;
  final FileBrowserViewMode viewMode;
  final FileSortField sortField;
  final bool sortAscending;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final ValueChanged<String> onPathSelected;
  final void Function(FileSortField field, bool ascending) onSortChanged;
  final ValueChanged<FileBrowserViewMode> onViewModeChanged;
  final VoidCallback onRefresh;

  const FileBrowserToolbar({
    super.key,
    required this.currentPath,
    required this.canGoBack,
    required this.canGoForward,
    required this.viewMode,
    required this.sortField,
    required this.sortAscending,
    required this.onBack,
    required this.onForward,
    required this.onPathSelected,
    required this.onSortChanged,
    required this.onViewModeChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToolbarGroup(
          children: [
            _ToolbarIconButton(icon: AppIcons.back, tooltip: '后退', onPressed: canGoBack ? onBack : null),
            _ToolbarIconButton(icon: AppIcons.forward, tooltip: '前进', onPressed: canGoForward ? onForward : null),
          ],
        ),
        const SizedBox(width: AppSpacing.compact),
        Expanded(
          child: _FilePathBreadcrumb(path: currentPath, onSelected: onPathSelected),
        ),
        const SizedBox(width: AppSpacing.md),
        _FileSortButton(field: sortField, ascending: sortAscending, onChanged: onSortChanged),
        const SizedBox(width: AppSpacing.compact),
        SizedBox(
          width: _viewModeControlWidth,
          child: AppSegmentedControl<FileBrowserViewMode>(
            value: viewMode,
            onChanged: onViewModeChanged,
            options: const [
              AppSegmentedOption.icon(value: FileBrowserViewMode.list, label: '列表视图', icon: AppIcons.list),
              AppSegmentedOption.icon(value: FileBrowserViewMode.grid, label: '网格视图', icon: AppIcons.grid),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.compact),
        _ToolbarGroup(
          children: [_ToolbarIconButton(icon: AppIcons.refresh, tooltip: '刷新目录', onPressed: onRefresh)],
        ),
      ],
    );
  }
}

class _FilePathBreadcrumb extends StatelessWidget {
  final String path;
  final ValueChanged<String> onSelected;

  const _FilePathBreadcrumb({required this.path, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final segments = path.split('/').where((segment) => segment.isNotEmpty);
    final crumbs = <({String label, String path})>[(label: '根目录', path: '/')];
    var accumulatedPath = '/';
    for (final segment in segments) {
      accumulatedPath = '$accumulatedPath$segment/';
      crumbs.add((label: segment, path: accumulatedPath));
    }

    return SizedBox(
      height: 34,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inputBackground(context),
          borderRadius: BorderRadius.circular(AppRadii.control),
          border: Border.all(color: AppColors.separator(context)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          scrollDirection: Axis.horizontal,
          itemCount: crumbs.length,
          separatorBuilder: (context, index) => Center(
            child: Text('/', style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context).withAlpha(120))),
          ),
          itemBuilder: (context, index) {
            final crumb = crumbs[index];
            final current = index == crumbs.length - 1;
            return AppClickableArea(
              onTap: current ? null : () => onSelected(crumb.path),
              borderRadius: BorderRadius.circular(AppRadii.small),
              padding: const EdgeInsets.symmetric(horizontal: 7),
              hoverColor: Colors.transparent,
              child: Center(
                child: Text(
                  crumb.label,
                  style: TextStyle(
                    color: current ? AppColors.textPrimary(context) : AppColors.textSecondary(context),
                    fontSize: 13,
                    fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FileSortButton extends StatelessWidget {
  final FileSortField field;
  final bool ascending;
  final void Function(FileSortField field, bool ascending) onChanged;

  const _FileSortButton({required this.field, required this.ascending, required this.onChanged});

  String get _label => switch (field) {
    FileSortField.name => '名称',
    FileSortField.size => '大小',
    FileSortField.modifiedAt => '修改时间',
  };

  String get _directionLabel => ascending ? '升序' : '降序';

  @override
  Widget build(BuildContext context) {
    return _ToolbarGroup(
      children: [
        AppDropdown<FileSortField>(
          trigger: SizedBox(
            height: 34,
            child: Padding(
              padding: const EdgeInsets.only(left: 9, right: 7),
              child: Row(
                children: [
                  Icon(
                    ascending ? AppIcons.ascending : AppIcons.descending,
                    size: 15,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    _label,
                    style: TextStyle(color: AppColors.textPrimary(context), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 5),
                  const Icon(AppIcons.chevronDown, size: 13),
                ],
              ),
            ),
          ),
          tooltip: '排序：$_label，$_directionLabel',
          selectedValue: field,
          onSelected: (value) => onChanged(value, value == field ? !ascending : true),
          options: const [
            AppDropdownOption(value: FileSortField.name, label: '名称'),
            AppDropdownOption(value: FileSortField.size, label: '大小'),
            AppDropdownOption(value: FileSortField.modifiedAt, label: '修改时间'),
          ],
          menuWidth: 126,
        ),
      ],
    );
  }
}

class _ToolbarGroup extends StatelessWidget {
  const _ToolbarGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _toolbarHeight,
      decoration: BoxDecoration(
        color: AppColors.selectControlSurface(context),
        borderRadius: BorderRadius.circular(AppRadii.surface),
        border: Border.all(color: AppColors.selectBorder(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index != 0)
              SizedBox(
                width: 1,
                height: _toolbarHeight,
                child: ColoredBox(color: AppColors.separator(context)),
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AppClickableArea(
        onTap: onPressed,
        width: _toolbarButtonWidth,
        height: _toolbarHeight,
        borderRadius: BorderRadius.zero,
        backgroundColor: Colors.transparent,
        hoverColor: AppColors.hoverSurface(context),
        child: Icon(
          icon,
          size: 18,
          color: onPressed == null ? AppColors.textSecondary(context).withAlpha(90) : AppColors.textPrimary(context),
        ),
      ),
    );
  }
}

const double _toolbarHeight = 34;
const double _toolbarButtonWidth = 36;
const double _viewModeControlWidth = 74;
