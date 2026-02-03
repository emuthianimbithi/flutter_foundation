import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart' as fp;

import 'failure.dart';

/// A Result type that represents either a success with a value of type [T],
/// or a failure with a [Failure].
///
/// This is a wrapper around fpdart's Either type, specialized for our use case.
///
/// Example:
/// ```dart
/// Result<User> fetchUser(String id) async {
///   try {
///     final user = await api.getUser(id);
///     return Result.success(user);
///   } catch (e) {
///     return Result.failure(Failure.server(e.toString()));
///   }
/// }
///
/// // Usage
/// final result = await fetchUser('123');
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (user) => print('User: ${user.name}'),
/// );
/// ```
class Result<T> extends Equatable {
  final fp.Either<Failure, T> _either;

  const Result._(this._either);

  /// Creates a successful result with the given [value].
  factory Result.success(T value) => Result._(fp.Either.right(value));

  /// Creates a failed result with the given [failure].
  factory Result.failure(Failure failure) => Result._(fp.Either.left(failure));

  /// Creates a result from a nullable value.
  /// Returns [failure] if [value] is null, otherwise returns success.
  factory Result.fromNullable(T? value, Failure failure) =>
      value != null ? Result.success(value) : Result.failure(failure);

  /// Creates a result by executing [fn] and catching any exceptions.
  static Future<Result<T>> guard<T>(Future<T> Function() fn) async {
    try {
      return Result.success(await fn());
    } on Exception catch (e, s) {
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Synchronous version of [guard].
  static Result<T> guardSync<T>(T Function() fn) {
    try {
      return Result.success(fn());
    } on Exception catch (e, s) {
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Whether this result is a success.
  bool get isSuccess => _either.isRight();

  /// Whether this result is a failure.
  bool get isFailure => _either.isLeft();

  /// Gets the success value, throwing if this is a failure.
  T get value => _either.getOrElse((l) => throw StateError('Result is a failure: $l'));

  /// Gets the success value or null if this is a failure.
  T? get valueOrNull => _either.fold((_) => null, (r) => r);

  /// Gets the failure, throwing if this is a success.
  Failure get failure => _either.fold((l) => l, (_) => throw StateError('Result is a success'));

  /// Gets the failure or null if this is a success.
  Failure? get failureOrNull => _either.fold((l) => l, (_) => null);

  /// Folds the result by applying [onFailure] if this is a failure,
  /// or [onSuccess] if this is a success.
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) =>
      _either.fold(onFailure, onSuccess);

  /// Maps the success value using [fn].
  Result<R> map<R>(R Function(T value) fn) => Result._(_either.map(fn));

  /// Maps the failure using [fn].
  Result<T> mapFailure(Failure Function(Failure failure) fn) =>
      Result._(_either.mapLeft(fn));

  /// Flat maps the success value using [fn].
  Result<R> flatMap<R>(Result<R> Function(T value) fn) =>
      _either.fold(Result.failure, fn);

  /// Returns [defaultValue] if this is a failure.
  T getOrElse(T defaultValue) => _either.getOrElse((_) => defaultValue);

  /// Returns the result of [fn] if this is a failure.
  T getOrElseLazy(T Function(Failure failure) fn) =>
      _either.fold(fn, (r) => r);

  /// Executes [fn] if this is a success.
  Result<T> tap(void Function(T value) fn) {
    if (isSuccess) fn(value);
    return this;
  }

  /// Executes [fn] if this is a failure.
  Result<T> tapFailure(void Function(Failure failure) fn) {
    if (isFailure) fn(failure);
    return this;
  }

  /// Converts this result to an [fp.Option].
  fp.Option<T> toOption() => _either.fold((_) => const fp.None(), fp.Some.new);

  @override
  List<Object?> get props => [_either];

  @override
  String toString() => fold(
        (failure) => 'Result.failure($failure)',
        (value) => 'Result.success($value)',
      );
}

/// Extension to convert futures of Results.
extension FutureResultExtension<T> on Future<Result<T>> {
  /// Maps the success value of the future result.
  Future<Result<R>> mapResult<R>(R Function(T value) fn) async =>
      (await this).map(fn);

  /// Flat maps the success value of the future result.
  Future<Result<R>> flatMapResult<R>(
    Future<Result<R>> Function(T value) fn,
  ) async {
    final result = await this;
    return result.fold(
      (failure) async => Result.failure(failure),
      fn,
    );
  }
}

/// Extension to convert nullable values to Results.
extension NullableToResult<T> on T? {
  /// Converts this nullable value to a Result.
  Result<T> toResult(Failure failure) => Result.fromNullable(this, failure);
}
