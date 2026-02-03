import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:foundation_core/foundation_core.dart';

/// Monitors network connectivity status.
class ConnectivityMonitor {
  final Connectivity _connectivity;
  final AppLogger _log = AppLogger('ConnectivityMonitor');

  final _connectivityController = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;
  bool _isWifi = false;
  bool _isMobile = false;

  ConnectivityMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Whether there is network connectivity.
  bool get isConnected => _isConnected;

  /// Whether connected via WiFi.
  bool get isWifi => _isWifi;

  /// Whether connected via mobile data.
  bool get isMobile => _isMobile;

  /// Stream of connectivity changes.
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  /// Initializes the monitor and starts listening.
  Future<void> init() async {
    // Check initial state
    await _checkConnectivity();

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    _log.debug('ConnectivityMonitor initialized: connected=$_isConnected, wifi=$_isWifi');
  }

  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateState(results);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _updateState(results);
  }

  void _updateState(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;

    _isWifi = results.contains(ConnectivityResult.wifi);
    _isMobile = results.contains(ConnectivityResult.mobile);
    _isConnected = results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);

    if (_isConnected != wasConnected) {
      _log.info('Connectivity changed: connected=$_isConnected, wifi=$_isWifi, mobile=$_isMobile');
      _connectivityController.add(_isConnected);
    }
  }

  /// Forces a connectivity check.
  Future<bool> checkConnectivity() async {
    await _checkConnectivity();
    return _isConnected;
  }

  /// Disposes the monitor.
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
