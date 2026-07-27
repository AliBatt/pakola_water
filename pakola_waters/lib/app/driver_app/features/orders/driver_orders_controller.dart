import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';

import '../../../../shared/orders/others_date_preset.dart';

class DriverOrdersController extends ChangeNotifier {
  DriverOrdersController({
    required OrderRepository orderRepository,
    required NotificationRepository notificationRepository,
  })  : _orderRepository = orderRepository,
        _notificationRepository = notificationRepository;

  final OrderRepository _orderRepository;
  final NotificationRepository _notificationRepository;

  AppUser? _rider;
  List<DeliveryOrder> _orders = [];
  DateTimeRange _statsRange = DateTimeRange(
    start: DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    ),
    end: DateTime.now(),
  );
  String _othersSearch = '';
  OthersDatePreset _othersDatePreset = OthersDatePreset.all;
  DateTimeRange? _othersCustomRange;
  OrderStatus? _othersStatusFilter;
  bool _isUpdating = false;
  StreamSubscription<List<DeliveryOrder>>? _ordersSub;

  List<DeliveryOrder> get orders => _orders;
  DateTimeRange get statsRange => _statsRange;
  bool get isUpdating => _isUpdating;
  OthersDatePreset get othersDatePreset => _othersDatePreset;
  DateTimeRange? get othersCustomRange => _othersCustomRange;
  OrderStatus? get othersStatusFilter => _othersStatusFilter;

  List<DeliveryOrder> get assignedOrders => _orders
      .where((o) => o.status.isInProgress)
      .toList()
    ..sort((a, b) {
      final aDate = a.createdAtDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAtDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

  int get newAssignedCount =>
      _orders.where((o) => o.status == OrderStatus.assigned).length;

  List<DeliveryOrder> get filteredOthersOrders {
    final query = _othersSearch.trim().toLowerCase();
    return _orders.where((order) {
      if (order.status.isInProgress) return false;

      if (query.isNotEmpty) {
        final customer = order.customerName.toLowerCase();
        final haystack = [
          customer,
          order.customerPhone ?? '',
          order.productName,
        ].join(' ').toLowerCase();
        if (!haystack.contains(query)) return false;
      }

      if (_othersStatusFilter != null && order.status != _othersStatusFilter) {
        return false;
      }

      final created = order.createdAtDate;
      if (created == null) return _othersDatePreset == OthersDatePreset.all;
      final range = _othersDateRange();
      if (range == null) return true;
      return !created.isBefore(range.start) && !created.isAfter(range.end);
    }).toList()
      ..sort((a, b) {
        final aDate = a.createdAtDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAtDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
  }

  List<DeliveryOrder> get ordersInStatsRange {
    return _orders.where((order) {
      final created = order.createdAtDate;
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
      final created = order.createdAtDate;
      return created != null && !created.isBefore(start);
    }).length;
  }

  int get statsTotalOrders => ordersInStatsRange.length;

  int get statsAssignedOrders =>
      ordersInStatsRange.where((o) => o.status == OrderStatus.assigned).length;

  int get statsInProgressOrders =>
      ordersInStatsRange.where((o) => o.status.isInProgress).length;

  int get statsCompletedOrders => ordersInStatsRange
      .where((o) => o.status == OrderStatus.delivered)
      .length;

  int get statsFailedOrders =>
      ordersInStatsRange.where((o) => o.status == OrderStatus.failed).length;

  void bindRider(AppUser? rider) {
    if (rider?.id == _rider?.id) return;
    _rider = rider;
    _ordersSub?.cancel();
    _orders = [];

    if (rider == null) {
      notifyListeners();
      return;
    }

    _subscribe(rider.id);
  }

  void _subscribe(String riderId) {
    _ordersSub = _orderRepository.watchRiderOrders(riderId).listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  void setStatsRange(DateTimeRange range) {
    _statsRange = range;
    notifyListeners();
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

  DeliveryOrder? orderById(String orderId) {
    for (final order in _orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  Future<void> refresh() async {
    final riderId = _rider?.id;
    if (riderId == null) return;
    _ordersSub?.cancel();
    _subscribe(riderId);
    // Allow the stream subscription a moment to emit.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  void _replaceOrder(DeliveryOrder updated) {
    _orders = [
      for (final order in _orders)
        if (order.id == updated.id) updated else order,
    ];
  }

  Future<Result<void>> markOutForDelivery(String orderId) async {
    _isUpdating = true;
    notifyListeners();
    final result = await _orderRepository.markOutForDelivery(orderId);
    if (result case Success()) {
      final current = orderById(orderId);
      if (current != null) {
        final now = DateTime.now().toIso8601String();
        _replaceOrder(
          current.copyWith(
            status: OrderStatus.outForDelivery,
            outForDeliveryAt: now,
            updatedAt: now,
          ),
        );
        await _notifyCustomer(
          order: current,
          title: 'Out for delivery',
          body:
              'Your ${current.productName} order is on the way with ${current.riderName ?? 'your rider'}.',
          type: 'order_out_for_delivery',
        );
      }
    }
    _isUpdating = false;
    notifyListeners();
    return result;
  }

  Future<Result<void>> markRiderArrived(String orderId) async {
    _isUpdating = true;
    notifyListeners();
    final result = await _orderRepository.markRiderArrived(orderId);
    if (result case Success()) {
      final current = orderById(orderId);
      if (current != null) {
        final now = DateTime.now().toIso8601String();
        _replaceOrder(
          current.copyWith(
            status: OrderStatus.riderArrived,
            riderArrivedAt: now,
            updatedAt: now,
          ),
        );
        await _notifyCustomer(
          order: current,
          title: 'Rider arrived',
          body:
              'Your rider has arrived with your ${current.productName} order. Please confirm delivery.',
          type: 'order_rider_arrived',
        );
      }
    }
    _isUpdating = false;
    notifyListeners();
    return result;
  }

  Future<void> _notifyCustomer({
    required DeliveryOrder order,
    required String title,
    required String body,
    required String type,
  }) async {
    final rider = _rider;
    if (rider == null) return;
    await _notificationRepository.createNotification(
      AppNotification(
        id: '',
        userId: order.customerId,
        title: title,
        body: body,
        createdById: rider.id,
        createdByRole: rider.role.name,
        createdByName: rider.displayName,
        type: type,
        orderId: order.id,
      ),
    );
  }

  DateTimeRange? _othersDateRange() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    switch (_othersDatePreset) {
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
        return _othersCustomRange;
    }
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }
}
