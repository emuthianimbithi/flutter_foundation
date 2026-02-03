import 'package:equatable/equatable.dart';

import '../types/failure.dart';
import '../types/result.dart';

/// Base class for value objects.
///
/// Value objects are immutable objects that are defined by their attributes
/// rather than their identity. Two value objects are equal if all their
/// attributes are equal.
///
/// Value objects should validate their state on construction and throw
/// or return a failure for invalid states.
///
/// Example:
/// ```dart
/// class Email extends ValueObject<String> {
///   const Email._(super.value);
///
///   static Result<Email> create(String input) {
///     final normalized = input.trim().toLowerCase();
///     if (!_emailRegex.hasMatch(normalized)) {
///       return Result.failure(Failure.validation('Invalid email format'));
///     }
///     return Result.success(Email._(normalized));
///   }
///
///   static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
/// }
/// ```
abstract class ValueObject<T> extends Equatable {
  /// The underlying value.
  final T value;

  const ValueObject(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toString();
}

/// A value object that wraps a String with validation.
abstract class StringValueObject extends ValueObject<String> {
  const StringValueObject(super.value);

  /// Whether the string is empty.
  bool get isEmpty => value.isEmpty;

  /// Whether the string is not empty.
  bool get isNotEmpty => value.isNotEmpty;

  /// The length of the string.
  int get length => value.length;
}

/// A validated email address.
class Email extends StringValueObject {
  const Email._(super.value);

  /// Creates an Email from a string, returning a failure if invalid.
  static Result<Email> create(String input) {
    final normalized = input.trim().toLowerCase();
    if (normalized.isEmpty) {
      return Result.failure(Failure.validation('Email cannot be empty'));
    }
    if (!_emailRegex.hasMatch(normalized)) {
      return Result.failure(Failure.validation('Invalid email format'));
    }
    return Result.success(Email._(normalized));
  }

  /// Creates an Email without validation. Use only when you know the value is valid.
  factory Email.fromTrusted(String value) => Email._(value.toLowerCase());

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
  );
}

/// A validated phone number.
class PhoneNumber extends StringValueObject {
  const PhoneNumber._(super.value);

  /// Creates a PhoneNumber from a string, returning a failure if invalid.
  static Result<PhoneNumber> create(String input) {
    // Remove all non-numeric characters except +
    final normalized = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (normalized.isEmpty) {
      return Result.failure(Failure.validation('Phone number cannot be empty'));
    }
    if (normalized.length < 7 || normalized.length > 15) {
      return Result.failure(Failure.validation('Invalid phone number length'));
    }
    return Result.success(PhoneNumber._(normalized));
  }

  /// Creates a PhoneNumber without validation.
  factory PhoneNumber.fromTrusted(String value) => PhoneNumber._(value);
}

/// A validated URL.
class Url extends StringValueObject {
  const Url._(super.value);

  /// Creates a Url from a string, returning a failure if invalid.
  static Result<Url> create(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return Result.failure(Failure.validation('URL cannot be empty'));
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return Result.failure(Failure.validation('Invalid URL format'));
    }
    return Result.success(Url._(trimmed));
  }

  /// Creates a Url without validation.
  factory Url.fromTrusted(String value) => Url._(value);

  /// Parses this URL into a Uri.
  Uri toUri() => Uri.parse(value);
}

/// A non-empty string value object.
class NonEmptyString extends StringValueObject {
  const NonEmptyString._(super.value);

  /// Creates a NonEmptyString, returning a failure if empty.
  static Result<NonEmptyString> create(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return Result.failure(Failure.validation('Value cannot be empty'));
    }
    return Result.success(NonEmptyString._(trimmed));
  }

  /// Creates a NonEmptyString without validation.
  factory NonEmptyString.fromTrusted(String value) => NonEmptyString._(value);
}

/// A positive integer value object.
class PositiveInt extends ValueObject<int> {
  const PositiveInt._(super.value);

  /// Creates a PositiveInt, returning a failure if not positive.
  static Result<PositiveInt> create(int input) {
    if (input <= 0) {
      return Result.failure(Failure.validation('Value must be positive'));
    }
    return Result.success(PositiveInt._(input));
  }

  /// Creates a PositiveInt without validation.
  factory PositiveInt.fromTrusted(int value) => PositiveInt._(value);
}

/// A percentage value (0-100).
class Percentage extends ValueObject<double> {
  const Percentage._(super.value);

  /// Creates a Percentage, returning a failure if not in range.
  static Result<Percentage> create(double input) {
    if (input < 0 || input > 100) {
      return Result.failure(
        Failure.validation('Percentage must be between 0 and 100'),
      );
    }
    return Result.success(Percentage._(input));
  }

  /// Creates a Percentage without validation.
  factory Percentage.fromTrusted(double value) => Percentage._(value);

  /// Returns the decimal representation (0-1).
  double get decimal => value / 100;
}
