/// Common validation functions.
///
/// All validators return null if valid, or an error message if invalid.
///
/// Example:
/// ```dart
/// TextFormField(
///   validator: Validators.compose([
///     Validators.required('Email is required'),
///     Validators.email('Enter a valid email'),
///   ]),
/// )
/// ```
class Validators {
  Validators._();

  // ─────────────────────────────────────────────────────────────
  // BASIC VALIDATORS
  // ─────────────────────────────────────────────────────────────

  /// Validates that the value is not null or empty.
  static String? Function(String?) required([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message ?? 'This field is required';
      }
      return null;
    };
  }

  /// Validates minimum length.
  static String? Function(String?) minLength(int length, [String? message]) {
    return (value) {
      if (value == null || value.length < length) {
        return message ?? 'Must be at least $length characters';
      }
      return null;
    };
  }

  /// Validates maximum length.
  static String? Function(String?) maxLength(int length, [String? message]) {
    return (value) {
      if (value != null && value.length > length) {
        return message ?? 'Must be at most $length characters';
      }
      return null;
    };
  }

  /// Validates exact length.
  static String? Function(String?) exactLength(int length, [String? message]) {
    return (value) {
      if (value == null || value.length != length) {
        return message ?? 'Must be exactly $length characters';
      }
      return null;
    };
  }

  /// Validates length range.
  static String? Function(String?) lengthRange(
    int min,
    int max, [
    String? message,
  ]) {
    return (value) {
      if (value == null || value.length < min || value.length > max) {
        return message ?? 'Must be between $min and $max characters';
      }
      return null;
    };
  }

  // ─────────────────────────────────────────────────────────────
  // FORMAT VALIDATORS
  // ─────────────────────────────────────────────────────────────

  /// Validates email format.
  static String? Function(String?) email([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
      );
      if (!emailRegex.hasMatch(value)) {
        return message ?? 'Enter a valid email address';
      }
      return null;
    };
  }

  /// Validates phone number format.
  static String? Function(String?) phone([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly.length < 7 || digitsOnly.length > 15) {
        return message ?? 'Enter a valid phone number';
      }
      return null;
    };
  }

  /// Validates URL format.
  static String? Function(String?) url([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final uri = Uri.tryParse(value);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        return message ?? 'Enter a valid URL';
      }
      return null;
    };
  }

  /// Validates against a regular expression.
  static String? Function(String?) pattern(
    RegExp regex, [
    String? message,
  ]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!regex.hasMatch(value)) {
        return message ?? 'Invalid format';
      }
      return null;
    };
  }

  /// Validates numeric only.
  static String? Function(String?) numeric([String? message]) {
    return pattern(RegExp(r'^\d+$'), message ?? 'Must contain only numbers');
  }

  /// Validates alphabetic only.
  static String? Function(String?) alpha([String? message]) {
    return pattern(
      RegExp(r'^[a-zA-Z]+$'),
      message ?? 'Must contain only letters',
    );
  }

  /// Validates alphanumeric only.
  static String? Function(String?) alphanumeric([String? message]) {
    return pattern(
      RegExp(r'^[a-zA-Z0-9]+$'),
      message ?? 'Must contain only letters and numbers',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // NUMBER VALIDATORS
  // ─────────────────────────────────────────────────────────────

  /// Validates that the value is a number.
  static String? Function(String?) isNumber([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (double.tryParse(value) == null) {
        return message ?? 'Must be a valid number';
      }
      return null;
    };
  }

  /// Validates that the value is an integer.
  static String? Function(String?) isInteger([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (int.tryParse(value) == null) {
        return message ?? 'Must be a valid integer';
      }
      return null;
    };
  }

  /// Validates minimum numeric value.
  static String? Function(String?) min(num minValue, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final numValue = num.tryParse(value);
      if (numValue == null || numValue < minValue) {
        return message ?? 'Must be at least $minValue';
      }
      return null;
    };
  }

  /// Validates maximum numeric value.
  static String? Function(String?) max(num maxValue, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final numValue = num.tryParse(value);
      if (numValue == null || numValue > maxValue) {
        return message ?? 'Must be at most $maxValue';
      }
      return null;
    };
  }

  /// Validates numeric range.
  static String? Function(String?) range(
    num minValue,
    num maxValue, [
    String? message,
  ]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final numValue = num.tryParse(value);
      if (numValue == null || numValue < minValue || numValue > maxValue) {
        return message ?? 'Must be between $minValue and $maxValue';
      }
      return null;
    };
  }

  // ─────────────────────────────────────────────────────────────
  // PASSWORD VALIDATORS
  // ─────────────────────────────────────────────────────────────

  /// Validates password strength.
  static String? Function(String?) password({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigit = true,
    bool requireSpecial = false,
    String? message,
  }) {
    return (value) {
      if (value == null || value.isEmpty) return null;

      final errors = <String>[];

      if (value.length < minLength) {
        errors.add('at least $minLength characters');
      }
      if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
        errors.add('an uppercase letter');
      }
      if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
        errors.add('a lowercase letter');
      }
      if (requireDigit && !value.contains(RegExp(r'[0-9]'))) {
        errors.add('a number');
      }
      if (requireSpecial && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        errors.add('a special character');
      }

      if (errors.isNotEmpty) {
        return message ?? 'Password must contain ${errors.join(', ')}';
      }
      return null;
    };
  }

  /// Validates that passwords match.
  static String? Function(String?) confirmPassword(
    String? password, [
    String? message,
  ]) {
    return (value) {
      if (value != password) {
        return message ?? 'Passwords do not match';
      }
      return null;
    };
  }

  // ─────────────────────────────────────────────────────────────
  // COMPARISON VALIDATORS
  // ─────────────────────────────────────────────────────────────

  /// Validates that the value equals another value.
  static String? Function(String?) equals(String? other, [String? message]) {
    return (value) {
      if (value != other) {
        return message ?? 'Values do not match';
      }
      return null;
    };
  }

  /// Validates that the value is not equal to another value.
  static String? Function(String?) notEquals(String? other, [String? message]) {
    return (value) {
      if (value == other) {
        return message ?? 'Value cannot be $other';
      }
      return null;
    };
  }

  /// Validates that the value is in a list of allowed values.
  static String? Function(String?) oneOf(
    List<String> values, [
    String? message,
  ]) {
    return (value) {
      if (value != null && !values.contains(value)) {
        return message ?? 'Must be one of: ${values.join(', ')}';
      }
      return null;
    };
  }

  // ─────────────────────────────────────────────────────────────
  // COMPOSITION
  // ─────────────────────────────────────────────────────────────

  /// Composes multiple validators into one.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Makes a validator optional (only validates if value is not empty).
  static String? Function(String?) optional(
    String? Function(String?) validator,
  ) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      return validator(value);
    };
  }
}
