class Validators {
  static String? required(String? v, {String message = 'Required'}) {
    if (v == null || v.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? v, {String message = 'Invalid email'}) {
    if (v == null || v.trim().isEmpty) return null;
    final r = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return r.hasMatch(v.trim()) ? null : message;
  }

  static String? minLength(String? v, int min, {String? message}) {
    if (v == null) return null;
    if (v.length < min) return message ?? 'Must be at least $min characters';
    return null;
  }

  static String? phone(String? v, {String message = 'Invalid phone'}) {
    if (v == null || v.trim().isEmpty) return null;
    final r = RegExp(r'^\+?[0-9]{7,15}$');
    return r.hasMatch(v.trim()) ? null : message;
  }

  static String? combine(String? v, List<String? Function(String?)> validators) {
    for (final fn in validators) {
      final err = fn(v);
      if (err != null) return err;
    }
    return null;
  }
}