import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../theme/color_scheme.dart';
import '../theme/typography.dart';

final appThemeProvider = Provider<FoundationAppTheme>((ref) {
  return FoundationAppTheme(
    colors: FoundationColorScheme(
      primary: const Color(0xFF0066FF),
      secondary: const Color(0xFF00BFA5),
      background: const Color(0xFFF5F5F5),
      surface: const Color(0xFFFFFFFF),
      error: const Color(0xFFB00020),
    ),
    typography: FoundationTypography.defaultTypography(),
  );
});
