import 'package:flutter/material.dart';

class AppColors {
  static const accent = Color(0xFF007AFF);
  static const accentDark = Color(0xFF0A84FF);
  static const favorite = Color(0xFFFF3B30);
  static const rating = Color(0xFFFFCC00);

  static Color primary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? accentDark
        : accent;
  }

  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFF5F5F7)
        : const Color(0xFF1D1D1F);
  }

  static Color textSecondary(BuildContext context) {
    return textPrimary(context).withAlpha(166);
  }

  static Color separator(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE5E5EA);
  }

  static Color sidebarBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF202023)
        : const Color(0xFFF5F5F7);
  }

  static Color elevatedSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFF2F2F7);
  }

  static Color hoverSurface(BuildContext context) {
    return textPrimary(
      context,
    ).withAlpha(Theme.of(context).brightness == Brightness.dark ? 22 : 13);
  }
}
