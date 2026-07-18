import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/widgets/app_surface.dart';

const _controlHeight = 36.0;
const _fieldGap = 6.0;

class AppSegment<T> {
  final T value;
  final String label;
  final IconData icon;

  const AppSegment({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class AppSegmentedControl<T> extends StatelessWidget {
  final T value;
  final List<AppSegment<T>> segments;
  final ValueChanged<T> onChanged;
  final double maxWidth;

  const AppSegmentedControl({
    super.key,
    required this.value,
    required this.segments,
    required this.onChanged,
    this.maxWidth = 420,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.separator(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final controlWidth = constraints.maxWidth < maxWidth
            ? constraints.maxWidth
            : maxWidth;
        return SizedBox(
          width: controlWidth,
          height: _controlHeight,
          child: AppSurface(
            tone: AppSurfaceTone.elevated,
            showBorder: true,
            borderRadius: BorderRadius.circular(AppRadii.control),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                for (var index = 0; index < segments.length; index++) ...[
                  Expanded(
                    child: _SegmentButton<T>(
                      segment: segments[index],
                      selected: segments[index].value == value,
                      onPressed: () => onChanged(segments[index].value),
                    ),
                  ),
                  if (index != segments.length - 1)
                    SizedBox(
                      height: 20,
                      child: VerticalDivider(width: 1, color: borderColor),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SegmentButton<T> extends StatefulWidget {
  final AppSegment<T> segment;
  final bool selected;
  final VoidCallback onPressed;

  const _SegmentButton({
    required this.segment,
    required this.selected,
    required this.onPressed,
  });

  @override
  State<_SegmentButton<T>> createState() => _SegmentButtonState<T>();
}

class _SegmentButtonState<T> extends State<_SegmentButton<T>> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final selected = widget.selected;
    final foreground = selected
        ? Colors.white
        : AppColors.textPrimary(context).withAlpha(220);
    final background = selected
        ? primary
        : _hovering
        ? AppColors.hoverSurface(context)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          height: double.infinity,
          color: background,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.segment.icon, size: 16, color: foreground),
              const SizedBox(width: _fieldGap),
              Text(
                widget.segment.label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
