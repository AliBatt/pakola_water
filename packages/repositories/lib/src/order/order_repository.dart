import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:services/services.dart';

abstract class OrderRepository {
  Future<Result<DeliveryOrder>> createOrder(DeliveryOrder order);
  Stream<List<DeliveryOrder>> watchCustomerOrders(String customerId);
  Stream<DeliveryOrder?> watchActiveOrder(String customerId);
  Future<Result<void>> confirmDelivery(String orderId);
  Future<Result<bool>> hasActiveOrder(String customerId);
}

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._orderService);

  final OrderService _orderService;

  @override
  Future<Result<DeliveryOrder>> createOrder(DeliveryOrder order) {
    return _orderService.createOrder(order);
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
  Future<Result<void>> confirmDelivery(String orderId) {
    return _orderService.confirmDelivery(orderId);
  }

  @override
  Future<Result<bool>> hasActiveOrder(String customerId) {
    return _orderService.hasActiveOrder(customerId);
  }
}
