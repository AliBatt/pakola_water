import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:models/models.dart';

abstract class OrderService {
  Future<Result<DeliveryOrder>> createOrder(DeliveryOrder order);
  Stream<List<DeliveryOrder>> watchCustomerOrders(String customerId);
  Stream<DeliveryOrder?> watchActiveOrder(String customerId);
  Future<Result<void>> confirmDelivery(String orderId);
  Future<Result<bool>> hasActiveOrder(String customerId);
}

class OrderServiceImpl implements OrderService {
  OrderServiceImpl(this._firestoreService);

  final FirestoreService _firestoreService;

  static const _terminalStatuses = {
    'delivered',
    'cancelled',
    'failed',
  };

  DeliveryOrder _mapDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = doc.id;
    _normalizeTimestamps(data);
    return DeliveryOrder.fromJson(data);
  }

  void _normalizeTimestamps(Map<String, dynamic> data) {
    for (final key in [
      'createdAt',
      'updatedAt',
      'estimatedArrivalAt',
      'supervisorNotifiedAt',
      'assignedAt',
      'riderArrivedAt',
      'deliveredAt',
    ]) {
      final value = data[key];
      if (value is Timestamp) {
        data[key] = value.toDate().toIso8601String();
      }
    }
  }

  @override
  Future<Result<DeliveryOrder>> createOrder(DeliveryOrder order) async {
    try {
      final active = await hasActiveOrder(order.customerId);
      if (active case Success<bool>(value: true)) {
        return const FailureResult(
          ServerFailure('You already have an ongoing order'),
        );
      }

      final docRef =
          _firestoreService.collection(CollectionPaths.orders).doc();
      final data = order.toJson()
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp()
        ..['status'] = OrderStatus.pending.name
        ..['paymentStatus'] = 'pending'
        ..['createdBy'] = order.customerId;

      await docRef.set(data);
      return Success(order.copyWith(id: docRef.id));
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Stream<List<DeliveryOrder>> watchCustomerOrders(String customerId) {
    return _firestoreService
        .watchWhereOrderBy(
          CollectionPaths.orders,
          field: 'customerId',
          isEqualTo: customerId,
          orderBy: 'createdAt',
        )
        .map((snapshot) => snapshot.docs.map(_mapDoc).toList());
  }

  @override
  Stream<DeliveryOrder?> watchActiveOrder(String customerId) {
    return watchCustomerOrders(customerId).map((orders) {
      for (final order in orders) {
        if (order.status.isActive) return order;
      }
      return null;
    });
  }

  @override
  Future<Result<bool>> hasActiveOrder(String customerId) async {
    try {
      final snapshot = await _firestoreService.queryWhere(
        CollectionPaths.orders,
        field: 'customerId',
        isEqualTo: customerId,
      );
      final hasActive = snapshot.docs.any((doc) {
        final status = doc.data()['status'] as String? ?? '';
        return !_terminalStatuses.contains(status);
      });
      return Success(hasActive);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> confirmDelivery(String orderId) async {
    try {
      final snapshot =
          await _firestoreService.doc(CollectionPaths.orders, orderId).get();
      if (!snapshot.exists) {
        return const FailureResult(ServerFailure('Order not found'));
      }
      final status = snapshot.data()?['status'] as String?;
      if (status != OrderStatus.riderArrived.name) {
        return const FailureResult(
          ServerFailure('Order is not ready to confirm yet'),
        );
      }

      await _firestoreService.updateDoc(
        CollectionPaths.orders,
        orderId,
        {
          'status': OrderStatus.delivered.name,
          'deliveredAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }
}
