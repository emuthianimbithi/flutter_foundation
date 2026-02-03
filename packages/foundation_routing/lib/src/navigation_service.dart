import 'package:go_router/go_router.dart';

/// Small wrapper to make navigation test-friendly and injectable.
class NavigationService {
  final GoRouter _router;

  NavigationService(this._router);

  String get location => _router.routerDelegate.currentConfiguration.uri.toString();

  void go(String location) => _router.go(location);

  void push(String location) => _router.push(location);

  void pop<T extends Object?>([T? result]) => _router.pop(result);

  bool canPop() => _router.canPop();
}
