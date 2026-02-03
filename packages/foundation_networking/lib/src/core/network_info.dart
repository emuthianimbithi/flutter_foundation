import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:foundation_core/foundation_core.dart';

/// Provides information about network connectivity.
class NetworkInfo {
  final Connectivity _connectivity;
  final AppLogger _log = AppLogger('NetworkInfo');

  final _connectivityController = StreamController<NetworkStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkStatus _status = const NetworkStatus();

  NetworkInfo({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// The current network status.
  NetworkStatus get status => _status;

  /// Whether there is any network connection.
  bool get isConnected => _status.isConnected;

  /// Whether connected via WiFi.
  bool get isWifi => _status.isWifi;

  /// Whether connected via mobile data.
  bool get isMobile => _status.isMobile;

  /// Whether connected via ethernet.
  bool get isEthernet => _status.isEthernet;

  /// Stream of network status changes.
  Stream<NetworkStatus> get onStatusChanged => _connectivityController.stream;

  /// Initializes the network info and starts listening.
  Future<void> init() async {
    await _checkConnectivity();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    _log.debug('NetworkInfo initialized: $_status');
  }

  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _updateStatus(results);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final newStatus = NetworkStatus(
      isWifi: results.contains(ConnectivityResult.wifi),
      isMobile: results.contains(ConnectivityResult.mobile),
      isEthernet: results.contains(ConnectivityResult.ethernet),
      isVpn: results.contains(ConnectivityResult.vpn),
      isBluetooth: results.contains(ConnectivityResult.bluetooth),
    );

    if (newStatus != _status) {
      _log.info('Network status changed: $_status -> $newStatus');
      _status = newStatus;
      _connectivityController.add(newStatus);
    }
  }

  /// Forces a connectivity check.
  Future<NetworkStatus> checkConnectivity() async {
    await _checkConnectivity();
    return _status;
  }

  /// Disposes resources.
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}

/// Network connectivity status.
class NetworkStatus {
  final bool isWifi;
  final bool isMobile;
  final bool isEthernet;
  final bool isVpn;
  final bool isBluetooth;

  const NetworkStatus({
    this.isWifi = false,
    this.isMobile = false,
    this.isEthernet = false,
    this.isVpn = false,
    this.isBluetooth = false,
  });

  /// Whether there is any connection.
  bool get isConnected => isWifi || isMobile || isEthernet;

  /// Whether connection is fast (WiFi or Ethernet).
  bool get isFast => isWifi || isEthernet;

  /// Whether connection is metered (mobile).
  bool get isMetered => isMobile && !isWifi && !isEthernet;

  /// The connection type as a string.
  String get connectionType {
    if (isWifi) return 'wifi';
    if (isEthernet) return 'ethernet';
    if (isMobile) return 'mobile';
    if (isBluetooth) return 'bluetooth';
    return 'none';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkStatus &&
          isWifi == other.isWifi &&
          isMobile == other.isMobile &&
          isEthernet == other.isEthernet &&
          isVpn == other.isVpn &&
          isBluetooth == other.isBluetooth;

  @override
  int get hashCode =>
      Object.hash(isWifi, isMobile, isEthernet, isVpn, isBluetooth);

  @override
  String toString() =>
      'NetworkStatus(connected: $isConnected, type: $connectionType, vpn: $isVpn)';
}
