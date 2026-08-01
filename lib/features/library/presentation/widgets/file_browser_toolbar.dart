import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/library/application/file_browser_provider.dart';

class FileBrowserToolbar extends StatelessWidget {
  final String currentPath;
  final bool canGoBack;
  final bool canGoForward;
  final ViewMode viewMode;
  final FileSortField sortField;
  final bool sortAscending;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final ValueChanged<String> onPathSelected;
  final void Function(FileSortField field, bool ascending) onSortChanged;
  final ValueChanged<ViewMode> onViewModeChanged;
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
        AppToolbarGroup(
          children: [
            AppToolbarButton(
              icon: AppIcons.back,
              tooltip: '后退',
              onPressed: canGoBack ? onBack : null,
              showBorder: false,
            ),
            const AppToolbarDivider(),
            AppToolbarButton(
              icon: AppIcons.forward,
              tooltip: '前进',
              onPressed: canGoForward ? onForward : null,
              showBorder: false,
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.compact),
        Expanded(
          child: _FilePathBreadcrumb(
            path: currentPath,
            onSelected: onPathSelected,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _FileSortButton(
          field: sortField,
          ascending: sortAscending,
          onChanged: onSortChanged,
        ),
        const SizedBox(width: AppSpacing.compact),
        AppToolbarGroup(
          children: [
            AppToolbarButton(
              icon: AppIcons.list,
              tooltip: '列表视图',
              selected: viewMode == ViewMode.list,
              onPressed: () => onViewModeChanged(ViewMode.list),
              showBorder: false,
            ),
            const AppToolbarDivider(),
            AppToolbarButton(
              icon: AppIcons.grid,
              tooltip: '网格视图',
              selected: viewMode == ViewMode.grid,
              onPressed: () => onViewModeChanged(ViewMode.grid),
              showBorder: false,
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.compact),
        AppToolbarButton(
          icon: AppIcons.refresh,
          tooltip: '刷新目录',
          onPressed: onRefresh,
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
            child: Text(
              '/',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context).withAlpha(120),
              ),
            ),
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
                    color: current
                        ? AppColors.textPrimary(context)
                        : AppColors.textSecondary(context),
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

  const _FileSortButton({
    required this.field,
    required this.ascending,
    required this.onChanged,
  });

  String get _label => switch (field) {
    FileSortField.name => '名称',
    FileSortField.size => '大小',
    FileSortField.modifiedAt => '修改时间',
  };

  String get _directionLabel => ascending ? '升序' : '降序';

  @override
  Widget build(BuildContext context) {
    return AppToolbarGroup(
      children: [
        AppMenuButton<FileSortField>(
          tooltip: '排序：$_label，$_directionLabel',
          selectedValue: field,
          onSelected: (value) =>
              onChanged(value, value == field ? !ascending : true),
          options: const [
            AppMenuOption(value: FileSortField.name, label: '名称'),
            AppMenuOption(value: FileSortField.size, label: '大小'),
            AppMenuOption(value: FileSortField.modifiedAt, label: '修改时间'),
          ],
          menuWidth: 126,
          child: SizedBox(
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
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(AppIcons.chevronDown, size: 13),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
