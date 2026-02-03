import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foundation_core/foundation_core.dart';

/// Firestore client wrapper with simplified API and offline support.
///
/// Example:
/// ```dart
/// final client = FirestoreClient();
///
/// // Get document
/// final result = await client.get<Map<String, dynamic>>('users', 'user123');
///
/// // Set document
/// await client.set('users', 'user123', {'name': 'John', 'email': 'john@example.com'});
///
/// // Query
/// final users = await client.query<Map<String, dynamic>>(
///   'users',
///   where: [WhereClause('status', isEqualTo: 'active')],
///   orderBy: 'createdAt',
///   limit: 10,
/// );
///
/// // Listen to changes
/// client.watch<Map<String, dynamic>>('users', 'user123').listen((data) {
///   print('User updated: $data');
/// });
/// ```
class FirestoreClient {
  final FirebaseFirestore _firestore;
  final AppLogger _log = AppLogger('FirestoreClient');

  FirestoreClient({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    // Enable offline persistence
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Gets a document.
  Future<Result<T?>> get<T>(
    String collection,
    String documentId, {
    Source source = Source.serverAndCache,
  }) async {
    try {
      _log.debug('Get: $collection/$documentId');

      final doc = await _firestore
          .collection(collection)
          .doc(documentId)
          .get(GetOptions(source: source));

      if (!doc.exists) {
        return Result.success(null);
      }

      final data = doc.data();
      return Result.success(data as T?);
    } on FirebaseException catch (e) {
      _log.error('Firestore get error', e);
      return Result.failure(_mapFirestoreError(e));
    } catch (e, s) {
      _log.error('Get error', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Sets a document (creates or overwrites).
  Future<Result<Unit>> set(
    String collection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      _log.debug('Set: $collection/$documentId');

      await _firestore
          .collection(collection)
          .doc(documentId)
          .set(data, SetOptions(merge: merge));

      return Result.success(unit);
    } on FirebaseException catch (e) {
      _log.error('Firestore set error', e);
      return Result.failure(_mapFirestoreError(e));
    } catch (e, s) {
      _log.error('Set error', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Updates a document.
  Future<Result<Unit>> update(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      _log.debug('Update: $collection/$documentId');

      await _firestore.collection(collection).doc(documentId).update(data);

      return Result.success(unit);
    } on FirebaseException catch (e) {
      _log.error('Firestore update error', e);
      return Result.failure(_mapFirestoreError(e));
    } catch (e, s) {
      _log.error('Update error', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Deletes a document.
  Future<Result<Unit>> delete(String collection, String documentId) async {
    try {
      _log.debug('Delete: $collection/$documentId');

      await _firestore.collection(collection).doc(documentId).delete();

      return Result.success(unit);
    } on FirebaseException catch (e) {
      _log.error('Firestore delete error', e);
      return Result.failure(_mapFirestoreError(e));
    } catch (e, s) {
      _log.error('Delete error', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Adds a document with auto-generated ID.
  Future<Result<String>> add(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      _log.debug('Add to: $collection');

      final doc = await _firestore.collection(collection).add(data);

      return Result.success(doc.id);
    } on FirebaseException catch (e) {
      _log.error('Firestore add error', e);
      return Result.failure(_mapFirestoreError(e));
    } catch (e, s) {
      _log.error('Add error', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Queries documents.
  Future<Result<List<T>>> query<T>(
    String collection, {
    List<WhereClause>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
    DocumentSnapshot? startAfter,
    Source source = Source.serverAndCache,
  }) async {
    try {
      _log.debug('Query: $collection');

      Query query = _firestore.collection(collection);

      // Apply where clauses
      if (where != null) {
        for (final clause in where) {
          query = clause.apply(query);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get(GetOptions(source: source));

      final results = snapshot.docs.map((doc) => doc.data() as T).toList();

      return Result.success(results);
    } on FirebaseException catch (e) {
      _log.error('Firestore query error', e);
      return Result.failure(_mapFirestoreError(e));
    } catch (e, s) {
      _log.error('Query error', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Watches a document for changes.
  Stream<T?> watch<T>(String collection, String documentId) {
    _log.debug('Watch: $collection/$documentId');

    return _firestore
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() as T? : null);
  }

  /// Watches a collection for changes.
  Stream<List<T>> watchCollection<T>(
    String collection, {
    List<WhereClause>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    _log.debug('Watch collection: $collection');

    Query query = _firestore.collection(collection);

    if (where != null) {
      for (final clause in where) {
        query = clause.apply(query);
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data() as T).toList(),
        );
  }

  /// Runs a batch write.
  Future<Result<Unit>> batch(
    void Function(WriteBatch batch) operations,
  ) async {
    try {
      _log.debug('Batch write');

      final batch = _firestore.batch();
      operations(batch);
      await batch.commit();

      return Result.success(unit);
    } on FirebaseException catch (e) {
      _log.error('Firestore batch error', e);
      return Result.failure(_mapFirestoreError(e));
    } catch (e, s) {
      _log.error('Batch error', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Runs a transaction.
  Future<Result<T>> transaction<T>(
    Future<T> Function(Transaction transaction) operations,
  ) async {
    try {
      _log.debug('Transaction');

      final result = await _firestore.runTransaction(operations);

      return Result.success(result);
    } on FirebaseException catch (e) {
      _log.error('Firestore transaction error', e);
      return Result.failure(_mapFirestoreError(e));
    } catch (e, s) {
      _log.error('Transaction error', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Gets a collection reference.
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _firestore.collection(path);

  /// Gets a document reference.
  DocumentReference<Map<String, dynamic>> doc(String collection, String id) =>
      _firestore.collection(collection).doc(id);

  Failure _mapFirestoreError(FirebaseException e) {
    return switch (e.code) {
      'permission-denied' =>
        Failure.authorization(e.message ?? 'Permission denied'),
      'not-found' => Failure.notFound(e.message ?? 'Document not found'),
      'already-exists' =>
        Failure.conflict(e.message ?? 'Document already exists'),
      'unavailable' => Failure.network(e.message ?? 'Service unavailable'),
      'cancelled' => Failure.cancelled(e.message ?? 'Operation cancelled'),
      'deadline-exceeded' =>
        Failure.timeout(e.message ?? 'Operation timed out'),
      _ => Failure.unexpected(e.message ?? 'Firestore error', code: e.code),
    };
  }
}

/// Helper class for building where clauses.
class WhereClause {
  final String field;
  final dynamic isEqualTo;
  final dynamic isNotEqualTo;
  final dynamic isLessThan;
  final dynamic isLessThanOrEqualTo;
  final dynamic isGreaterThan;
  final dynamic isGreaterThanOrEqualTo;
  final dynamic arrayContains;
  final List<dynamic>? arrayContainsAny;
  final List<dynamic>? whereIn;
  final List<dynamic>? whereNotIn;
  final bool? isNull;

  const WhereClause(
    this.field, {
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
  });

  Query apply(Query query) {
    if (isEqualTo != null) {
      return query.where(field, isEqualTo: isEqualTo);
    }
    if (isNotEqualTo != null) {
      return query.where(field, isNotEqualTo: isNotEqualTo);
    }
    if (isLessThan != null) {
      return query.where(field, isLessThan: isLessThan);
    }
    if (isLessThanOrEqualTo != null) {
      return query.where(field, isLessThanOrEqualTo: isLessThanOrEqualTo);
    }
    if (isGreaterThan != null) {
      return query.where(field, isGreaterThan: isGreaterThan);
    }
    if (isGreaterThanOrEqualTo != null) {
      return query.where(field, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo);
    }
    if (arrayContains != null) {
      return query.where(field, arrayContains: arrayContains);
    }
    if (arrayContainsAny != null) {
      return query.where(field, arrayContainsAny: arrayContainsAny);
    }
    if (whereIn != null) {
      return query.where(field, whereIn: whereIn);
    }
    if (whereNotIn != null) {
      return query.where(field, whereNotIn: whereNotIn);
    }
    if (isNull != null) {
      return query.where(field, isNull: isNull);
    }
    return query;
  }
}
