import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:models/models.dart';

abstract class OrderService {
  Future<Result<DeliveryOrder>> createOrder(DeliveryOrder order);
  Future<Result<DeliveryOrder>> createManualOrder({
    required DeliveryOrder order,
    required String createdByAdminId,
    required String supervisorId,
    required String supervisorName,
    required String riderId,
    required String riderName,
    required DateTime estimatedArrivalAt,
  });
  Stream<List<DeliveryOrder>> watchCustomerOrders(String customerId);
  Stream<DeliveryOrder?> watchActiveOrder(String customerId);
  Stream<List<DeliveryOrder>> watchBranchOrders(String branchId);
  Stream<List<DeliveryOrder>> watchAllOrders();
  Stream<List<DeliveryOrder>> watchRiderOrders(String riderId);
  Future<Result<void>> confirmDelivery(String orderId);
  Future<Result<void>> assignToRider({
    required String orderId,
    required String supervisorId,
    required String supervisorName,
    required String riderId,
    required String riderName,
    required DateTime estimatedArrivalAt,
  });
  Future<Result<void>> adminMarkDelivered({
    required String orderId,
    required String adminId,
    required String adminName,
    String? adminNotes,
  });
  Future<Result<void>> adminMarkFailed({
    required String orderId,
    required String adminId,
    required String adminName,
    required String failureReason,
    String? adminNotes,
  });
  Future<Result<void>> adminUpdateNotes({
    required String orderId,
    required String adminNotes,
  });
  Future<Result<void>> markOutForDelivery(String orderId);
  Future<Result<void>> markRiderArrived(String orderId);
  Future<Result<void>> markPaymentPaid(String orderId);
  Future<Result<void>> cancelOrder({
    required String orderId,
    required String cancelledById,
    required String cancelledByName,
    required String cancelledByRole,
    String? reason,
  });
  Future<Result<bool>> hasActiveOrder(String customerId);
  Future<Result<bool>> hasOpenOrderOfType({
    required String customerId,
    required OrderType orderType,
  });
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
      'outForDeliveryAt',
      'riderArrivedAt',
      'deliveredAt',
      'failedAt',
      'scheduledFor',
      'scheduledActivatedAt',
      'cancelledAt',
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
      final orderType = order.orderType;
      final isScheduled = orderType == OrderType.scheduled;
      final scheduledFor = order.scheduledForDate;

      if (isScheduled) {
        if (scheduledFor == null) {
          return const FailureResult(
            ServerFailure('Select a date and time for the scheduled order'),
          );
        }
        if (!scheduledFor.isAfter(DateTime.now())) {
          return const FailureResult(
            ServerFailure('Scheduled time must be in the future'),
          );
        }
      }

      final openSlot = await hasOpenOrderOfType(
        customerId: order.customerId,
        orderType: orderType,
      );
      if (openSlot case Success<bool>(value: true)) {
        return FailureResult(
          ServerFailure(
            isScheduled
                ? 'You already have a scheduled order'
                : 'You already have an ongoing instant order',
          ),
        );
      }
      if (openSlot case FailureResult(:final failure)) {
        return FailureResult(failure);
      }

      final docRef =
          _firestoreService.collection(CollectionPaths.orders).doc();
      final status =
          isScheduled ? OrderStatus.scheduled : OrderStatus.pending;
      final data = order.toJson()
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp()
        ..['status'] = status.name
        ..['orderType'] = orderType.name
        ..['paymentStatus'] = PaymentStatus.pending.name
        ..['createdBy'] = order.customerId
        ..['scheduledFor'] = isScheduled && scheduledFor != null
            ? Timestamp.fromDate(scheduledFor)
            : null
        ..['scheduledActivatedAt'] = null;

      await docRef.set(data);
      return Success(
        order.copyWith(
          id: docRef.id,
          status: status,
          orderType: orderType,
          scheduledFor: scheduledFor?.toIso8601String(),
        ),
      );
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<DeliveryOrder>> createManualOrder({
    required DeliveryOrder order,
    required String createdByAdminId,
    required String supervisorId,
    required String supervisorName,
    required String riderId,
    required String riderName,
    required DateTime estimatedArrivalAt,
  }) async {
    try {
      final docRef =
          _firestoreService.collection(CollectionPaths.orders).doc();
      final data = order.toJson()
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp()
        ..['status'] = OrderStatus.assigned.name
        ..['paymentStatus'] = PaymentStatus.pending.name
        ..['createdBy'] = createdByAdminId
        ..['createdByRole'] = AppRole.admin.name
        ..['manualOrder'] = true
        ..['supervisorId'] = supervisorId
        ..['supervisorName'] = supervisorName
        ..['riderId'] = riderId
        ..['riderName'] = riderName
        ..['supervisorNotifiedAt'] = FieldValue.serverTimestamp()
        ..['assignedAt'] = FieldValue.serverTimestamp()
        ..['estimatedArrivalAt'] = Timestamp.fromDate(estimatedArrivalAt);

      await docRef.set(data);
      return Success(
        order.copyWith(
          id: docRef.id,
          status: OrderStatus.assigned,
          supervisorId: supervisorId,
          supervisorName: supervisorName,
          riderId: riderId,
          riderName: riderName,
          estimatedArrivalAt: estimatedArrivalAt.toIso8601String(),
        ),
      );
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
        final status = OrderStatus.fromString(
          doc.data()['status'] as String? ?? '',
        );
        return status.isActive;
      });
      return Success(hasActive);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<bool>> hasOpenOrderOfType({
    required String customerId,
    required OrderType orderType,
  }) async {
    try {
      final snapshot = await _firestoreService.queryWhere(
        CollectionPaths.orders,
        field: 'customerId',
        isEqualTo: customerId,
      );
      final hasOpen = snapshot.docs.any((doc) {
        final data = doc.data();
        final status = OrderStatus.fromString(
          data['status'] as String? ?? '',
        );
        if (!status.isOpen) return false;
        final type = OrderType.fromString(
          data['orderType'] as String? ??
              (status == OrderStatus.scheduled
                  ? OrderType.scheduled.name
                  : OrderType.instant.name),
        );
        return type == orderType;
      });
      return Success(hasOpen);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Stream<List<DeliveryOrder>> watchBranchOrders(String branchId) {
    return _firestoreService
        .watchWhereOrderBy(
          CollectionPaths.orders,
          field: 'branchId',
          isEqualTo: branchId,
          orderBy: 'createdAt',
        )
        .map((snapshot) => snapshot.docs.map(_mapDoc).toList());
  }

  @override
  Stream<List<DeliveryOrder>> watchAllOrders() {
    return _firestoreService
        .watchCollectionOrderBy(
          CollectionPaths.orders,
          orderBy: 'createdAt',
        )
        .map((snapshot) => snapshot.docs.map(_mapDoc).toList());
  }

  @override
  Stream<List<DeliveryOrder>> watchRiderOrders(String riderId) {
    return _firestoreService
        .watchWhereOrderBy(
          CollectionPaths.orders,
          field: 'riderId',
          isEqualTo: riderId,
          orderBy: 'createdAt',
        )
        .map((snapshot) => snapshot.docs.map(_mapDoc).toList());
  }

  @override
  Future<Result<void>> markOutForDelivery(String orderId) async {
    try {
      final snapshot =
          await _firestoreService.doc(CollectionPaths.orders, orderId).get();
      if (!snapshot.exists) {
        return const FailureResult(ServerFailure('Order not found'));
      }
      final status = snapshot.data()?['status'] as String?;
      if (status != OrderStatus.assigned.name) {
        return const FailureResult(
          ServerFailure('Order must be assigned before going out for delivery'),
        );
      }

      await _firestoreService.updateDoc(
        CollectionPaths.orders,
        orderId,
        {
          'status': OrderStatus.outForDelivery.name,
          'outForDeliveryAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> markRiderArrived(String orderId) async {
    try {
      final snapshot =
          await _firestoreService.doc(CollectionPaths.orders, orderId).get();
      if (!snapshot.exists) {
        return const FailureResult(ServerFailure('Order not found'));
      }
      final status = snapshot.data()?['status'] as String?;
      if (status != OrderStatus.outForDelivery.name) {
        return const FailureResult(
          ServerFailure('Order must be out for delivery first'),
        );
      }

      await _firestoreService.updateDoc(
        CollectionPaths.orders,
        orderId,
        {
          'status': OrderStatus.riderArrived.name,
          'riderArrivedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> assignToRider({
    required String orderId,
    required String supervisorId,
    required String supervisorName,
    required String riderId,
    required String riderName,
    required DateTime estimatedArrivalAt,
  }) async {
    try {
      final snapshot =
          await _firestoreService.doc(CollectionPaths.orders, orderId).get();
      if (!snapshot.exists) {
        return const FailureResult(ServerFailure('Order not found'));
      }
      final data = snapshot.data() ?? {};
      final status = OrderStatus.fromString(data['status'] as String? ?? '');
      if (status == OrderStatus.scheduled) {
        return const FailureResult(
          ServerFailure(
            'This scheduled order cannot be assigned until its time arrives',
          ),
        );
      }
      if (!status.isRequested) {
        return const FailureResult(
          ServerFailure('Only pending orders can be assigned'),
        );
      }

      await _firestoreService.updateDoc(
        CollectionPaths.orders,
        orderId,
        {
          'supervisorId': supervisorId,
          'supervisorName': supervisorName,
          'riderId': riderId,
          'riderName': riderName,
          'status': OrderStatus.assigned.name,
          'supervisorNotifiedAt': FieldValue.serverTimestamp(),
          'assignedAt': FieldValue.serverTimestamp(),
          'estimatedArrivalAt': Timestamp.fromDate(estimatedArrivalAt),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> adminMarkDelivered({
    required String orderId,
    required String adminId,
    required String adminName,
    String? adminNotes,
  }) async {
    try {
      final snapshot =
          await _firestoreService.doc(CollectionPaths.orders, orderId).get();
      if (!snapshot.exists) {
        return const FailureResult(ServerFailure('Order not found'));
      }
      final status = snapshot.data()?['status'] as String? ?? '';
      if (_terminalStatuses.contains(status)) {
        return const FailureResult(
          ServerFailure('Order is already closed'),
        );
      }

      final notes = adminNotes?.trim();
      final paymentMethod = PaymentMethod.fromString(
        snapshot.data()?['paymentMethod'] as String? ?? 'cod',
      );
      await _firestoreService.updateDoc(
        CollectionPaths.orders,
        orderId,
        {
          'status': OrderStatus.delivered.name,
          'deliveredAt': FieldValue.serverTimestamp(),
          // COD is collected on delivery; credit stays unpaid until settled.
          if (paymentMethod == PaymentMethod.cod)
            'paymentStatus': PaymentStatus.paid.name,
          'adminActionById': adminId,
          'adminActionByName': adminName,
          if (notes != null && notes.isNotEmpty) 'adminNotes': notes,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> adminMarkFailed({
    required String orderId,
    required String adminId,
    required String adminName,
    required String failureReason,
    String? adminNotes,
  }) async {
    try {
      final reason = failureReason.trim();
      if (reason.isEmpty) {
        return const FailureResult(
          ServerFailure('Failure reason is required'),
        );
      }

      final snapshot =
          await _firestoreService.doc(CollectionPaths.orders, orderId).get();
      if (!snapshot.exists) {
        return const FailureResult(ServerFailure('Order not found'));
      }
      final status = snapshot.data()?['status'] as String? ?? '';
      if (_terminalStatuses.contains(status)) {
        return const FailureResult(
          ServerFailure('Order is already closed'),
        );
      }

      final notes = adminNotes?.trim();
      await _firestoreService.updateDoc(
        CollectionPaths.orders,
        orderId,
        {
          'status': OrderStatus.failed.name,
          'failedAt': FieldValue.serverTimestamp(),
          'failureReason': reason,
          'adminActionById': adminId,
          'adminActionByName': adminName,
          if (notes != null && notes.isNotEmpty) 'adminNotes': notes,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> adminUpdateNotes({
    required String orderId,
    required String adminNotes,
  }) async {
    try {
      await _firestoreService.updateDoc(
        CollectionPaths.orders,
        orderId,
        {
          'adminNotes': adminNotes.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      return const Success(null);
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

      final paymentMethod = PaymentMethod.fromString(
        snapshot.data()?['paymentMethod'] as String? ?? 'cod',
      );

      await _firestoreService.updateDoc(
        CollectionPaths.orders,
        orderId,
        {
          'status': OrderStatus.delivered.name,
          'deliveredAt': FieldValue.serverTimestamp(),
          if (paymentMethod == PaymentMethod.cod)
            'paymentStatus': PaymentStatus.paid.name,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> markPaymentPaid(String orderId) async {
    try {
      final snapshot =
          await _firestoreService.doc(CollectionPaths.orders, orderId).get();
      if (!snapshot.exists) {
        return const FailureResult(ServerFailure('Order not found'));
      }

      final status = OrderStatus.fromString(
        snapshot.data()?['status'] as String? ?? '',
      );
      if (status == OrderStatus.cancelled || status == OrderStatus.failed) {
        return const FailureResult(
          ServerFailure('Cannot mark cancelled/failed orders as paid'),
        );
      }

      await _firestoreService.updateDoc(
        CollectionPaths.orders,
        orderId,
        {
          'paymentStatus': PaymentStatus.paid.name,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> cancelOrder({
    required String orderId,
    required String cancelledById,
    required String cancelledByName,
    required String cancelledByRole,
    String? reason,
  }) async {
    try {
      final snapshot =
          await _firestoreService.doc(CollectionPaths.orders, orderId).get();
      if (!snapshot.exists) {
        return const FailureResult(ServerFailure('Order not found'));
      }

      final data = snapshot.data() ?? {};
      final status = OrderStatus.fromString(data['status'] as String? ?? '');
      if (!status.isOpen) {
        return const FailureResult(
          ServerFailure('Order is already closed'),
        );
      }

      final isCustomer = cancelledByRole == AppRole.customer.name;
      if (isCustomer) {
        if (!status.canCustomerCancel) {
          return const FailureResult(
            ServerFailure(
              'You can no longer cancel once the rider has arrived',
            ),
          );
        }
        if (data['customerId'] != cancelledById) {
          return const FailureResult(
            ServerFailure('You can only cancel your own order'),
          );
        }
      }

      final trimmedReason = reason?.trim();
      final defaultReason = isCustomer
          ? 'Cancelled by customer'
          : 'Cancelled by $cancelledByRole';

      await _firestoreService.updateDoc(
        CollectionPaths.orders,
        orderId,
        {
          'status': OrderStatus.cancelled.name,
          // Cancelled orders remain unpaid.
          'paymentStatus': PaymentStatus.pending.name,
          'cancelledAt': FieldValue.serverTimestamp(),
          'cancelledById': cancelledById,
          'cancelledByName': cancelledByName,
          'cancelledByRole': cancelledByRole,
          'failureReason':
              (trimmedReason == null || trimmedReason.isEmpty)
                  ? defaultReason
                  : trimmedReason,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }
}
