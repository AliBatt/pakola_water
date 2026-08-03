import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:services/services.dart';

abstract class SupportRequestRepository {
  Stream<List<SupportRequest>> watchAll();
  Stream<List<SupportRequest>> watchForUser(String userId);
  Stream<SupportRequest?> watchById(String requestId);
  Stream<List<SupportRequestReply>> watchReplies(String requestId);
  Future<Result<SupportRequest>> createRequest({
    required AppUser requester,
    required String title,
    required String description,
    String? imageUrl,
  });
  Future<Result<SupportRequestReply>> addReply({
    required SupportRequest request,
    required AppUser sender,
    required String message,
  });
  Future<Result<void>> updateStatus({
    required SupportRequest request,
    required SupportRequestStatus status,
    required AppUser admin,
  });
  Future<Result<void>> markRead({
    required String requestId,
    required bool asAdmin,
  });
}

class SupportRequestRepositoryImpl implements SupportRequestRepository {
  SupportRequestRepositoryImpl(this._service);

  final SupportRequestService _service;

  @override
  Stream<List<SupportRequest>> watchAll() => _service.watchAll();

  @override
  Stream<List<SupportRequest>> watchForUser(String userId) =>
      _service.watchForUser(userId);

  @override
  Stream<SupportRequest?> watchById(String requestId) =>
      _service.watchById(requestId);

  @override
  Stream<List<SupportRequestReply>> watchReplies(String requestId) =>
      _service.watchReplies(requestId);

  @override
  Future<Result<SupportRequest>> createRequest({
    required AppUser requester,
    required String title,
    required String description,
    String? imageUrl,
  }) {
    return _service.createRequest(
      requester: requester,
      title: title,
      description: description,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<Result<SupportRequestReply>> addReply({
    required SupportRequest request,
    required AppUser sender,
    required String message,
  }) {
    return _service.addReply(
      request: request,
      sender: sender,
      message: message,
    );
  }

  @override
  Future<Result<void>> updateStatus({
    required SupportRequest request,
    required SupportRequestStatus status,
    required AppUser admin,
  }) {
    return _service.updateStatus(
      request: request,
      status: status,
      admin: admin,
    );
  }

  @override
  Future<Result<void>> markRead({
    required String requestId,
    required bool asAdmin,
  }) {
    return _service.markRead(requestId: requestId, asAdmin: asAdmin);
  }
}
