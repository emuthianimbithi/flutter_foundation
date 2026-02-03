/// Core utilities, types, and extensions for Flutter Foundation packages.
///
/// This library provides the foundational building blocks used across all
/// Foundation packages, including:
///
/// - [Result] and [Either] types for functional error handling
/// - Extension methods for common Dart types
/// - Logging utilities
/// - Base classes for entities and value objects
library foundation_core;

// Types
export 'src/types/result.dart';
export 'src/types/either.dart';
export 'src/types/unit.dart';
export 'src/types/failure.dart';
export 'src/types/paginated.dart';
export 'src/types/typedefs.dart';

// Extensions
export 'src/extensions/string_extensions.dart';
export 'src/extensions/datetime_extensions.dart';
export 'src/extensions/iterable_extensions.dart';
export 'src/extensions/map_extensions.dart';
export 'src/extensions/context_extensions.dart';
export 'src/extensions/future_extensions.dart';

// Utils
export 'src/utils/logger.dart';
export 'src/utils/debouncer.dart';
export 'src/utils/throttler.dart';
export 'src/utils/validators.dart';
export 'src/utils/uuid_generator.dart';

// Base classes
export 'src/base/entity.dart';
export 'src/base/value_object.dart';
export 'src/base/use_case.dart';
