import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';

class BranchesController extends ChangeNotifier {
  BranchesController({
    required BranchRepository branchRepository,
    required UserRepository userRepository,
  })  : _branchRepository = branchRepository,
        _userRepository = userRepository;

  final BranchRepository _branchRepository;
  final UserRepository _userRepository;

  List<Branch> _branches = [];
  List<AppUser> _supervisors = [];
  List<AppUser> _riders = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  BranchStatus? _statusFilter;

  List<Branch> get branches {
    return _branches.where((branch) {
      final matchesSearch = _search.isEmpty ||
          branch.name.toLowerCase().contains(_search.toLowerCase()) ||
          branch.code.toLowerCase().contains(_search.toLowerCase()) ||
          (branch.city ?? '').toLowerCase().contains(_search.toLowerCase());
      final matchesStatus =
          _statusFilter == null || branch.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<AppUser> get supervisors => _supervisors
      .where((user) => user.status == UserStatus.active)
      .toList();
  List<AppUser> get riders =>
      _riders.where((user) => user.status == UserStatus.active).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  BranchStatus? get statusFilter => _statusFilter;

  AppUser? supervisorFor(Branch branch) {
    final id = branch.supervisorId;
    if (id == null) return null;
    for (final user in _supervisors) {
      if (user.id == id) return user;
    }
    return null;
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setStatusFilter(BranchStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final branchesResult = await _branchRepository.listBranches();
    final supervisorsResult =
        await _userRepository.listByRole(AppRole.supervisor);
    final ridersResult = await _userRepository.listByRole(AppRole.driver);

    switch (branchesResult) {
      case Success<List<Branch>>(:final value):
        _branches = value;
      case FailureResult<List<Branch>>(:final failure):
        _error = failure.message;
    }
    switch (supervisorsResult) {
      case Success<List<AppUser>>(:final value):
        _supervisors = value;
      case FailureResult<List<AppUser>>(:final failure):
        _error ??= failure.message;
    }
    switch (ridersResult) {
      case Success<List<AppUser>>(:final value):
        _riders = value;
      case FailureResult<List<AppUser>>(:final failure):
        _error ??= failure.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Result<Branch>> create(Branch branch) async {
    final result = await _branchRepository.createBranch(branch);
    if (result case Success()) {
      await load();
    }
    return result;
  }

  Future<Result<Branch>> update(Branch branch) async {
    final result = await _branchRepository.updateBranch(branch);
    if (result case Success()) {
      await load();
    }
    return result;
  }

  Future<Result<void>> delete(String branchId) async {
    final result = await _branchRepository.deleteBranch(branchId);
    if (result case Success()) {
      await load();
    }
    return result;
  }
}
