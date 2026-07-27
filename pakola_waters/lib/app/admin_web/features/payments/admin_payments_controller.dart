import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';

import '../../../../shared/orders/others_date_preset.dart';

class AdminPaymentsController extends ChangeNotifier {
  AdminPaymentsController({
    required OrderRepository orderRepository,
    required NotificationRepository notificationRepository,
  })  : _orderRepository = orderRepository,
        _notificationRepository = notificationRepository;

  final OrderRepository _orderRepository;
  final NotificationRepository _notificationRepository;

  List<DeliveryOrder> _orders = [];
  String _search = '';
  PaymentMethod? _methodFilter;
  PaymentStatus? _statusFilter;
  OthersDatePreset _datePreset = OthersDatePreset.all;
  DateTimeRange? _customRange;
  bool _unpaidCreditOnly = false;
  bool _bound = false;
  bool _acting = false;
  final Set<String> _healedCodIds = {};
  StreamSubscription<List<DeliveryOrder>>? _ordersSub;

  List<DeliveryOrder> get orders => _orders;
  String get search => _search;
  PaymentMethod? get methodFilter => _methodFilter;
  PaymentStatus? get statusFilter => _statusFilter;
  OthersDatePreset get datePreset => _datePreset;
  DateTimeRange? get customRange => _customRange;
  bool get unpaidCreditOnly => _unpaidCreditOnly;
  bool get isActing => _acting;
  bool get isLoading => !_bound || (_ordersSub == null && _orders.isEmpty);

  List<DeliveryOrder> get filteredOrders {
    final query = _search.trim().toLowerCase();
    return _orders.where((order) {
      if (_unpaidCreditOnly && !order.isUnpaidCredit) return false;
      if (_methodFilter != null && order.paymentMethod != _methodFilter) {
        return false;
      }
      if (_statusFilter != null &&
          order.effectivePaymentStatus != _statusFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final haystack = [
          order.customerName,
          order.customerPhone ?? '',
          order.productName,
          order.branchName ?? '',
          order.id,
          order.paymentMethod.label,
          order.effectivePaymentStatus.label,
        ].join(' ').toLowerCase();
        if (!haystack.contains(query)) return false;
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

  int get totalCount => filteredOrders.length;
  int get codCount =>
      filteredOrders.where((o) => o.paymentMethod == PaymentMethod.cod).length;
  int get creditCount => filteredOrders
      .where((o) => o.paymentMethod == PaymentMethod.credit)
      .length;
  int get paidCount =>
      filteredOrders.where((o) => o.effectivePaymentStatus.isPaid).length;
  int get unpaidCount =>
      filteredOrders.where((o) => o.effectivePaymentStatus.isUnpaid).length;
  int get unpaidCreditCount =>
      filteredOrders.where((o) => o.isUnpaidCredit).length;

  double get paidRevenue => filteredOrders
      .where((o) => o.effectivePaymentStatus.isPaid)
      .fold(0, (sum, o) => sum + o.lineTotal);

  double get unpaidCreditRevenue => filteredOrders
      .where((o) => o.isUnpaidCredit)
      .fold(0, (sum, o) => sum + o.lineTotal);

  void bind() {
    if (_bound) return;
    _bound = true;
    _ordersSub?.cancel();
    _ordersSub = _orderRepository.watchAllOrders().listen((orders) {
      _orders = orders;
      notifyListeners();
      _healDeliveredCodPayments(orders);
    });
  }

  Future<void> refresh() async {
    _ordersSub?.cancel();
    _ordersSub = _orderRepository.watchAllOrders().listen((orders) {
      _orders = orders;
      notifyListeners();
      _healDeliveredCodPayments(orders);
    });
  }

  /// Older COD deliveries left paymentStatus as pending; sync them to paid.
  Future<void> _healDeliveredCodPayments(List<DeliveryOrder> orders) async {
    for (final order in orders) {
      if (_healedCodIds.contains(order.id)) continue;
      if (order.paymentMethod == PaymentMethod.cod &&
          order.status == OrderStatus.delivered &&
          order.paymentStatus.isUnpaid) {
        _healedCodIds.add(order.id);
        await _orderRepository.markPaymentPaid(order.id);
      }
    }
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setMethodFilter(PaymentMethod? method) {
    _methodFilter = method;
    if (method != PaymentMethod.credit) {
      _unpaidCreditOnly = false;
    }
    notifyListeners();
  }

  void setStatusFilter(PaymentStatus? status) {
    _statusFilter = status;
    if (status == PaymentStatus.paid) {
      _unpaidCreditOnly = false;
    }
    notifyListeners();
  }

  void setUnpaidCreditOnly(bool value) {
    _unpaidCreditOnly = value;
    if (value) {
      _methodFilter = PaymentMethod.credit;
      _statusFilter = PaymentStatus.pending;
    }
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

  Future<Result<void>> markPaid(DeliveryOrder order) async {
    _acting = true;
    notifyListeners();
    final result = await _orderRepository.markPaymentPaid(order.id);
    _acting = false;
    notifyListeners();
    return result;
  }

  Future<Result<AppNotification>> notifyPaymentDue({
    required DeliveryOrder order,
    required AppUser sender,
    required String title,
    required String body,
  }) {
    return _notificationRepository.createNotification(
      AppNotification(
        id: '',
        userId: order.customerId,
        title: title,
        body: body,
        createdById: sender.id,
        createdByRole: sender.role.name,
        createdByName: sender.displayName,
        type: 'payment_reminder',
        orderId: order.id,
      ),
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
