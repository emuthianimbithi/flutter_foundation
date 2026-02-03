import 'package:flutter/material.dart';

/// Extension methods for [BuildContext].
extension ContextExtensions on BuildContext {
  // ─────────────────────────────────────────────────────────────
  // THEME
  // ─────────────────────────────────────────────────────────────

  /// The current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The current [ColorScheme].
  ColorScheme get colorScheme => theme.colorScheme;

  /// The current [TextTheme].
  TextTheme get textTheme => theme.textTheme;

  /// Whether the current theme is dark.
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Whether the current theme is light.
  bool get isLightMode => theme.brightness == Brightness.light;

  // ─────────────────────────────────────────────────────────────
  // MEDIA QUERY
  // ─────────────────────────────────────────────────────────────

  /// The current [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// The screen size.
  Size get screenSize => mediaQuery.size;

  /// The screen width.
  double get screenWidth => screenSize.width;

  /// The screen height.
  double get screenHeight => screenSize.height;

  /// The device pixel ratio.
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// The top padding (e.g., status bar).
  double get topPadding => mediaQuery.padding.top;

  /// The bottom padding (e.g., home indicator).
  double get bottomPadding => mediaQuery.padding.bottom;

  /// The view insets (e.g., keyboard).
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// The keyboard height.
  double get keyboardHeight => viewInsets.bottom;

  /// Whether the keyboard is visible.
  bool get isKeyboardVisible => keyboardHeight > 0;

  /// The orientation.
  Orientation get orientation => mediaQuery.orientation;

  /// Whether the device is in portrait orientation.
  bool get isPortrait => orientation == Orientation.portrait;

  /// Whether the device is in landscape orientation.
  bool get isLandscape => orientation == Orientation.landscape;

  /// The text scale factor.
  double get textScaleFactor => mediaQuery.textScaleFactor;

  /// Whether the device has a notch.
  bool get hasNotch => topPadding > 20;

  // ─────────────────────────────────────────────────────────────
  // RESPONSIVE BREAKPOINTS
  // ─────────────────────────────────────────────────────────────

  /// Whether the screen is extra small (< 600).
  bool get isXs => screenWidth < 600;

  /// Whether the screen is small (>= 600 and < 960).
  bool get isSm => screenWidth >= 600 && screenWidth < 960;

  /// Whether the screen is medium (>= 960 and < 1280).
  bool get isMd => screenWidth >= 960 && screenWidth < 1280;

  /// Whether the screen is large (>= 1280 and < 1920).
  bool get isLg => screenWidth >= 1280 && screenWidth < 1920;

  /// Whether the screen is extra large (>= 1920).
  bool get isXl => screenWidth >= 1920;

  /// Whether the screen is mobile-sized (< 600).
  bool get isMobile => screenWidth < 600;

  /// Whether the screen is tablet-sized (>= 600 and < 1024).
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;

  /// Whether the screen is desktop-sized (>= 1024).
  bool get isDesktop => screenWidth >= 1024;

  /// Returns a value based on the screen size.
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // ─────────────────────────────────────────────────────────────
  // NAVIGATION
  // ─────────────────────────────────────────────────────────────

  /// The current [NavigatorState].
  NavigatorState get navigator => Navigator.of(this);

  /// Whether the navigator can pop.
  bool get canPop => navigator.canPop();

  /// Pops the current route.
  void pop<T>([T? result]) => navigator.pop(result);

  /// Pops until the predicate is satisfied.
  void popUntil(bool Function(Route<dynamic>) predicate) =>
      navigator.popUntil(predicate);

  /// Pops to the first route.
  void popToFirst() => navigator.popUntil((route) => route.isFirst);

  /// Pushes a new route.
  Future<T?> push<T>(Route<T> route) => navigator.push(route);

  /// Pushes a named route.
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      navigator.pushNamed<T>(routeName, arguments: arguments);

  /// Pushes a replacement route.
  Future<T?> pushReplacement<T, TO>(Route<T> route, {TO? result}) =>
      navigator.pushReplacement(route, result: result);

  /// Pushes a replacement named route.
  Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) =>
      navigator.pushReplacementNamed<T, TO>(
        routeName,
        arguments: arguments,
        result: result,
      );

  /// Pushes a route and removes until predicate.
  Future<T?> pushAndRemoveUntil<T>(
    Route<T> route,
    bool Function(Route<dynamic>) predicate,
  ) =>
      navigator.pushAndRemoveUntil(route, predicate);

  /// Pushes a named route and removes until predicate.
  Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) =>
      navigator.pushNamedAndRemoveUntil<T>(
        routeName,
        predicate,
        arguments: arguments,
      );

  // ─────────────────────────────────────────────────────────────
  // FOCUS
  // ─────────────────────────────────────────────────────────────

  /// The current [FocusScopeNode].
  FocusScopeNode get focusScope => FocusScope.of(this);

  /// Unfocuses the current focus.
  void unfocus() => focusScope.unfocus();

  /// Requests focus on a [FocusNode].
  void requestFocus(FocusNode node) => focusScope.requestFocus(node);

  /// Whether there is a focused node.
  bool get hasFocus => focusScope.hasFocus;

  // ─────────────────────────────────────────────────────────────
  // SCAFFOLD
  // ─────────────────────────────────────────────────────────────

  /// The current [ScaffoldState], if any.
  ScaffoldState? get scaffoldOrNull => Scaffold.maybeOf(this);

  /// The current [ScaffoldState].
  ScaffoldState get scaffold => Scaffold.of(this);

  /// The current [ScaffoldMessengerState].
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);

  /// Shows a snackbar.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    SnackBar snackBar,
  ) =>
      scaffoldMessenger.showSnackBar(snackBar);

  /// Shows a simple text snackbar.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showTextSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) =>
      showSnackBar(
        SnackBar(content: Text(message), duration: duration, action: action),
      );

  /// Hides the current snackbar.
  void hideCurrentSnackBar() => scaffoldMessenger.hideCurrentSnackBar();

  /// Opens the drawer.
  void openDrawer() => scaffold.openDrawer();

  /// Opens the end drawer.
  void openEndDrawer() => scaffold.openEndDrawer();

  /// Closes the drawer.
  void closeDrawer() => scaffold.closeDrawer();

  /// Closes the end drawer.
  void closeEndDrawer() => scaffold.closeEndDrawer();

  // ─────────────────────────────────────────────────────────────
  // FORMS
  // ─────────────────────────────────────────────────────────────

  /// The current [FormState], if any.
  FormState? get formOrNull => Form.maybeOf(this);

  /// The current [FormState].
  FormState get form => Form.of(this);

  /// Validates the current form.
  bool validateForm() => form.validate();

  /// Saves the current form.
  void saveForm() => form.save();

  /// Resets the current form.
  void resetForm() => form.reset();
}
