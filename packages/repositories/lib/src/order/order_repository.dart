import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:services/services.dart';

abstract class OrderRepository {
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

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._orderService);

  final OrderService _orderService;

  @override
  Future<Result<DeliveryOrder>> createOrder(DeliveryOrder order) {
    return _orderService.createOrder(order);
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
  }) {
    return _orderService.createManualOrder(
      order: order,
      createdByAdminId: createdByAdminId,
      supervisorId: supervisorId,
      supervisorName: supervisorName,
      riderId: riderId,
      riderName: riderName,
      estimatedArrivalAt: estimatedArrivalAt,
    );
  }

  @override
  Stream<List<DeliveryOrder>> watchCustomerOrders(String customerId) {
    return _orderService.watchCustomerOrders(customerId);
  }

  @override
  Stream<DeliveryOrder?> watchActiveOrder(String customerId) {
    return _orderService.watchActiveOrder(customerId);
  }

  @override
  Stream<List<DeliveryOrder>> watchBranchOrders(String branchId) {
    return _orderService.watchBranchOrders(branchId);
  }

  @override
  Stream<List<DeliveryOrder>> watchAllOrders() {
    return _orderService.watchAllOrders();
  }

  @override
  Stream<List<DeliveryOrder>> watchRiderOrders(String riderId) {
    return _orderService.watchRiderOrders(riderId);
  }

  @override
  Future<Result<void>> confirmDelivery(String orderId) {
    return _orderService.confirmDelivery(orderId);
  }

  @override
  Future<Result<void>> assignToRider({
    required String orderId,
    required String supervisorId,
    required String supervisorName,
    required String riderId,
    required String riderName,
    required DateTime estimatedArrivalAt,
  }) {
    return _orderService.assignToRider(
      orderId: orderId,
      supervisorId: supervisorId,
      supervisorName: supervisorName,
      riderId: riderId,
      riderName: riderName,
      estimatedArrivalAt: estimatedArrivalAt,
    );
  }

  @override
  Future<Result<void>> adminMarkDelivered({
    required String orderId,
    required String adminId,
    required String adminName,
    String? adminNotes,
  }) {
    return _orderService.adminMarkDelivered(
      orderId: orderId,
      adminId: adminId,
      adminName: adminName,
      adminNotes: adminNotes,
    );
  }

  @override
  Future<Result<void>> adminMarkFailed({
    required String orderId,
    required String adminId,
    required String adminName,
    required String failureReason,
    String? adminNotes,
  }) {
    return _orderService.adminMarkFailed(
      orderId: orderId,
      adminId: adminId,
      adminName: adminName,
      failureReason: failureReason,
      adminNotes: adminNotes,
    );
  }

  @override
  Future<Result<void>> adminUpdateNotes({
    required String orderId,
    required String adminNotes,
  }) {
    return _orderService.adminUpdateNotes(
      orderId: orderId,
      adminNotes: adminNotes,
    );
  }

  @override
  Future<Result<void>> markOutForDelivery(String orderId) {
    return _orderService.markOutForDelivery(orderId);
  }

  @override
  Future<Result<void>> markRiderArrived(String orderId) {
    return _orderService.markRiderArrived(orderId);
  }

  @override
  Future<Result<void>> markPaymentPaid(String orderId) {
    return _orderService.markPaymentPaid(orderId);
  }

  @override
  Future<Result<void>> cancelOrder({
    required String orderId,
    required String cancelledById,
    required String cancelledByName,
    required String cancelledByRole,
    String? reason,
  }) {
    return _orderService.cancelOrder(
      orderId: orderId,
      cancelledById: cancelledById,
      cancelledByName: cancelledByName,
      cancelledByRole: cancelledByRole,
      reason: reason,
    );
  }

  @override
  Future<Result<bool>> hasActiveOrder(String customerId) {
    return _orderService.hasActiveOrder(customerId);
  }

  @override
  Future<Result<bool>> hasOpenOrderOfType({
    required String customerId,
    required OrderType orderType,
  }) {
    return _orderService.hasOpenOrderOfType(
      customerId: customerId,
      orderType: orderType,
    );
  }
}
