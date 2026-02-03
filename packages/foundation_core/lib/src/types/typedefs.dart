import 'dart:async';

import 'result.dart';

/// A JSON object type alias.
typedef Json = Map<String, dynamic>;

/// A JSON list type alias.
typedef JsonList = List<Map<String, dynamic>>;

/// A callback that takes no arguments and returns void.
typedef VoidCallback = void Function();

/// A callback that takes a value of type [T].
typedef ValueCallback<T> = void Function(T value);

/// A callback that takes two values.
typedef ValueCallback2<T1, T2> = void Function(T1 value1, T2 value2);

/// An async callback that takes no arguments.
typedef AsyncCallback = Future<void> Function();

/// An async callback that takes a value of type [T].
typedef AsyncValueCallback<T> = Future<void> Function(T value);

/// A predicate function that takes a value of type [T].
typedef Predicate<T> = bool Function(T value);

/// A mapper function that transforms [T] to [R].
typedef Mapper<T, R> = R Function(T value);

/// An async mapper function.
typedef AsyncMapper<T, R> = Future<R> Function(T value);

/// A factory function that creates a value of type [T].
typedef Factory<T> = T Function();

/// An async factory function.
typedef AsyncFactory<T> = Future<T> Function();

/// A disposer function.
typedef Disposer = FutureOr<void> Function();

/// A function that returns a Result.
typedef ResultCallback<T> = Future<Result<T>> Function();

/// A function that parses JSON into a typed object.
typedef FromJson<T> = T Function(Json json);

/// A function that converts a typed object to JSON.
typedef ToJson<T> = Json Function(T value);
