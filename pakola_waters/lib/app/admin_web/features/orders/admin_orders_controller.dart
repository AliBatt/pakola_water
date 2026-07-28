import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';

import '../../../../shared/orders/others_date_preset.dart';

class AdminOrdersController extends ChangeNotifier {
  AdminOrdersController({
    required OrderRepository orderRepository,
    required BranchRepository branchRepository,
    required UserRepository userRepository,
  })  : _orderRepository = orderRepository,
        _branchRepository = branchRepository,
        _userRepository = userRepository;

  final OrderRepository _orderRepository;
  final BranchRepository _branchRepository;
  final UserRepository _userRepository;

  List<DeliveryOrder> _orders = [];
  List<Branch> _branches = [];
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
    _loadBranches();
    _loadSupervisors();
  }

  Future<void> refresh() async {
    _ordersSub?.cancel();
    _ordersSub = _orderRepository.watchAllOrders().listen((orders) {
      _orders = orders;
      notifyListeners();
    });
    await Future.wait([_loadBranches(), _loadSupervisors()]);
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
      _supervisorNames = {
        for (final user in value) user.id: user.displayName,
      };
      notifyListeners();
    }
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
