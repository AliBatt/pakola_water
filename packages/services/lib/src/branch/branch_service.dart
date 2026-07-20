import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:models/models.dart';

abstract class BranchService {
  Future<Result<List<Branch>>> listBranches();
  Future<Result<Branch>> createBranch(Branch branch);
  Future<Result<Branch>> updateBranch(Branch branch);
  Future<Result<void>> deleteBranch(String branchId);
}

class BranchServiceImpl implements BranchService {
  BranchServiceImpl(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<Result<List<Branch>>> listBranches() async {
    try {
      final snapshot =
          await _firestoreService.collection(CollectionPaths.branches).get();
      final branches = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Branch.fromJson(data);
      }).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return Success(branches);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<Branch>> createBranch(Branch branch) async {
    try {
      final docRef =
          _firestoreService.collection(CollectionPaths.branches).doc();
      final data = branch.toJson()
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);

      final created = branch.copyWith(id: docRef.id);
      if (created.supervisorId != null) {
        await _linkSupervisor(created.id, created.supervisorId!);
      }
      return Success(created);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<Branch>> updateBranch(Branch branch) async {
    try {
      final data = branch.toJson()
        ..['updatedAt'] = FieldValue.serverTimestamp();
      await _firestoreService.setDoc(
        CollectionPaths.branches,
        branch.id,
        data,
        merge: true,
      );
      if (branch.supervisorId != null) {
        await _linkSupervisor(branch.id, branch.supervisorId!);
      }
      return Success(branch);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> deleteBranch(String branchId) async {
    try {
      await _firestoreService.deleteDoc(CollectionPaths.branches, branchId);
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  Future<void> _linkSupervisor(String branchId, String supervisorId) async {
    await _firestoreService.setDoc(
      CollectionPaths.users,
      supervisorId,
      {
        'primaryBranchId': branchId,
        'branchIds': FieldValue.arrayUnion([branchId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      merge: true,
    );
  }
}
