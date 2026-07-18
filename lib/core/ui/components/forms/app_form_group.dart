import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

class AppFormGroup extends StatelessWidget {
  final List<Widget> children;

  const AppFormGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final separator = AppColors.separator(context).withAlpha(145);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface(context),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.separator(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index != 0)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.compact),
                child: Divider(height: 1, thickness: 1, color: separator),
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}
