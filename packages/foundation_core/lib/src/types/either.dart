/// Re-exports fpdart's Either type and provides additional utilities.
///
/// Either represents a value that can be one of two types: Left or Right.
/// By convention, Left is used for failures and Right for success.
library;

import 'package:fpdart/fpdart.dart';

// Re-export Either from fpdart
export 'package:fpdart/fpdart.dart' show Either, Left, Right;

/// Extension methods for Either.
extension EitherExtension<L, R> on Either<L, R> {
  /// Converts this Either to a nullable Right value.
  R? get rightOrNull => fold((_) => null, (r) => r);

  /// Converts this Either to a nullable Left value.
  L? get leftOrNull => fold((l) => l, (_) => null);

  /// Executes [fn] if this is a Right.
  Either<L, R> tapRight(void Function(R value) fn) {
    fold((_) {}, fn);
    return this;
  }

  /// Executes [fn] if this is a Left.
  Either<L, R> tapLeft(void Function(L value) fn) {
    fold(fn, (_) {});
    return this;
  }
}

/// Extension to convert futures of Eithers.
extension FutureEitherExtension<L, R> on Future<Either<L, R>> {
  /// Maps the Right value of the future Either.
  Future<Either<L, R2>> mapRight<R2>(R2 Function(R value) fn) async =>
      (await this).map(fn);

  /// Maps the Left value of the future Either.
  Future<Either<L2, R>> mapLeft<L2>(L2 Function(L value) fn) async =>
      (await this).mapLeft(fn);

  /// Flat maps the Right value of the future Either.
  Future<Either<L, R2>> flatMapRight<R2>(
    Future<Either<L, R2>> Function(R value) fn,
  ) async {
    final either = await this;
    return either.fold(
      (l) async => Either.left(l),
      fn,
    );
  }
}
