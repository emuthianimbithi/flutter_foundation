import 'package:flutter/widgets.dart';

/// Route names used across the app.
///
/// Keep these stable; they are used for redirects and deep links.
abstract final class AppRouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const orgSelect = 'org_select';
  static const mfa = 'mfa';
  static const home = 'home';
  static const forbidden = 'forbidden';
}

/// Route paths used across the app.
abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const orgSelect = '/org';
  static const mfa = '/mfa';
  static const home = '/home';
  static const forbidden = '/forbidden';
}
