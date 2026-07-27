import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';
import 'package:utilities/utilities.dart';

import '../../../../shared/orders/others_date_preset.dart';

class SupervisorOrdersController extends ChangeNotifier {
  SupervisorOrdersController({
    required OrderRepository orderRepository,
    required UserRepository userRepository,
    required NotificationRepository notificationRepository,
  })  : _orderRepository = orderRepository,
        _userRepository = userRepository,
        _notificationRepository = notificationRepository;

  final OrderRepository _orderRepository;
  final UserRepository _userRepository;
  final NotificationRepository _notificationRepository;

  AppUser? _supervisor;
  List<DeliveryOrder> _orders = [];
  List<AppUser> _riders = [];
  DateTimeRange _statsRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 0)).copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    ),
    end: DateTime.now(),
  );
  bool _isAssigning = false;
  String? _error;
  StreamSubscription<List<DeliveryOrder>>? _ordersSub;

  List<DeliveryOrder> get orders => _orders;
  DateTimeRange get statsRange => _statsRange;
  bool get isAssigning => _isAssigning;
  String? get error => _error;

  String? get branchId => _supervisor?.primaryBranchId;

  List<DeliveryOrder> get requestedOrders =>
      _orders.where((o) => o.status.isRequested).toList();

  String _othersSearch = '';
  OthersDatePreset _othersDatePreset = OthersDatePreset.all;
  DateTimeRange? _othersCustomRange;
  OrderStatus? _othersStatusFilter;

  String get othersSearch => _othersSearch;
  OthersDatePreset get othersDatePreset => _othersDatePreset;
  DateTimeRange? get othersCustomRange => _othersCustomRange;
  OrderStatus? get othersStatusFilter => _othersStatusFilter;

  List<DeliveryOrder> get filteredOthersOrders {
    final query = _othersSearch.trim().toLowerCase();
    return _orders.where((order) {
      if (query.isNotEmpty) {
        final customer = order.customerName.toLowerCase();
        final rider = (order.riderName ?? '').toLowerCase();
        if (!customer.contains(query) && !rider.contains(query)) {
          return false;
        }
      }

      if (_othersStatusFilter != null && order.status != _othersStatusFilter) {
        return false;
      }

      final created = _parseDate(order.createdAt);
      if (created == null) return _othersDatePreset == OthersDatePreset.all;

      final range = _othersDateRange();
      if (range == null) return true;
      return !created.isBefore(range.start) && !created.isAfter(range.end);
    }).toList()
      ..sort((a, b) {
        final aDate = _parseDate(a.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = _parseDate(b.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
  }

  DateTimeRange? _othersDateRange() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    switch (_othersDatePreset) {
      case OthersDatePreset.all:
        return null;
      case OthersDatePreset.today:
        return DateTimeRange(
          start: todayStart,
          end: now,
        );
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
        return _othersCustomRange;
    }
  }

  void setOthersSearch(String value) {
    _othersSearch = value;
    notifyListeners();
  }

  void setOthersDatePreset(OthersDatePreset preset) {
    _othersDatePreset = preset;
    notifyListeners();
  }

  void setOthersCustomRange(DateTimeRange? range) {
    _othersCustomRange = range;
    _othersDatePreset = OthersDatePreset.custom;
    notifyListeners();
  }

  void setOthersStatusFilter(OrderStatus? status) {
    _othersStatusFilter = status;
    notifyListeners();
  }

  int get newOrderCount => requestedOrders.length;

  List<DeliveryOrder> get ordersInStatsRange {
    return _orders.where((order) {
      final created = _parseDate(order.createdAt);
      if (created == null) return false;
      return !created.isBefore(_statsRange.start) &&
          !created.isAfter(_statsRange.end);
    }).toList();
  }

  int get todayOrderCount {
    final start = DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
    return _orders.where((order) {
      final created = _parseDate(order.createdAt);
      return created != null && !created.isBefore(start);
    }).length;
  }

  int get statsTotalOrders => ordersInStatsRange.length;

  int get statsCompletedOrders =>
      ordersInStatsRange.where((o) => o.status.isCompleted).length;

  int get statsPendingOrders =>
      ordersInStatsRange.where((o) => o.status.isRequested).length;

  int get statsInProgressOrders =>
      ordersInStatsRange.where((o) => o.status.isInProgress).length;

  double get statsRevenue => ordersInStatsRange.fold(
        0,
        (sum, order) => sum + order.lineTotal,
      );

  List<AppUser> ridersForBranch({required bool myBranch}) {
    final branch = branchId;
    if (branch == null) return [];
    return _riders.where((rider) {
      final inBranch = rider.branchIds.contains(branch);
      return myBranch ? inBranch : !inBranch;
    }).toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
  }

  void bindSupervisor(AppUser? supervisor) {
    if (supervisor?.id == _supervisor?.id) return;
    _supervisor = supervisor;
    _ordersSub?.cancel();
    _orders = [];

    if (supervisor == null || supervisor.primaryBranchId == null) {
      notifyListeners();
      return;
    }

    _subscribe(supervisor.primaryBranchId!);
    _loadRiders();
  }

  void _subscribe(String branchId) {
    _ordersSub = _orderRepository.watchBranchOrders(branchId).listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  Future<void> _loadRiders() async {
    final result = await _userRepository.listByRole(AppRole.driver);
    if (result case Success<List<AppUser>>(:final value)) {
      _riders = value.where((r) => r.status == UserStatus.active).toList();
      notifyListeners();
    }
  }

  void setStatsRange(DateTimeRange range) {
    _statsRange = range;
    notifyListeners();
  }

  Future<void> refresh() async {
    final branch = branchId;
    if (branch == null) return;
    _ordersSub?.cancel();
    _subscribe(branch);
    await _loadRiders();
  }

  Future<Result<void>> assignOrder({
    required DeliveryOrder order,
    required AppUser rider,
    required DateTime estimatedArrivalAt,
  }) async {
    final supervisor = _supervisor;
    if (supervisor == null) {
      return const FailureResult(AuthFailure('Not signed in'));
    }

    _isAssigning = true;
    _error = null;
    notifyListeners();

    final assignResult = await _orderRepository.assignToRider(
      orderId: order.id,
      supervisorId: supervisor.id,
      supervisorName: supervisor.displayName,
      riderId: rider.id,
      riderName: rider.displayName,
      estimatedArrivalAt: estimatedArrivalAt,
    );

    if (assignResult case FailureResult(:final failure)) {
      _error = failure.message;
      _isAssigning = false;
      notifyListeners();
      return assignResult;
    }

    final etaLabel = DateTimeFormatter.formatTime(estimatedArrivalAt);
    await _notificationRepository.createNotification(
      AppNotification(
        id: '',
        userId: rider.id,
        title: 'New delivery assigned',
        body:
            '${order.productName} x${order.quantity} for ${order.customerName}. ETA $etaLabel',
        createdById: supervisor.id,
        createdByRole: supervisor.role.name,
        createdByName: supervisor.displayName,
        type: 'order_assigned',
        orderId: order.id,
      ),
    );

    await _notificationRepository.createNotification(
      AppNotification(
        id: '',
        userId: order.customerId,
        title: 'Rider assigned',
        body:
            '${rider.displayName} is delivering your order. Estimated arrival $etaLabel',
        createdById: supervisor.id,
        createdByRole: supervisor.role.name,
        createdByName: supervisor.displayName,
        type: 'order_assigned',
        orderId: order.id,
      ),
    );

    _isAssigning = false;
    notifyListeners();
    await refresh();
    return const Success(null);
  }

  DateTime? _parseDate(String? value) => DateTimeFormatter.parse(value);

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }
}
