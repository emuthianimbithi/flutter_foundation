import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_core/foundation_core.dart';

void main() {
  group('Result', () {
    test('success creates a successful result', () {
      final result = Result.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, equals(42));
    });

    test('failure creates a failed result', () {
      final failure = Failure.validation('Invalid input');
      final result = Result<int>.failure(failure);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(failure));
    });

    test('fold applies correct function', () {
      final success = Result.success(42);
      final failure = Result<int>.failure(Failure.validation('error'));

      expect(
        success.fold((f) => 'failure', (v) => 'success: $v'),
        equals('success: 42'),
      );
      expect(
        failure.fold((f) => 'failure: ${f.message}', (v) => 'success'),
        equals('failure: error'),
      );
    });

    test('map transforms success value', () {
      final result = Result.success(42);
      final mapped = result.map((v) => v * 2);
      expect(mapped.value, equals(84));
    });

    test('guard catches exceptions', () async {
      final result = await Result.guard(() async {
        throw Exception('test error');
      });
      expect(result.isFailure, isTrue);
      expect(result.failure.type, equals(FailureType.unexpected));
    });
  });

  group('Failure', () {
    test('creates different failure types', () {
      expect(Failure.network('error').type, equals(FailureType.network));
      expect(Failure.server('error').type, equals(FailureType.server));
      expect(Failure.validation('error').type, equals(FailureType.validation));
      expect(
        Failure.authentication('error').type,
        equals(FailureType.authentication),
      );
    });

    test('isRecoverable returns correct value', () {
      expect(Failure.network('error').isRecoverable, isTrue);
      expect(Failure.timeout().isRecoverable, isTrue);
      expect(Failure.validation('error').isRecoverable, isFalse);
    });
  });

  group('Paginated', () {
    test('calculates pagination correctly', () {
      final page = Paginated<int>(
        items: [1, 2, 3],
        page: 2,
        pageSize: 3,
        totalItems: 10,
      );

      expect(page.totalPages, equals(4));
      expect(page.hasNextPage, isTrue);
      expect(page.hasPreviousPage, isTrue);
      expect(page.isFirstPage, isFalse);
      expect(page.isLastPage, isFalse);
    });

    test('empty creates empty pagination', () {
      final page = Paginated<int>.empty();
      expect(page.isEmpty, isTrue);
      expect(page.totalPages, equals(0));
      expect(page.hasNextPage, isFalse);
    });
  });

  group('Email ValueObject', () {
    test('creates valid email', () {
      final result = Email.create('test@example.com');
      expect(result.isSuccess, isTrue);
      expect(result.value.value, equals('test@example.com'));
    });

    test('normalizes email to lowercase', () {
      final result = Email.create('Test@Example.COM');
      expect(result.isSuccess, isTrue);
      expect(result.value.value, equals('test@example.com'));
    });

    test('rejects invalid email', () {
      final result = Email.create('not-an-email');
      expect(result.isFailure, isTrue);
      expect(result.failure.type, equals(FailureType.validation));
    });
  });

  group('StringExtensions', () {
    test('capitalized capitalizes first letter', () {
      expect('hello'.capitalized, equals('Hello'));
      expect(''.capitalized, equals(''));
    });

    test('titleCase capitalizes each word', () {
      expect('hello world'.titleCase, equals('Hello World'));
    });

    test('camelCase converts correctly', () {
      expect('hello world'.camelCase, equals('helloWorld'));
      expect('HelloWorld'.camelCase, equals('helloWorld'));
      expect('hello_world'.camelCase, equals('helloWorld'));
    });

    test('snakeCase converts correctly', () {
      expect('helloWorld'.snakeCase, equals('hello_world'));
      expect('HelloWorld'.snakeCase, equals('hello_world'));
    });

    test('truncate truncates with ellipsis', () {
      expect('hello world'.truncate(8), equals('hello...'));
      expect('hello'.truncate(10), equals('hello'));
    });

    test('isEmail validates email format', () {
      expect('test@example.com'.isEmail, isTrue);
      expect('invalid'.isEmail, isFalse);
    });
  });

  group('DateTimeExtensions', () {
    test('isToday returns correct value', () {
      expect(DateTime.now().isToday, isTrue);
      expect(DateTime.now().subtract(const Duration(days: 1)).isToday, isFalse);
    });

    test('dateOnly returns date without time', () {
      final dateTime = DateTime(2024, 1, 15, 14, 30, 45);
      final dateOnly = dateTime.dateOnly;
      expect(dateOnly.hour, equals(0));
      expect(dateOnly.minute, equals(0));
      expect(dateOnly.second, equals(0));
    });

    test('addMonths handles month boundaries', () {
      final date = DateTime(2024, 1, 31);
      final result = date.addMonths(1);
      expect(result.month, equals(2));
      expect(result.day, lessThanOrEqualTo(29));
    });
  });

  group('IterableExtensions', () {
    test('firstOrNull returns null for empty', () {
      expect(<int>[].firstOrNull, isNull);
      expect([1, 2, 3].firstOrNull, equals(1));
    });

    test('groupBy groups correctly', () {
      final items = ['a', 'ab', 'abc', 'b', 'bc'];
      final grouped = items.groupBy((s) => s.length);
      expect(grouped[1], equals(['a', 'b']));
      expect(grouped[2], equals(['ab', 'bc']));
      expect(grouped[3], equals(['abc']));
    });

    test('distinctBy removes duplicates by key', () {
      final items = [
        (id: 1, name: 'a'),
        (id: 2, name: 'b'),
        (id: 1, name: 'c'),
      ];
      final distinct = items.distinctBy((item) => item.id).toList();
      expect(distinct.length, equals(2));
    });

    test('chunked splits into correct sizes', () {
      final items = [1, 2, 3, 4, 5];
      final chunks = items.chunked(2).toList();
      expect(chunks.length, equals(3));
      expect(chunks[0], equals([1, 2]));
      expect(chunks[1], equals([3, 4]));
      expect(chunks[2], equals([5]));
    });
  });

  group('MapExtensions', () {
    test('getOrDefault returns default for missing key', () {
      final map = {'a': 1, 'b': 2};
      expect(map.getOrDefault('a', 0), equals(1));
      expect(map.getOrDefault('c', 0), equals(0));
    });

    test('mapValues transforms values', () {
      final map = {'a': 1, 'b': 2};
      final result = map.mapValues((v) => v * 2);
      expect(result, equals({'a': 2, 'b': 4}));
    });

    test('where filters entries', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      final result = map.where((k, v) => v > 1);
      expect(result, equals({'b': 2, 'c': 3}));
    });
  });

  group('Validators', () {
    test('required validates empty values', () {
      final validator = Validators.required('Required');
      expect(validator(null), equals('Required'));
      expect(validator(''), equals('Required'));
      expect(validator('  '), equals('Required'));
      expect(validator('value'), isNull);
    });

    test('email validates format', () {
      final validator = Validators.email();
      expect(validator('test@example.com'), isNull);
      expect(validator('invalid'), isNotNull);
      expect(validator(''), isNull); // Empty is valid (use compose with required)
    });

    test('minLength validates length', () {
      final validator = Validators.minLength(5);
      expect(validator('hi'), isNotNull);
      expect(validator('hello'), isNull);
      expect(validator('hello world'), isNull);
    });

    test('compose combines validators', () {
      final validator = Validators.compose([
        Validators.required(),
        Validators.email(),
      ]);
      expect(validator(''), isNotNull); // Fails required
      expect(validator('invalid'), isNotNull); // Fails email
      expect(validator('test@example.com'), isNull); // Passes both
    });

    test('password validates complexity', () {
      final validator = Validators.password(
        minLength: 8,
        requireUppercase: true,
        requireLowercase: true,
        requireDigit: true,
      );
      expect(validator('weak'), isNotNull);
      expect(validator('WeakPass1'), isNull);
    });
  });

  group('Debouncer', () {
    test('debounces function calls', () async {
      var callCount = 0;
      final debouncer = Debouncer(
        duration: const Duration(milliseconds: 50),
      );

      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);

      expect(callCount, equals(0));

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(callCount, equals(1));

      debouncer.dispose();
    });

    test('cancel prevents execution', () async {
      var called = false;
      final debouncer = Debouncer(
        duration: const Duration(milliseconds: 50),
      );

      debouncer.run(() => called = true);
      debouncer.cancel();

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(called, isFalse);

      debouncer.dispose();
    });
  });

  group('UuidGenerator', () {
    test('v4 generates valid UUID', () {
      final uuid = UuidGenerator.v4();
      expect(UuidGenerator.isValid(uuid), isTrue);
    });

    test('shortId generates 8 character ID', () {
      final id = UuidGenerator.shortId();
      expect(id.length, equals(8));
    });

    test('compactId generates UUID without hyphens', () {
      final id = UuidGenerator.compactId();
      expect(id.length, equals(32));
      expect(id.contains('-'), isFalse);
    });

    test('isValid validates UUID format', () {
      expect(
        UuidGenerator.isValid('550e8400-e29b-41d4-a716-446655440000'),
        isTrue,
      );
      expect(UuidGenerator.isValid('invalid'), isFalse);
    });
  });
}
