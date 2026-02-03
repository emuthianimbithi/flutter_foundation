import '../types/result.dart';
import '../types/unit.dart';

/// Base class for use cases (interactors).
///
/// Use cases encapsulate business logic and represent a single action
/// the user can perform in the application.
///
/// Example:
/// ```dart
/// class GetUserUseCase extends UseCase<String, User> {
///   final UserRepository _repository;
///
///   GetUserUseCase(this._repository);
///
///   @override
///   Future<Result<User>> call(String userId) async {
///     return _repository.getUserById(userId);
///   }
/// }
///
/// // Usage
/// final getUserUseCase = GetUserUseCase(repository);
/// final result = await getUserUseCase('user-123');
/// ```
abstract class UseCase<Params, Output> {
  /// Executes the use case with the given [params].
  Future<Result<Output>> call(Params params);
}

/// A use case that doesn't require parameters.
///
/// Example:
/// ```dart
/// class GetCurrentUserUseCase extends NoParamsUseCase<User> {
///   final AuthRepository _authRepository;
///
///   GetCurrentUserUseCase(this._authRepository);
///
///   @override
///   Future<Result<User>> call() async {
///     return _authRepository.getCurrentUser();
///   }
/// }
/// ```
abstract class NoParamsUseCase<Output> {
  /// Executes the use case.
  Future<Result<Output>> call();
}

/// A use case that doesn't return a meaningful value.
///
/// Example:
/// ```dart
/// class LogoutUseCase extends VoidUseCase<void> {
///   final AuthRepository _authRepository;
///
///   LogoutUseCase(this._authRepository);
///
///   @override
///   Future<Result<Unit>> call(void _) async {
///     await _authRepository.logout();
///     return Result.success(unit);
///   }
/// }
/// ```
abstract class VoidUseCase<Params> extends UseCase<Params, Unit> {}

/// A use case that neither requires parameters nor returns a value.
abstract class SimpleUseCase extends NoParamsUseCase<Unit> {}

/// A synchronous use case.
///
/// Example:
/// ```dart
/// class ValidateEmailUseCase extends SyncUseCase<String, bool> {
///   @override
///   Result<bool> call(String email) {
///     final isValid = EmailValidator.validate(email);
///     return Result.success(isValid);
///   }
/// }
/// ```
abstract class SyncUseCase<Params, Output> {
  /// Executes the use case synchronously.
  Result<Output> call(Params params);
}

/// A synchronous use case that doesn't require parameters.
abstract class SyncNoParamsUseCase<Output> {
  /// Executes the use case synchronously.
  Result<Output> call();
}

/// A streaming use case that returns a stream of results.
///
/// Example:
/// ```dart
/// class WatchUserUseCase extends StreamUseCase<String, User> {
///   final UserRepository _repository;
///
///   WatchUserUseCase(this._repository);
///
///   @override
///   Stream<Result<User>> call(String userId) {
///     return _repository.watchUser(userId);
///   }
/// }
/// ```
abstract class StreamUseCase<Params, Output> {
  /// Executes the use case and returns a stream.
  Stream<Result<Output>> call(Params params);
}

/// A streaming use case that doesn't require parameters.
abstract class StreamNoParamsUseCase<Output> {
  /// Executes the use case and returns a stream.
  Stream<Result<Output>> call();
}
