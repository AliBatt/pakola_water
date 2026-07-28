import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';

class AdminCustomersController extends ChangeNotifier {
  AdminCustomersController({
    required UserRepository userRepository,
    required BranchRepository branchRepository,
    required OrderRepository orderRepository,
  })  : _userRepository = userRepository,
        _branchRepository = branchRepository,
        _orderRepository = orderRepository;

  final UserRepository _userRepository;
  final BranchRepository _branchRepository;
  final OrderRepository _orderRepository;

  List<AppUser> _customers = [];
  List<Branch> _branches = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  String? _branchFilter;
  UserStatus? _statusFilter;

  List<Branch> get branches => _branches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  String? get branchFilter => _branchFilter;
  UserStatus? get statusFilter => _statusFilter;
  OrderRepository get orderRepository => _orderRepository;

  List<AppUser> get customers {
    final query = _search.trim().toLowerCase();
    return _customers.where((user) {
      if (_statusFilter != null && user.status != _statusFilter) {
        return false;
      }
      if (_branchFilter != null) {
        final preferred = user.primaryBranchId;
        final inList = user.branchIds.contains(_branchFilter);
        if (preferred != _branchFilter && !inList) return false;
      }
      if (query.isEmpty) return true;
      final haystack = [
        user.displayName,
        user.email,
        user.phone ?? '',
        user.address ?? '',
        branchNameFor(user),
        user.id,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
  }

  int get totalCount => customers.length;
  int get activeCount =>
      customers.where((c) => c.status == UserStatus.active).length;

  String branchNameFor(AppUser user) {
    final id = user.primaryBranchId;
    if (id == null || id.isEmpty) {
      if (user.branchIds.isNotEmpty) {
        return _branchName(user.branchIds.first);
      }
      return '—';
    }
    return _branchName(id);
  }

  List<String> preferredBranchNames(AppUser user) {
    final ids = <String>{
      if (user.primaryBranchId != null && user.primaryBranchId!.isNotEmpty)
        user.primaryBranchId!,
      ...user.branchIds,
    };
    if (ids.isEmpty) return const ['—'];
    return ids.map(_branchName).toList();
  }

  String _branchName(String id) {
    for (final branch in _branches) {
      if (branch.id == id) return branch.name;
    }
    return id;
  }

  Branch? branchById(String? id) {
    if (id == null) return null;
    for (final branch in _branches) {
      if (branch.id == id) return branch;
    }
    return null;
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setBranchFilter(String? branchId) {
    _branchFilter = branchId;
    notifyListeners();
  }

  void setStatusFilter(UserStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final customersResult = await _userRepository.listByRole(AppRole.customer);
    final branchesResult = await _branchRepository.listBranches();

    switch (customersResult) {
      case Success<List<AppUser>>(:final value):
        _customers = value;
      case FailureResult<List<AppUser>>(:final failure):
        _error = failure.message;
    }

    switch (branchesResult) {
      case Success<List<Branch>>(:final value):
        _branches = value;
      case FailureResult<List<Branch>>(:final failure):
        _error ??= failure.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Stream<List<DeliveryOrder>> watchCustomerOrders(String customerId) {
    return _orderRepository.watchCustomerOrders(customerId);
  }
}
