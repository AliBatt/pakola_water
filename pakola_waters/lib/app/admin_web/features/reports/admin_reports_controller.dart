import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';

import '../../../../shared/orders/others_date_preset.dart';

enum ReportsDateBasis {
  created,
  delivered,
}

enum RiderRankBy {
  deliveries,
  revenue,
}

enum CustomerRankBy {
  revenue,
  orders,
}

class ReportEntityStat {
  const ReportEntityStat({
    required this.id,
    required this.name,
    required this.revenue,
    required this.orderCount,
    required this.deliveredCount,
    required this.failedCount,
    this.avgAssignMs,
    this.avgArriveMs,
    this.avgDeliveryMs,
  });

  final String id;
  final String name;
  final double revenue;
  final int orderCount;
  final int deliveredCount;
  final int failedCount;
  final double? avgAssignMs;
  final double? avgArriveMs;
  final double? avgDeliveryMs;

  Duration? get avgAssignDuration =>
      avgAssignMs == null ? null : Duration(milliseconds: avgAssignMs!.round());

  Duration? get avgArriveDuration =>
      avgArriveMs == null ? null : Duration(milliseconds: avgArriveMs!.round());

  Duration? get avgDeliveryDuration => avgDeliveryMs == null
      ? null
      : Duration(milliseconds: avgDeliveryMs!.round());
}

class RevenuePoint {
  const RevenuePoint({required this.day, required this.revenue, required this.orders});

  final DateTime day;
  final double revenue;
  final int orders;
}

class AdminReportsController extends ChangeNotifier {
  AdminReportsController({
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
  Map<String, String> _riderNames = {};
  OthersDatePreset _datePreset = OthersDatePreset.month;
  DateTimeRange? _customRange;
  String? _branchFilter;
  PaymentMethod? _paymentFilter;
  ReportsDateBasis _dateBasis = ReportsDateBasis.created;
  RiderRankBy _riderRankBy = RiderRankBy.deliveries;
  CustomerRankBy _customerRankBy = CustomerRankBy.revenue;
  bool _bound = false;
  StreamSubscription<List<DeliveryOrder>>? _ordersSub;

  List<DeliveryOrder> get orders => _orders;
  List<Branch> get branches => _branches;
  OthersDatePreset get datePreset => _datePreset;
  DateTimeRange? get customRange => _customRange;
  String? get branchFilter => _branchFilter;
  PaymentMethod? get paymentFilter => _paymentFilter;
  ReportsDateBasis get dateBasis => _dateBasis;
  RiderRankBy get riderRankBy => _riderRankBy;
  CustomerRankBy get customerRankBy => _customerRankBy;
  bool get isLoading => !_bound || (_ordersSub == null && _orders.isEmpty);

  List<DeliveryOrder> get filteredOrders {
    return _orders.where((order) {
      if (_branchFilter != null && order.branchId != _branchFilter) {
        return false;
      }
      if (_paymentFilter != null && order.paymentMethod != _paymentFilter) {
        return false;
      }
      final date = _basisDate(order);
      if (date == null) return _datePreset == OthersDatePreset.all;
      final range = _dateRange();
      if (range == null) return true;
      return !date.isBefore(range.start) && !date.isAfter(range.end);
    }).toList();
  }

  List<DeliveryOrder> get deliveredOrders => filteredOrders
      .where((o) => o.status == OrderStatus.delivered)
      .toList();

  double get totalRevenue =>
      deliveredOrders.fold(0, (sum, o) => sum + o.lineTotal);

  int get totalOrders => filteredOrders.length;
  int get deliveredCount => deliveredOrders.length;
  int get failedCount =>
      filteredOrders.where((o) => o.status == OrderStatus.failed).length;
  int get activeCount =>
      filteredOrders.where((o) => o.status.isActive).length;
  int get cancelledCount =>
      filteredOrders.where((o) => o.status == OrderStatus.cancelled).length;

  Duration? get averageAssignTime {
    final values = filteredOrders
        .map((o) => o.supervisorAssignDuration)
        .whereType<Duration>()
        .toList();
    return _averageDuration(values);
  }

  Duration? get averageArriveTime {
    final values = filteredOrders
        .map(_arriveDuration)
        .whereType<Duration>()
        .toList();
    return _averageDuration(values);
  }

  Duration? get averageDeliveryTime {
    final values = deliveredOrders
        .map((o) => o.totalOrderDuration)
        .whereType<Duration>()
        .toList();
    return _averageDuration(values);
  }

  ReportEntityStat? get topBranch {
    final list = branchStats;
    return list.isEmpty ? null : list.first;
  }

  ReportEntityStat? get topRider {
    final list = riderStats;
    return list.isEmpty ? null : list.first;
  }

  ReportEntityStat? get fastestRider {
    final candidates = riderStats
        .where((s) => s.avgArriveMs != null && s.deliveredCount > 0)
        .toList()
      ..sort((a, b) => a.avgArriveMs!.compareTo(b.avgArriveMs!));
    return candidates.isEmpty ? null : candidates.first;
  }

  ReportEntityStat? get fastestSupervisor {
    final candidates = supervisorStats
        .where((s) => s.avgAssignMs != null && s.orderCount > 0)
        .toList()
      ..sort((a, b) => a.avgAssignMs!.compareTo(b.avgAssignMs!));
    return candidates.isEmpty ? null : candidates.first;
  }

  List<ReportEntityStat> get branchStats {
    final map = <String, _Agg>{};
    for (final order in filteredOrders) {
      final id = order.branchId;
      final name = order.branchName?.isNotEmpty == true
          ? order.branchName!
          : _branchName(id);
      final agg = map.putIfAbsent(id, () => _Agg(id: id, name: name));
      _accumulate(agg, order);
    }
    final list = map.values.map(_toStat).toList()
      ..sort((a, b) {
        final byRevenue = b.revenue.compareTo(a.revenue);
        if (byRevenue != 0) return byRevenue;
        return b.deliveredCount.compareTo(a.deliveredCount);
      });
    return list;
  }

  List<ReportEntityStat> get riderStats {
    final map = <String, _Agg>{};
    for (final order in filteredOrders) {
      final id = order.riderId;
      if (id == null || id.isEmpty) continue;
      final name = _resolveName(
        denormalized: order.riderName,
        id: id,
        lookup: _riderNames,
      );
      final agg = map.putIfAbsent(id, () => _Agg(id: id, name: name));
      if (name != id) agg.name = name;
      _accumulate(agg, order);
    }
    final list = map.values.map(_toStat).toList();
    switch (_riderRankBy) {
      case RiderRankBy.deliveries:
        list.sort((a, b) {
          final byDel = b.deliveredCount.compareTo(a.deliveredCount);
          if (byDel != 0) return byDel;
          return b.revenue.compareTo(a.revenue);
        });
      case RiderRankBy.revenue:
        list.sort((a, b) {
          final byRev = b.revenue.compareTo(a.revenue);
          if (byRev != 0) return byRev;
          return b.deliveredCount.compareTo(a.deliveredCount);
        });
    }
    return list;
  }

  List<ReportEntityStat> get customerStats {
    final map = <String, _Agg>{};
    for (final order in filteredOrders) {
      final id = order.customerId;
      if (id.isEmpty) continue;
      final name =
          order.customerName.isNotEmpty ? order.customerName : id;
      final agg = map.putIfAbsent(id, () => _Agg(id: id, name: name));
      _accumulate(agg, order);
    }
    final list = map.values.map(_toStat).toList();
    switch (_customerRankBy) {
      case CustomerRankBy.revenue:
        list.sort((a, b) {
          final byRev = b.revenue.compareTo(a.revenue);
          if (byRev != 0) return byRev;
          return b.orderCount.compareTo(a.orderCount);
        });
      case CustomerRankBy.orders:
        list.sort((a, b) {
          final byOrders = b.orderCount.compareTo(a.orderCount);
          if (byOrders != 0) return byOrders;
          return b.revenue.compareTo(a.revenue);
        });
    }
    return list;
  }

  List<ReportEntityStat> get supervisorStats {
    final map = <String, _Agg>{};
    for (final order in filteredOrders) {
      final id = order.supervisorId;
      if (id == null || id.isEmpty) continue;
      final name = _resolveName(
        denormalized: order.supervisorName,
        id: id,
        lookup: _supervisorNames,
      );
      final agg = map.putIfAbsent(id, () => _Agg(id: id, name: name));
      if (name != id) agg.name = name;
      _accumulate(agg, order);
    }
    final list = map.values.map(_toStat).toList()
      ..sort((a, b) {
        final byOrders = b.orderCount.compareTo(a.orderCount);
        if (byOrders != 0) return byOrders;
        final aAssign = a.avgAssignMs ?? double.infinity;
        final bAssign = b.avgAssignMs ?? double.infinity;
        return aAssign.compareTo(bAssign);
      });
    return list;
  }

  Map<OrderStatus, int> get statusBreakdown {
    final map = <OrderStatus, int>{};
    for (final order in filteredOrders) {
      map[order.status] = (map[order.status] ?? 0) + 1;
    }
    return map;
  }

  List<RevenuePoint> get revenueTrend {
    final map = <DateTime, RevenuePoint>{};
    for (final order in deliveredOrders) {
      final date = _basisDate(order);
      if (date == null) continue;
      final day = DateTime(date.year, date.month, date.day);
      final existing = map[day];
      if (existing == null) {
        map[day] = RevenuePoint(day: day, revenue: order.lineTotal, orders: 1);
      } else {
        map[day] = RevenuePoint(
          day: day,
          revenue: existing.revenue + order.lineTotal,
          orders: existing.orders + 1,
        );
      }
    }
    final list = map.values.toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    return list;
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
      _loadRiders(),
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
      _supervisorNames = {
        for (final user in value) user.id: user.displayName,
      };
      notifyListeners();
    }
  }

  Future<void> _loadRiders() async {
    final result = await _userRepository.listByRole(AppRole.driver);
    if (result case Success<List<AppUser>>(:final value)) {
      _riderNames = {
        for (final user in value) user.id: user.displayName,
      };
      notifyListeners();
    }
  }

  String supervisorNameFor(DeliveryOrder order) {
    final id = order.supervisorId;
    if (id == null || id.isEmpty) {
      return order.supervisorName?.trim().isNotEmpty == true
          ? order.supervisorName!.trim()
          : '';
    }
    return _resolveName(
      denormalized: order.supervisorName,
      id: id,
      lookup: _supervisorNames,
    );
  }

  String riderNameFor(DeliveryOrder order) {
    final id = order.riderId;
    if (id == null || id.isEmpty) {
      return order.riderName?.trim().isNotEmpty == true
          ? order.riderName!.trim()
          : '';
    }
    return _resolveName(
      denormalized: order.riderName,
      id: id,
      lookup: _riderNames,
    );
  }

  String _resolveName({
    required String? denormalized,
    required String id,
    required Map<String, String> lookup,
  }) {
    final lookedUp = lookup[id];
    if (lookedUp != null && lookedUp.trim().isNotEmpty) {
      return lookedUp.trim();
    }
    if (denormalized != null &&
        denormalized.trim().isNotEmpty &&
        denormalized.trim() != id) {
      return denormalized.trim();
    }
    return id;
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

  void setBranchFilter(String? branchId) {
    _branchFilter = branchId;
    notifyListeners();
  }

  void setPaymentFilter(PaymentMethod? method) {
    _paymentFilter = method;
    notifyListeners();
  }

  void setDateBasis(ReportsDateBasis basis) {
    _dateBasis = basis;
    notifyListeners();
  }

  void setRiderRankBy(RiderRankBy value) {
    _riderRankBy = value;
    notifyListeners();
  }

  void setCustomerRankBy(CustomerRankBy value) {
    _customerRankBy = value;
    notifyListeners();
  }

  DateTime? _basisDate(DeliveryOrder order) {
    switch (_dateBasis) {
      case ReportsDateBasis.created:
        return order.createdAtDate;
      case ReportsDateBasis.delivered:
        return order.deliveredAtDate ?? order.createdAtDate;
    }
  }

  String _branchName(String id) {
    for (final branch in _branches) {
      if (branch.id == id) return branch.name;
    }
    return id;
  }

  void _accumulate(_Agg agg, DeliveryOrder order) {
    agg.orderCount += 1;
    if (order.status == OrderStatus.delivered) {
      agg.deliveredCount += 1;
      agg.revenue += order.lineTotal;
    } else if (order.status == OrderStatus.failed) {
      agg.failedCount += 1;
    }

    final assign = order.supervisorAssignDuration;
    if (assign != null) {
      agg.assignTotalMs += assign.inMilliseconds;
      agg.assignSamples += 1;
    }

    final arrive = _arriveDuration(order);
    if (arrive != null) {
      agg.arriveTotalMs += arrive.inMilliseconds;
      agg.arriveSamples += 1;
    }

    final delivery = order.totalOrderDuration;
    if (delivery != null && order.status == OrderStatus.delivered) {
      agg.deliveryTotalMs += delivery.inMilliseconds;
      agg.deliverySamples += 1;
    }
  }

  Duration? _arriveDuration(DeliveryOrder order) {
    final arrived = order.riderArrivedAtDate;
    if (arrived == null) return null;
    final start = order.assignedAtDate ?? order.outForDeliveryAtDate;
    if (start == null) return null;
    final diff = arrived.difference(start);
    if (diff.isNegative) return null;
    return diff;
  }

  ReportEntityStat _toStat(_Agg agg) {
    return ReportEntityStat(
      id: agg.id,
      name: agg.name,
      revenue: agg.revenue,
      orderCount: agg.orderCount,
      deliveredCount: agg.deliveredCount,
      failedCount: agg.failedCount,
      avgAssignMs: agg.assignSamples == 0
          ? null
          : agg.assignTotalMs / agg.assignSamples,
      avgArriveMs: agg.arriveSamples == 0
          ? null
          : agg.arriveTotalMs / agg.arriveSamples,
      avgDeliveryMs: agg.deliverySamples == 0
          ? null
          : agg.deliveryTotalMs / agg.deliverySamples,
    );
  }

  Duration? _averageDuration(List<Duration> values) {
    if (values.isEmpty) return null;
    final totalMs =
        values.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
    return Duration(milliseconds: (totalMs / values.length).round());
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

class _Agg {
  _Agg({required this.id, required this.name});

  final String id;
  String name;
  double revenue = 0;
  int orderCount = 0;
  int deliveredCount = 0;
  int failedCount = 0;
  double assignTotalMs = 0;
  int assignSamples = 0;
  double arriveTotalMs = 0;
  int arriveSamples = 0;
  double deliveryTotalMs = 0;
  int deliverySamples = 0;
}
