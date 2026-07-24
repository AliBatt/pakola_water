import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:models/models.dart';

abstract class NotificationService {
  Stream<List<AppNotification>> watchForUser(String userId);
  Future<Result<AppNotification>> createNotification(AppNotification notification);
  Future<Result<void>> markRead(String notificationId);
  Future<Result<void>> markAllRead(String userId);
}

class NotificationServiceImpl implements NotificationService {
  NotificationServiceImpl(this._firestoreService);

  final FirestoreService _firestoreService;

  AppNotification _mapDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = doc.id;
    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) {
      data['createdAt'] = createdAt.toDate().toIso8601String();
    }
    return AppNotification.fromJson(data);
  }

  @override
  Stream<List<AppNotification>> watchForUser(String userId) {
    return _firestoreService
        .watchWhereOrderBy(
          CollectionPaths.notifications,
          field: 'userId',
          isEqualTo: userId,
          orderBy: 'createdAt',
        )
        .map((snapshot) => snapshot.docs.map(_mapDoc).toList());
  }

  @override
  Future<Result<AppNotification>> createNotification(
    AppNotification notification,
  ) async {
    try {
      final docRef =
          _firestoreService.collection(CollectionPaths.notifications).doc();
      final data = notification.toJson()
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['read'] = false;
      await docRef.set(data);
      return Success(
        AppNotification(
          id: docRef.id,
          userId: notification.userId,
          title: notification.title,
          body: notification.body,
          createdById: notification.createdById,
          createdByRole: notification.createdByRole,
          createdByName: notification.createdByName,
          read: false,
          type: notification.type,
          orderId: notification.orderId,
        ),
      );
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> markRead(String notificationId) async {
    try {
      await _firestoreService.updateDoc(
        CollectionPaths.notifications,
        notificationId,
        {'read': true},
      );
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> markAllRead(String userId) async {
    try {
      final snapshot = await _firestoreService.queryWhere(
        CollectionPaths.notifications,
        field: 'userId',
        isEqualTo: userId,
      );
      final batch = _firestoreService.instance.batch();
      for (final doc in snapshot.docs) {
        if (doc.data()['read'] == true) continue;
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }
}
