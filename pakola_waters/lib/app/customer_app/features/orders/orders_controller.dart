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
    String? note,
  }) async {
    final user = _user;
    if (user == null) {
      return const FailureResult(AuthFailure('Not signed in'));
    }
    if (user.primaryBranchId == null || user.primaryBranchId!.isEmpty) {
      return const FailureResult(ServerFailure('No branch selected on profile'));
    }
    if (quantity < 1) {
      return const FailureResult(ServerFailure('Quantity must be at least 1'));
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final unitPrice = product.effectivePrice;
    final branch = branchFor(user.primaryBranchId!);
    final order = DeliveryOrder(
      id: '',
      customerId: user.id,
      customerName: user.displayName,
      customerPhone: user.phone,
      branchId: user.primaryBranchId!,
      branchName: branch?.name,
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: unitPrice * quantity,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      paymentMethod: paymentMethod,
      status: OrderStatus.pending,
      deliveryAddress: user.address,
      deliveryLocation: user.location,
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
