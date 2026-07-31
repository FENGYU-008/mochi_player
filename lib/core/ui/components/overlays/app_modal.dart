import 'dart:ui';

import 'package:flutter/material.dart';

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
