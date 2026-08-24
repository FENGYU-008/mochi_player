import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

class AppFormGroup extends StatelessWidget {
  final List<Widget> children;

  const AppFormGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final separator = AppColors.separator(context).withAlpha(105);
    final background = Color.alphaBlend(
      AppColors.subtleSurface(context),
      Theme.of(context).scaffoldBackgroundColor,
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.separator(context).withAlpha(105)),
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
