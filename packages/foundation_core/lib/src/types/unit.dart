import 'package:equatable/equatable.dart';

/// A type that represents the absence of a value.
///
/// Use this instead of `void` when you need a concrete type, for example
/// as a type parameter in generics like `Result<Unit>`.
///
/// Example:
/// ```dart
/// Future<Result<Unit>> deleteUser(String id) async {
///   await api.deleteUser(id);
///   return Result.success(unit);
/// }
/// ```
class Unit extends Equatable {
  const Unit._();

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'Unit';
}

/// The singleton instance of [Unit].
const unit = Unit._();
