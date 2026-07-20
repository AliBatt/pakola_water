import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:services/services.dart';

abstract class BranchRepository {
  Future<Result<List<Branch>>> listBranches();
  Future<Result<Branch>> createBranch(Branch branch);
  Future<Result<Branch>> updateBranch(Branch branch);
  Future<Result<void>> deleteBranch(String branchId);
}

class BranchRepositoryImpl implements BranchRepository {
  BranchRepositoryImpl(this._branchService);

  final BranchService _branchService;

  @override
  Future<Result<List<Branch>>> listBranches() => _branchService.listBranches();

  @override
  Future<Result<Branch>> createBranch(Branch branch) =>
      _branchService.createBranch(branch);

  @override
  Future<Result<Branch>> updateBranch(Branch branch) =>
      _branchService.updateBranch(branch);

  @override
  Future<Result<void>> deleteBranch(String branchId) =>
      _branchService.deleteBranch(branchId);
}
