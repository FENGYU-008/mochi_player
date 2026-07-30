import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/buttons/app_icon_button.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

Future<T?> showAppModal<T>({
  required BuildContext context,
  required Widget child,
  String barrierLabel = '关闭',
  double maxWidth = 1000,
  double maxHeightFactor = 0.85,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: barrierLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInCubic,
      );

      return Stack(
        children: [
          FadeTransition(
            opacity: curvedAnimation,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(color: Colors.black.withAlpha(51)),
              ),
            ),
          ),
          ScaleTransition(
            scale: Tween<double>(
              begin: 0.92,
              end: 1.0,
            ).animate(curvedAnimation),
            child: FadeTransition(opacity: curvedAnimation, child: child),
          ),
        ],
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {},
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
              ),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

class AppModalScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const AppModalScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(AppRadii.large);

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF2C2C2E),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 50,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppIconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icons.close_rounded,
                      tooltip: '关闭',
                      size: 32,
                      iconSize: 18,
                      foregroundColor: AppColors.textPrimary(context),
                      backgroundColor: AppColors.hoverSurface(context),
                      borderColor: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 1, color: theme.dividerColor),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
