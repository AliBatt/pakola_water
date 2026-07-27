import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:services/services.dart';

abstract class OrderMessageRepository {
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

class OrderMessageRepositoryImpl implements OrderMessageRepository {
  OrderMessageRepositoryImpl(this._orderMessageService);

  final OrderMessageService _orderMessageService;

  @override
  Stream<List<OrderMessage>> watchMessages(String orderId) {
    return _orderMessageService.watchMessages(orderId);
  }

  @override
  Future<Result<OrderMessage>> sendCustomerMessage({
    required DeliveryOrder order,
    required AppUser customer,
    required String message,
    OrderMessageType type = OrderMessageType.customerMessage,
  }) {
    return _orderMessageService.sendCustomerMessage(
      order: order,
      customer: customer,
      message: message,
      type: type,
    );
  }

  @override
  Future<Result<OrderMessage>> sendStaffMessage({
    required DeliveryOrder order,
    required AppUser sender,
    required String message,
    required String recipientUserId,
  }) {
    return _orderMessageService.sendStaffMessage(
      order: order,
      sender: sender,
      message: message,
      recipientUserId: recipientUserId,
    );
  }
}
