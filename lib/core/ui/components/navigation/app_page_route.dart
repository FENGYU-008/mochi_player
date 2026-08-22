import 'package:flutter/material.dart';

/// Standard transition for pages opened inside the application shell.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required WidgetBuilder builder, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
            reverseCurve: Curves.easeInCubic,
          );
          final position = Tween<Offset>(
            begin: const Offset(0.025, 0),
            end: Offset.zero,
          ).animate(curvedAnimation);

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(position: position, child: child),
          );
        },
      );
}
