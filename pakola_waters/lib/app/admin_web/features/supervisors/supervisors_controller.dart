import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';
import 'package:services/services.dart';

class SupervisorsController extends ChangeNotifier {
  SupervisorsController({
    required UserRepository userRepository,
    required BranchRepository branchRepository,
  })  : _userRepository = userRepository,
        _branchRepository = branchRepository;

  final UserRepository _userRepository;
  final BranchRepository _branchRepository;

  List<AppUser> _supervisors = [];
  List<Branch> _branches = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  UserStatus? _statusFilter;

  List<AppUser> get supervisors {
    return _supervisors.where((user) {
      final matchesSearch = _search.isEmpty ||
          user.displayName.toLowerCase().contains(_search.toLowerCase()) ||
          (user.phone ?? '').contains(_search) ||
          user.email.toLowerCase().contains(_search.toLowerCase());
      final matchesStatus =
          _statusFilter == null || user.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<Branch> get branches => _branches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  UserStatus? get statusFilter => _statusFilter;

  Branch? branchFor(AppUser user) {
    final id = user.primaryBranchId;
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

  void setStatusFilter(UserStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final usersResult = await _userRepository.listByRole(AppRole.supervisor);
    final branchesResult = await _branchRepository.listBranches();

    switch (usersResult) {
      case Success<List<AppUser>>(:final value):
        _supervisors = value;
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

  Future<Result<CreateUserAccountResult>> create({
    required String displayName,
    required String phone,
    required UserStatus status,
    String? email,
    String? address,
    String? notes,
    String? primaryBranchId,
  }) async {
    final result = await _userRepository.createUser(
      displayName: displayName,
      phone: phone,
      email: email,
      address: address,
      notes: notes,
      role: AppRole.supervisor,
      status: status,
      primaryBranchId: primaryBranchId,
      branchIds: primaryBranchId == null ? const [] : [primaryBranchId],
    );
    if (result case Success()) {
      await load();
    }
    return result;
  }

  Future<Result<AppUser>> update(AppUser user) async {
    final result = await _userRepository.updateUser(user);
    if (result case Success()) {
      await load();
    }
    return result;
  }

  Future<Result<void>> delete(String userId) async {
    final result = await _userRepository.deleteUser(userId);
    if (result case Success()) {
      await load();
    }
    return result;
  }
}
