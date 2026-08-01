import 'package:flutter/material.dart';

@immutable
class AppColorSchemeExtension extends ThemeExtension<AppColorSchemeExtension> {
  final Color textPrimary;
  final Color textSecondary;
  final Color separator;
  final Color sidebarBackground;
  final Color elevatedSurface;
  final Color subtleSurface;
  final Color hoverSurface;
  final Color selectedSurface;
  final Color inputBackground;
  final Color headerBackground;
  final Color activitySurface;
  final Color modalSurface;
  final Color selectMenuSurface;
  final Color selectControlSurface;
  final Color selectBorder;
  final Color mediaHoverOverlay;

  const AppColorSchemeExtension({
    required this.textPrimary,
    required this.textSecondary,
    required this.separator,
    required this.sidebarBackground,
    required this.elevatedSurface,
    required this.subtleSurface,
    required this.hoverSurface,
    required this.selectedSurface,
    required this.inputBackground,
    required this.headerBackground,
    required this.activitySurface,
    required this.modalSurface,
    required this.selectMenuSurface,
    required this.selectControlSurface,
    required this.selectBorder,
    required this.mediaHoverOverlay,
  });

  @override
  AppColorSchemeExtension copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? separator,
    Color? sidebarBackground,
    Color? elevatedSurface,
    Color? subtleSurface,
    Color? hoverSurface,
    Color? selectedSurface,
    Color? inputBackground,
    Color? headerBackground,
    Color? activitySurface,
    Color? modalSurface,
    Color? selectMenuSurface,
    Color? selectControlSurface,
    Color? selectBorder,
    Color? mediaHoverOverlay,
  }) {
    return AppColorSchemeExtension(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      separator: separator ?? this.separator,
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      subtleSurface: subtleSurface ?? this.subtleSurface,
      hoverSurface: hoverSurface ?? this.hoverSurface,
      selectedSurface: selectedSurface ?? this.selectedSurface,
      inputBackground: inputBackground ?? this.inputBackground,
      headerBackground: headerBackground ?? this.headerBackground,
      activitySurface: activitySurface ?? this.activitySurface,
      modalSurface: modalSurface ?? this.modalSurface,
      selectMenuSurface: selectMenuSurface ?? this.selectMenuSurface,
      selectControlSurface: selectControlSurface ?? this.selectControlSurface,
      selectBorder: selectBorder ?? this.selectBorder,
      mediaHoverOverlay: mediaHoverOverlay ?? this.mediaHoverOverlay,
    );
  }

  @override
  AppColorSchemeExtension lerp(
    covariant AppColorSchemeExtension? other,
    double t,
  ) {
    if (other == null) return this;
    return AppColorSchemeExtension(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      sidebarBackground: Color.lerp(
        sidebarBackground,
        other.sidebarBackground,
        t,
      )!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      subtleSurface: Color.lerp(subtleSurface, other.subtleSurface, t)!,
      hoverSurface: Color.lerp(hoverSurface, other.hoverSurface, t)!,
      selectedSurface: Color.lerp(selectedSurface, other.selectedSurface, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      headerBackground: Color.lerp(
        headerBackground,
        other.headerBackground,
        t,
      )!,
      activitySurface: Color.lerp(activitySurface, other.activitySurface, t)!,
      modalSurface: Color.lerp(modalSurface, other.modalSurface, t)!,
      selectMenuSurface: Color.lerp(
        selectMenuSurface,
        other.selectMenuSurface,
        t,
      )!,
      selectControlSurface: Color.lerp(
        selectControlSurface,
        other.selectControlSurface,
        t,
      )!,
      selectBorder: Color.lerp(selectBorder, other.selectBorder, t)!,
      mediaHoverOverlay: Color.lerp(
        mediaHoverOverlay,
        other.mediaHoverOverlay,
        t,
      )!,
    );
  }
}

class AppColors {
  static const primaryLight = Color(0xFF7065A8);
  static const primaryDark = Color(0xFF9186C2);
  static const favoriteLight = Color(0xFFB45F73);
  static const favoriteDark = Color(0xFFD18191);
  static const rating = Color(0xFFFFCC00);

  static AppColorSchemeExtension _scheme(BuildContext context) {
    return Theme.of(context).extension<AppColorSchemeExtension>()!;
  }

  static Color primary(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color favorite(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? favoriteDark
        : favoriteLight;
  }

  static Color textPrimary(BuildContext context) {
    return _scheme(context).textPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return _scheme(context).textSecondary;
  }

  static Color separator(BuildContext context) {
    return _scheme(context).separator;
  }

  static Color sidebarBackground(BuildContext context) {
    return _scheme(context).sidebarBackground;
  }

  static Color elevatedSurface(BuildContext context) {
    return _scheme(context).elevatedSurface;
  }

  static Color hoverSurface(BuildContext context) {
    return _scheme(context).hoverSurface;
  }

  static Color selectedSurface(BuildContext context) {
    return _scheme(context).selectedSurface;
  }

  static Color subtleSurface(BuildContext context) =>
      _scheme(context).subtleSurface;

  static Color inputBackground(BuildContext context) =>
      _scheme(context).inputBackground;

  static Color headerBackground(BuildContext context) =>
      _scheme(context).headerBackground;

  static Color activitySurface(BuildContext context) =>
      _scheme(context).activitySurface;

  static Color modalSurface(BuildContext context) =>
      _scheme(context).modalSurface;

  static Color selectMenuSurface(BuildContext context) =>
      _scheme(context).selectMenuSurface;

  static Color selectControlSurface(BuildContext context) =>
      _scheme(context).selectControlSurface;

  static Color selectBorder(BuildContext context) =>
      _scheme(context).selectBorder;

  static Color mediaHoverOverlay(BuildContext context) =>
      _scheme(context).mediaHoverOverlay;
}
