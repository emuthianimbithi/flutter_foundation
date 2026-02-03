class QrScannerPlaceholder {
  /// Implement with `mobile_scanner` or `qr_code_scanner` in your app.
  Future<String?> scan() async {
    throw UnimplementedError('Provide a concrete QR scanner implementation.');
  }
}
