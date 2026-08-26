import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

/// Groups related form items on one visually connected surface.
class AppFormGroup extends StatelessWidget {
  const AppFormGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final separator = AppColors.separator(context).withAlpha(105);
    final background = Color.alphaBlend(AppColors.subtleSurface(context), Theme.of(context).scaffoldBackgroundColor);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: separator),
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
