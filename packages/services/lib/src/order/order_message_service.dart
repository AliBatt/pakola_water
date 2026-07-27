import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:models/models.dart';

import '../notification/notification_service.dart';
import '../user/user_service.dart';

abstract class OrderMessageService {
  Stream<List<OrderMessage>> watchMessages(String orderId);
  Future<Result<OrderMessage>> sendCustomerMessage({
    required DeliveryOrder order,
    required AppUser customer,
    required String message,
    OrderMessageType type,
  });
  Future<Result<OrderMessage>> sendStaffMessage({
    required DeliveryOrder order,
    required AppUser sender,
    required String message,
    required String recipientUserId,
  });
}

class OrderMessageServiceImpl implements OrderMessageService {
  OrderMessageServiceImpl(
    this._firestoreService,
    this._notificationService,
    this._userService,
  );

  final FirestoreService _firestoreService;
  final NotificationService _notificationService;
  final UserService _userService;

  static const _messagesSubcollection = 'messages';

  OrderMessage _mapDoc(
    String orderId,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = doc.id;
    data['orderId'] = orderId;
    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) {
      data['createdAt'] = createdAt.toDate().toIso8601String();
    }
    return OrderMessage.fromJson(data);
  }

  @override
  Stream<List<OrderMessage>> watchMessages(String orderId) {
    return _firestoreService
        .subcollection(CollectionPaths.orders, orderId, _messagesSubcollection)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _mapDoc(orderId, doc)).toList());
  }

  @override
  Future<Result<OrderMessage>> sendCustomerMessage({
    required DeliveryOrder order,
    required AppUser customer,
    required String message,
    OrderMessageType type = OrderMessageType.customerMessage,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return const FailureResult(ServerFailure('Message cannot be empty'));
    }

    if (type == OrderMessageType.review) {
      if (order.status != OrderStatus.delivered) {
        return const FailureResult(
          ServerFailure('Reviews are only allowed after delivery'),
        );
      }
    } else if (!order.status.isActive) {
      return const FailureResult(
        ServerFailure('You can only message while the order is active'),
      );
    }

    try {
      final docRef = _firestoreService
          .subcollection(CollectionPaths.orders, order.id, _messagesSubcollection)
          .doc();
      final data = {
        'orderId': order.id,
        'message': trimmed,
        'type': type.name,
        'createdById': customer.id,
        'createdByName': customer.displayName,
        'createdByRole': customer.role.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await docRef.set(data);

      final saved = OrderMessage(
        id: docRef.id,
        orderId: order.id,
        message: trimmed,
        type: type,
        createdById: customer.id,
        createdByName: customer.displayName,
        createdByRole: customer.role.name,
      );

      await _notifyBranchStaff(
        order: order,
        sender: customer,
        title: type == OrderMessageType.review
            ? 'Customer review'
            : 'Customer message',
        body: '${customer.displayName}: $trimmed',
        notificationType: type == OrderMessageType.review
            ? 'order_review'
            : 'order_message',
      );

      return Success(saved);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<OrderMessage>> sendStaffMessage({
    required DeliveryOrder order,
    required AppUser sender,
    required String message,
    required String recipientUserId,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return const FailureResult(ServerFailure('Message cannot be empty'));
    }

    try {
      final docRef = _firestoreService
          .subcollection(CollectionPaths.orders, order.id, _messagesSubcollection)
          .doc();
      final data = {
        'orderId': order.id,
        'message': trimmed,
        'type': OrderMessageType.staffMessage.name,
        'createdById': sender.id,
        'createdByName': sender.displayName,
        'createdByRole': sender.role.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await docRef.set(data);

      await _notificationService.createNotification(
        AppNotification(
          id: '',
          userId: recipientUserId,
          title: 'Message about your order',
          body: '${sender.displayName}: $trimmed',
          createdById: sender.id,
          createdByRole: sender.role.name,
          createdByName: sender.displayName,
          type: 'staff_message',
          orderId: order.id,
        ),
      );

      return Success(
        OrderMessage(
          id: docRef.id,
          orderId: order.id,
          message: trimmed,
          type: OrderMessageType.staffMessage,
          createdById: sender.id,
          createdByName: sender.displayName,
          createdByRole: sender.role.name,
        ),
      );
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  Future<void> _notifyBranchStaff({
    required DeliveryOrder order,
    required AppUser sender,
    required String title,
    required String body,
    required String notificationType,
  }) async {
    final supervisorsResult =
        await _userService.listByRole(AppRole.supervisor);
    if (supervisorsResult case Success<List<AppUser>>(:final value)) {
      for (final supervisor in value) {
        if (supervisor.primaryBranchId != order.branchId) continue;
        await _notificationService.createNotification(
          AppNotification(
            id: '',
            userId: supervisor.id,
            title: title,
            body: body,
            createdById: sender.id,
            createdByRole: sender.role.name,
            createdByName: sender.displayName,
            type: notificationType,
            orderId: order.id,
          ),
        );
      }
    }

    if (order.riderId != null) {
      await _notificationService.createNotification(
        AppNotification(
          id: '',
          userId: order.riderId!,
          title: title,
          body: body,
          createdById: sender.id,
          createdByRole: sender.role.name,
          createdByName: sender.displayName,
          type: notificationType,
          orderId: order.id,
        ),
      );
    }
  }
}
