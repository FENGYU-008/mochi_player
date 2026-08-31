import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

/// Groups related form items on one visually connected surface.
class AppFormGroup extends StatelessWidget {
  const AppFormGroup({super.key, required this.children, this.title, this.trailing});

  /// Optional heading for this settings card.
  final String? title;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final separator = AppColors.separator(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: separator),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title case final title?) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                  trailing ?? const SizedBox.shrink(),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: separator),
          ],
          for (var index = 0; index < children.length; index++) ...[
            if (index != 0)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.lg),
                child: Divider(height: 1, thickness: 1, color: separator),
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}
