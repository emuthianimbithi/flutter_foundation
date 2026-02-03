import 'package:flutter/widgets.dart';

/// Lightweight localization delegate scaffold.
/// Apps can extend this to plug in generated ARB-based localizations.
class FoundationLocalizationDelegate extends LocalizationsDelegate<void> {
  const FoundationLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<void> load(Locale locale) async {}

  @override
  bool shouldReload(covariant LocalizationsDelegate<void> old) => false;
}
