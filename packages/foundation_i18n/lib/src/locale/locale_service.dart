import 'dart:ui';

class LocaleService {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale? locale) {
    _locale = locale;
  }

  void clear() {
    _locale = null;
  }
}