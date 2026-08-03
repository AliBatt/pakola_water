import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';
import 'package:utilities/utilities.dart';

import '../../../../shared/orders/others_date_preset.dart';

class AdminOrdersController extends ChangeNotifier {
  AdminOrdersController({
    required OrderRepository orderRepository,
    required BranchRepository branchRepository,
    required UserRepository userRepository,
    required ProductRepository productRepository,
    required NotificationRepository notificationRepository,
  })  : _orderRepository = orderRepository,
        _branchRepository = branchRepository,
        _userRepository = userRepository,
        _productRepository = productRepository,
        _notificationRepository = notificationRepository;

  final OrderRepository _orderRepository;
  final BranchRepository _branchRepository;
  final UserRepository _userRepository;
  final ProductRepository _productRepository;
  final NotificationRepository _notificationRepository;

  List<DeliveryOrder> _orders = [];
  List<Branch> _branches = [];
  List<AppUser> _customers = [];
  List<AppUser> _supervisors = [];
  List<AppUser> _riders = [];
  List<Product> _products = [];
  Map<String, String> _supervisorNames = {};
  String _search = '';
  OthersDatePreset _datePreset = OthersDatePreset.all;
  DateTimeRange? _customRange;
  OrderStatus? _statusFilter;
  String? _branchFilter;
  bool _isActing = false;
  String? _error;
  bool _bound = false;
  StreamSubscription<List<DeliveryOrder>>? _ordersSub;

  List<DeliveryOrder> get orders => _orders;
  List<Branch> get branches => _branches;
  List<AppUser> get customers => _customers;
  List<AppUser> get supervisors => _supervisors
      .where((u) => u.status == UserStatus.active)
      .toList();
  List<AppUser> get riders =>
      _riders.where((u) => u.status == UserStatus.active).toList();
  List<Product> get products => _products
      .where((p) => p.status == ProductStatus.active)
      .toList();
  String get search => _search;
  OthersDatePreset get datePreset => _datePreset;
  DateTimeRange? get customRange => _customRange;
  OrderStatus? get statusFilter => _statusFilter;
  String? get branchFilter => _branchFilter;
  bool get isActing => _isActing;
  String? get error => _error;
  bool get isLoading => !_bound || (_ordersSub == null && _orders.isEmpty);

  int get totalCount => filteredOrders.length;
  int get activeCount =>
      filteredOrders.where((o) => o.status.isActive).length;
  int get deliveredCount =>
      filteredOrders.where((o) => o.status == OrderStatus.delivered).length;
  int get failedCount =>
      filteredOrders.where((o) => o.status == OrderStatus.failed).length;

  List<DeliveryOrder> get filteredOrders {
    final query = _search.trim().toLowerCase();
    return _orders.where((order) {
      if (_branchFilter != null && order.branchId != _branchFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final haystack = [
          order.customerName,
          order.customerId,
          order.customerPhone ?? '',
          order.riderName ?? '',
          order.supervisorName ?? supervisorNameFor(order),
          order.productName,
          order.branchName ?? '',
          order.id,
        ].join(' ').toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      if (_statusFilter != null && order.status != _statusFilter) {
        return false;
      }
      final created = order.createdAtDate;
      if (created == null) return _datePreset == OthersDatePreset.all;
      final range = _dateRange();
      if (range == null) return true;
      return !created.isBefore(range.start) && !created.isAfter(range.end);
    }).toList()
      ..sort((a, b) {
        final aDate =
            a.createdAtDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.createdAtDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
  }

  String supervisorNameFor(DeliveryOrder order) {
    if (order.supervisorName != null && order.supervisorName!.isNotEmpty) {
      return order.supervisorName!;
    }
    final id = order.supervisorId;
    if (id == null) return '—';
    return _supervisorNames[id] ?? id;
  }

  void bind() {
    if (_bound) return;
    _bound = true;
    _ordersSub?.cancel();
    _ordersSub = _orderRepository.watchAllOrders().listen((orders) {
      _orders = orders;
      notifyListeners();
    });
    _loadLookups();
  }

  Future<void> refresh() async {
    _ordersSub?.cancel();
    _ordersSub = _orderRepository.watchAllOrders().listen((orders) {
      _orders = orders;
      notifyListeners();
    });
    await _loadLookups();
  }

  Future<void> _loadLookups() async {
    await Future.wait([
      _loadBranches(),
      _loadSupervisors(),
      _loadCustomers(),
      _loadRiders(),
      _loadProducts(),
    ]);
  }

  Future<void> _loadBranches() async {
    final result = await _branchRepository.listBranches();
    if (result case Success<List<Branch>>(:final value)) {
      _branches = value;
      notifyListeners();
    }
  }

  Future<void> _loadSupervisors() async {
    final result = await _userRepository.listByRole(AppRole.supervisor);
    if (result case Success<List<AppUser>>(:final value)) {
      _supervisors = value;
      _supervisorNames = {
        for (final user in value) user.id: user.displayName,
      };
      notifyListeners();
    }
  }

  Future<void> _loadCustomers() async {
    final result = await _userRepository.listByRole(AppRole.customer);
    if (result case Success<List<AppUser>>(:final value)) {
      _customers = value
        ..sort((a, b) => a.displayName.compareTo(b.displayName));
      notifyListeners();
    }
  }

  Future<void> _loadRiders() async {
    final result = await _userRepository.listByRole(AppRole.driver);
    if (result case Success<List<AppUser>>(:final value)) {
      _riders = value;
      notifyListeners();
    }
  }

  Future<void> _loadProducts() async {
    final result = await _productRepository.listProducts();
    if (result case Success<List<Product>>(:final value)) {
      _products = value
        ..sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    }
  }

  List<AppUser> supervisorsForBranch(String? branchId) {
    final list = supervisors;
    if (branchId == null || branchId.isEmpty) return list;
    return list.where((user) {
      return user.primaryBranchId == branchId ||
          user.branchIds.contains(branchId);
    }).toList();
  }

  List<AppUser> ridersForBranch(String? branchId) {
    final list = riders;
    if (branchId == null || branchId.isEmpty) return list;
    return list.where((user) {
      return user.primaryBranchId == branchId ||
          user.branchIds.contains(branchId);
    }).toList();
  }

  Branch? branchById(String? id) {
    if (id == null) return null;
    for (final branch in _branches) {
      if (branch.id == id) return branch;
    }
    return null;
  }

  Future<Result<DeliveryOrder>> createManualOrder({
    required AppUser admin,
    required AppUser customer,
    required Product product,
    required Branch branch,
    required AppUser supervisor,
    required AppUser rider,
    required int quantity,
    required PaymentMethod paymentMethod,
    required DateTime estimatedArrivalAt,
    String? note,
    String? deliveryAddress,
  }) async {
    if (quantity < 1) {
      return const FailureResult(ServerFailure('Quantity must be at least 1'));
    }
    if (estimatedArrivalAt.isBefore(DateTime.now())) {
      return const FailureResult(
        ServerFailure('ETA must be in the future'),
      );
    }

    _isActing = true;
    _error = null;
    notifyListeners();

    final unitPrice = product.effectivePrice;
    final order = DeliveryOrder(
      id: '',
      customerId: customer.id,
      customerName: customer.displayName,
      customerPhone: customer.phone,
      branchId: branch.id,
      branchName: branch.name,
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: unitPrice * quantity,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      paymentMethod: paymentMethod,
      status: OrderStatus.assigned,
      deliveryAddress: (deliveryAddress ?? customer.address)?.trim().isEmpty ==
              true
          ? null
          : (deliveryAddress ?? customer.address)?.trim(),
      deliveryLocation: customer.location,
      adminNotes: 'Manual order created by ${admin.displayName}',
      adminActionById: admin.id,
      adminActionByName: admin.displayName,
    );

    final result = await _orderRepository.createManualOrder(
      order: order,
      createdByAdminId: admin.id,
      supervisorId: supervisor.id,
      supervisorName: supervisor.displayName,
      riderId: rider.id,
      riderName: rider.displayName,
      estimatedArrivalAt: estimatedArrivalAt,
    );

    if (result case Success<DeliveryOrder>(:final value)) {
      final etaLabel = DateTimeFormatter.formatDateTime(estimatedArrivalAt);
      await _notificationRepository.createNotification(
        AppNotification(
          id: '',
          userId: rider.id,
          title: 'New delivery assigned',
          body:
              '${product.name} x$quantity for ${customer.displayName}. ETA $etaLabel (manual order)',
          createdById: admin.id,
          createdByRole: admin.role.name,
          createdByName: admin.displayName,
          type: 'order_assigned',
          orderId: value.id,
        ),
      );
      await _notificationRepository.createNotification(
        AppNotification(
          id: '',
          userId: supervisor.id,
          title: 'Manual order created',
          body:
              '${product.name} x$quantity for ${customer.displayName} assigned to ${rider.displayName}',
          createdById: admin.id,
          createdByRole: admin.role.name,
          createdByName: admin.displayName,
          type: 'order_assigned',
          orderId: value.id,
        ),
      );
      await _notificationRepository.createNotification(
        AppNotification(
          id: '',
          userId: customer.id,
          title: 'Order created',
          body:
              'Your order for ${product.name} x$quantity was placed by admin. Rider: ${rider.displayName}. ETA $etaLabel',
          createdById: admin.id,
          createdByRole: admin.role.name,
          createdByName: admin.displayName,
          type: 'order_assigned',
          orderId: value.id,
        ),
      );
    } else if (result case FailureResult<DeliveryOrder>(:final failure)) {
      _error = failure.message;
    }

    _isActing = false;
    notifyListeners();
    return result;
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setDatePreset(OthersDatePreset preset) {
    _datePreset = preset;
    notifyListeners();
  }

  void setCustomRange(DateTimeRange? range) {
    _customRange = range;
    _datePreset = OthersDatePreset.custom;
    notifyListeners();
  }

  void setStatusFilter(OrderStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setBranchFilter(String? branchId) {
    _branchFilter = branchId;
    notifyListeners();
  }

  Future<Result<void>> markDelivered({
    required DeliveryOrder order,
    required AppUser admin,
    String? adminNotes,
  }) async {
    _isActing = true;
    _error = null;
    notifyListeners();

    final result = await _orderRepository.adminMarkDelivered(
      orderId: order.id,
      adminId: admin.id,
      adminName: admin.displayName,
      adminNotes: adminNotes,
    );

    if (result case FailureResult(:final failure)) {
      _error = failure.message;
    }
    _isActing = false;
    notifyListeners();
    return result;
  }

  Future<Result<void>> markFailed({
    required DeliveryOrder order,
    required AppUser admin,
    required String failureReason,
    String? adminNotes,
  }) async {
    _isActing = true;
    _error = null;
    notifyListeners();

    final result = await _orderRepository.adminMarkFailed(
      orderId: order.id,
      adminId: admin.id,
      adminName: admin.displayName,
      failureReason: failureReason,
      adminNotes: adminNotes,
    );

    if (result case FailureResult(:final failure)) {
      _error = failure.message;
    }
    _isActing = false;
    notifyListeners();
    return result;
  }

  Future<Result<void>> saveNotes({
    required DeliveryOrder order,
    required String adminNotes,
  }) {
    return _orderRepository.adminUpdateNotes(
      orderId: order.id,
      adminNotes: adminNotes,
    );
  }

  Future<Result<void>> cancelOrder({
    required DeliveryOrder order,
    required AppUser admin,
    required String reason,
    String? adminNotes,
  }) async {
    if (!order.status.isActive) {
      return const FailureResult(ServerFailure('Order is already closed'));
    }

    _isActing = true;
    _error = null;
    notifyListeners();

    final result = await _orderRepository.cancelOrder(
      orderId: order.id,
      cancelledById: admin.id,
      cancelledByName: admin.displayName,
      cancelledByRole: admin.role.name,
      reason: reason.trim().isEmpty ? 'Cancelled by admin' : reason.trim(),
    );

    if (result case Success()) {
      final notes = adminNotes?.trim();
      if (notes != null && notes.isNotEmpty) {
        await _orderRepository.adminUpdateNotes(
          orderId: order.id,
          adminNotes: notes,
        );
      }
    } else if (result case FailureResult(:final failure)) {
      _error = failure.message;
    }

    _isActing = false;
    notifyListeners();
    return result;
  }

  DateTimeRange? _dateRange() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    switch (_datePreset) {
      case OthersDatePreset.all:
        return null;
      case OthersDatePreset.today:
        return DateTimeRange(start: todayStart, end: now);
      case OthersDatePreset.yesterday:
        final start = todayStart.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: start,
          end: start.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
        );
      case OthersDatePreset.week:
        final weekday = now.weekday;
        final start = todayStart.subtract(Duration(days: weekday - 1));
        return DateTimeRange(start: start, end: now);
      case OthersDatePreset.month:
        final start = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: start, end: now);
      case OthersDatePreset.custom:
        return _customRange;
    }
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }
}
