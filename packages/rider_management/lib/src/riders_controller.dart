import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';
import 'package:services/services.dart';

class RidersController extends ChangeNotifier {
  RidersController({
    required UserRepository userRepository,
    required BranchRepository branchRepository,
  })  : _userRepository = userRepository,
        _branchRepository = branchRepository;

  final UserRepository _userRepository;
  final BranchRepository _branchRepository;

  List<AppUser> _riders = [];
  List<Branch> _branches = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  UserStatus? _statusFilter;
  String? _branchFilter;

  List<AppUser> get riders {
    return _riders.where((user) {
      final query = _search.toLowerCase();
      final matchesSearch = _search.isEmpty ||
          user.displayName.toLowerCase().contains(query) ||
          (user.phone ?? '').contains(_search) ||
          user.email.toLowerCase().contains(query) ||
          (user.cnic ?? '').contains(_search) ||
          (user.vehiclePlate ?? '').toLowerCase().contains(query);
      final matchesStatus =
          _statusFilter == null || user.status == _statusFilter;
      final matchesBranch = _branchFilter == null ||
          user.branchIds.contains(_branchFilter) ||
          user.primaryBranchId == _branchFilter;
      return matchesSearch && matchesStatus && matchesBranch;
    }).toList();
  }

  List<Branch> get branches => _branches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  UserStatus? get statusFilter => _statusFilter;
  String? get branchFilter => _branchFilter;

  String branchNamesFor(AppUser rider) {
    if (rider.branchIds.isEmpty) return 'No branches';
    final names = _branches
        .where((branch) => rider.branchIds.contains(branch.id))
        .map((branch) => branch.name)
        .toList();
    return names.isEmpty ? '${rider.branchIds.length} branch(es)' : names.join(', ');
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setStatusFilter(UserStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setBranchFilter(String? branchId) {
    _branchFilter = branchId;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final ridersResult = await _userRepository.listByRole(AppRole.driver);
    final branchesResult = await _branchRepository.listBranches();

    switch (ridersResult) {
      case Success<List<AppUser>>(:final value):
        _riders = value;
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
    required List<String> branchIds,
    String? email,
    String? address,
    String? notes,
    String? cnic,
    String? experience,
    String? vehiclePlate,
  }) async {
    final result = await _userRepository.createUser(
      displayName: displayName,
      phone: phone,
      email: email,
      address: address,
      notes: notes,
      cnic: cnic,
      experience: experience,
      vehiclePlate: vehiclePlate,
      role: AppRole.driver,
      status: status,
      branchIds: branchIds,
      primaryBranchId: branchIds.isNotEmpty ? branchIds.first : null,
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
