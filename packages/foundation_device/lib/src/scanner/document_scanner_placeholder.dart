class DocumentScannerPlaceholder {
  /// Implement with a document scanner plugin (platform-specific) if needed.
  Future<List<String>> scanDocuments() async {
    throw UnimplementedError('Provide a concrete document scanner implementation.');
  }
}