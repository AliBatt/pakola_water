import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';

class OrdersController extends ChangeNotifier {
  OrdersController({
    required OrderRepository orderRepository,
    required BranchRepository branchRepository,
    required OrderMessageRepository orderMessageRepository,
  })  : _orderRepository = orderRepository,
        _branchRepository = branchRepository,
        _orderMessageRepository = orderMessageRepository;

  final OrderRepository _orderRepository;
  final BranchRepository _branchRepository;
  final OrderMessageRepository _orderMessageRepository;

  AppUser? _user;
  DeliveryOrder? _activeOrder;
  List<DeliveryOrder> _orders = [];
  List<Branch> _branches = [];
  bool _isSubmitting = false;
  String? _error;
  StreamSubscription<DeliveryOrder?>? _activeSub;
  StreamSubscription<List<DeliveryOrder>>? _ordersSub;

  DeliveryOrder? get activeOrder => _activeOrder;
  List<DeliveryOrder> get orders => _orders;
  List<Branch> get branches => _branches;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  bool get hasActiveOrder => _activeOrder != null;

  /// Ongoing instant + activated scheduled (excludes parked scheduled holds).
  List<DeliveryOrder> get activeOrders =>
      _orders.where((order) => order.status.isActive).toList();

  bool get hasOpenInstantOrder => _orders.any(
        (order) =>
            order.status.isOpen && order.orderType == OrderType.instant,
      );

  bool get hasOpenScheduledOrder => _orders.any(
        (order) =>
            order.status.isOpen && order.orderType == OrderType.scheduled,
      );

  /// True when at least one of instant/scheduled slots is free.
  bool get canPlaceOrder => !hasOpenInstantOrder || !hasOpenScheduledOrder;

  DeliveryOrder? get openScheduledOrder {
    for (final order in _orders) {
      if (order.status.isScheduledHold) return order;
    }
    return null;
  }

  Branch? branchFor(String branchId) {
    for (final branch in _branches) {
      if (branch.id == branchId) return branch;
    }
    return null;
  }

  void bindUser(AppUser? user) {
    if (user?.id == _user?.id) return;
    _user = user;
    _activeSub?.cancel();
    _ordersSub?.cancel();
    _activeOrder = null;
    _orders = [];

    if (user == null) {
      notifyListeners();
      return;
    }

    _subscribeToOrders(user.id);
    _loadBranches();
  }

  void _subscribeToOrders(String userId) {
    _activeSub = _orderRepository.watchActiveOrder(userId).listen((order) {
      _activeOrder = order;
      notifyListeners();
    });
    _ordersSub = _orderRepository.watchCustomerOrders(userId).listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    final userId = _user?.id;
    if (userId == null) return;

    _activeSub?.cancel();
    _ordersSub?.cancel();
    _subscribeToOrders(userId);
    await _loadBranches();
  }

  Future<void> _loadBranches() async {
    final result = await _branchRepository.listBranches();
    if (result case Success<List<Branch>>(:final value)) {
      _branches = value;
      notifyListeners();
    }
  }

  Future<Result<DeliveryOrder>> placeOrder({
    required Product product,
    required int quantity,
    required PaymentMethod paymentMethod,
    required String branchId,
    required String deliveryAddress,
    required GeoLocation deliveryLocation,
    bool isCustomDeliveryLocation = false,
    OrderType orderType = OrderType.instant,
    DateTime? scheduledFor,
    String? note,
  }) async {
    final user = _user;
    if (user == null) {
      return const FailureResult(AuthFailure('Not signed in'));
    }
    if (branchId.isEmpty) {
      return const FailureResult(ServerFailure('Select a branch'));
    }
    if (deliveryAddress.trim().isEmpty) {
      return const FailureResult(ServerFailure('Delivery address is required'));
    }
    if (quantity < 1) {
      return const FailureResult(ServerFailure('Quantity must be at least 1'));
    }
    if (orderType == OrderType.scheduled) {
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

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final unitPrice = product.effectivePrice;
    final branch = branchFor(branchId);
    final isScheduled = orderType == OrderType.scheduled;
    final order = DeliveryOrder(
      id: '',
      customerId: user.id,
      customerName: user.displayName,
      customerPhone: user.phone,
      branchId: branchId,
      branchName: branch?.name,
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: unitPrice * quantity,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      paymentMethod: paymentMethod,
      status: isScheduled ? OrderStatus.scheduled : OrderStatus.pending,
      orderType: orderType,
      scheduledFor: scheduledFor?.toIso8601String(),
      deliveryAddress: deliveryAddress.trim(),
      deliveryLocation: deliveryLocation,
      isCustomDeliveryLocation: isCustomDeliveryLocation,
    );

    final result = await _orderRepository.createOrder(order);
    if (result case FailureResult(:final failure)) {
      _error = failure.message;
    }

    _isSubmitting = false;
    notifyListeners();
    return result;
  }

  Future<Result<void>> confirmDelivery(String orderId) {
    return _orderRepository.confirmDelivery(orderId);
  }

  Future<Result<void>> cancelOrder({
    required DeliveryOrder order,
    String? reason,
  }) async {
    final user = _user;
    if (user == null) {
      return const FailureResult(AuthFailure('Not signed in'));
    }
    if (!order.status.canCustomerCancel) {
      return const FailureResult(
        ServerFailure(
          'You can no longer cancel once the rider has arrived',
        ),
      );
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _orderRepository.cancelOrder(
      orderId: order.id,
      cancelledById: user.id,
      cancelledByName: user.displayName,
      cancelledByRole: user.role.name,
      reason: reason?.trim().isEmpty == true
          ? 'Cancelled by customer'
          : reason?.trim(),
    );

    if (result case FailureResult(:final failure)) {
      _error = failure.message;
    }

    _isSubmitting = false;
    notifyListeners();
    return result;
  }

  Stream<List<OrderMessage>> watchOrderMessages(String orderId) {
    return _orderMessageRepository.watchMessages(orderId);
  }

  Future<Result<OrderMessage>> sendOrderMessage({
    required DeliveryOrder order,
    required String message,
    OrderMessageType type = OrderMessageType.customerMessage,
  }) {
    final user = _user;
    if (user == null) {
      return Future.value(const FailureResult(AuthFailure('Not signed in')));
    }
    return _orderMessageRepository.sendCustomerMessage(
      order: order,
      customer: user,
      message: message,
      type: type,
    );
  }

  @override
  void dispose() {
    _activeSub?.cancel();
    _ordersSub?.cancel();
    super.dispose();
  }
}
