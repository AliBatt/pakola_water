import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:models/models.dart';

import '../notification/notification_service.dart';

abstract class SupportRequestService {
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

class SupportRequestServiceImpl implements SupportRequestService {
  SupportRequestServiceImpl(
    this._firestoreService,
    this._notificationService,
  );

  final FirestoreService _firestoreService;
  final NotificationService _notificationService;

  static const _replies = 'replies';

  SupportRequest _mapRequest(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = doc.id;
    _normalizeTimestamps(data);
    return SupportRequest.fromJson(data);
  }

  SupportRequest _mapRequestDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] = doc.id;
    _normalizeTimestamps(data);
    return SupportRequest.fromJson(data);
  }

  SupportRequestReply _mapReply(
    String requestId,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = doc.id;
    data['requestId'] = requestId;
    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) {
      data['createdAt'] = createdAt.toDate().toIso8601String();
    }
    return SupportRequestReply.fromJson(data);
  }

  void _normalizeTimestamps(Map<String, dynamic> data) {
    for (final key in [
      'createdAt',
      'updatedAt',
      'lastReplyAt',
      'closedAt',
    ]) {
      final value = data[key];
      if (value is Timestamp) {
        data[key] = value.toDate().toIso8601String();
      }
    }
  }

  @override
  Stream<List<SupportRequest>> watchAll() {
    return _firestoreService
        .watchCollectionOrderBy(
          CollectionPaths.supportRequests,
          orderBy: 'createdAt',
        )
        .map((snapshot) => snapshot.docs.map(_mapRequest).toList());
  }

  @override
  Stream<List<SupportRequest>> watchForUser(String userId) {
    return _firestoreService
        .watchWhereOrderBy(
          CollectionPaths.supportRequests,
          field: 'createdById',
          isEqualTo: userId,
          orderBy: 'createdAt',
        )
        .map((snapshot) => snapshot.docs.map(_mapRequest).toList());
  }

  @override
  Stream<SupportRequest?> watchById(String requestId) {
    return _firestoreService
        .watchDoc(CollectionPaths.supportRequests, requestId)
        .map((doc) {
      if (!doc.exists) return null;
      return _mapRequestDoc(doc);
    });
  }

  @override
  Stream<List<SupportRequestReply>> watchReplies(String requestId) {
    return _firestoreService
        .subcollection(
          CollectionPaths.supportRequests,
          requestId,
          _replies,
        )
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => _mapReply(requestId, doc)).toList(),
        );
  }

  @override
  Future<Result<SupportRequest>> createRequest({
    required AppUser requester,
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedDescription = description.trim();
    if (trimmedTitle.isEmpty) {
      return const FailureResult(ServerFailure('Title is required'));
    }
    if (trimmedDescription.isEmpty) {
      return const FailureResult(ServerFailure('Description is required'));
    }
    if (requester.role == AppRole.admin) {
      return const FailureResult(
        ServerFailure('Admins cannot create support requests'),
      );
    }

    try {
      final docRef =
          _firestoreService.collection(CollectionPaths.supportRequests).doc();
      final data = {
        'title': trimmedTitle,
        'description': trimmedDescription,
        'createdById': requester.id,
        'createdByName': requester.displayName,
        'createdByRole': requester.role.name,
        'status': SupportRequestStatus.open.name,
        'imageUrl': imageUrl,
        'adminUnread': true,
        'requesterUnread': false,
        'lastReplyAt': null,
        'lastReplyPreview': trimmedDescription,
        'lastReplyByRole': requester.role.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await docRef.set(data);

      // Push to admins is handled by Cloud Function onSupportRequestCreated.
      return Success(
        SupportRequest(
          id: docRef.id,
          title: trimmedTitle,
          description: trimmedDescription,
          createdById: requester.id,
          createdByName: requester.displayName,
          createdByRole: requester.role,
          imageUrl: imageUrl,
          adminUnread: true,
          lastReplyPreview: trimmedDescription,
          lastReplyByRole: requester.role.name,
        ),
      );
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<SupportRequestReply>> addReply({
    required SupportRequest request,
    required AppUser sender,
    required String message,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return const FailureResult(ServerFailure('Reply cannot be empty'));
    }
    if (request.status.isTerminal) {
      return const FailureResult(
        ServerFailure('This request is closed and cannot accept replies'),
      );
    }

    final isAdmin = sender.role == AppRole.admin;
    final isOwner = sender.id == request.createdById;
    if (!isAdmin && !isOwner) {
      return const FailureResult(
        ServerFailure('You cannot reply to this request'),
      );
    }

    try {
      final replyRef = _firestoreService
          .subcollection(
            CollectionPaths.supportRequests,
            request.id,
            _replies,
          )
          .doc();
      await replyRef.set({
        'requestId': request.id,
        'message': trimmed,
        'createdById': sender.id,
        'createdByName': sender.displayName,
        'createdByRole': sender.role.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final preview = trimmed.length > 120
          ? '${trimmed.substring(0, 117)}...'
          : trimmed;

      await _firestoreService.updateDoc(
        CollectionPaths.supportRequests,
        request.id,
        {
          'lastReplyAt': FieldValue.serverTimestamp(),
          'lastReplyPreview': preview,
          'lastReplyByRole': sender.role.name,
          'updatedAt': FieldValue.serverTimestamp(),
          if (isAdmin) ...{
            'requesterUnread': true,
            'adminUnread': false,
            if (request.status == SupportRequestStatus.open)
              'status': SupportRequestStatus.inProgress.name,
          } else ...{
            'adminUnread': true,
            'requesterUnread': false,
          },
        },
      );

      // Push notifications are handled by Cloud Function onSupportReplyCreated.

      return Success(
        SupportRequestReply(
          id: replyRef.id,
          requestId: request.id,
          message: trimmed,
          createdById: sender.id,
          createdByName: sender.displayName,
          createdByRole: sender.role.name,
        ),
      );
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> updateStatus({
    required SupportRequest request,
    required SupportRequestStatus status,
    required AppUser admin,
  }) async {
    if (admin.role != AppRole.admin) {
      return const FailureResult(
        ServerFailure('Only admins can update request status'),
      );
    }

    try {
      final data = <String, dynamic>{
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'requesterUnread': true,
      };
      if (status.isTerminal) {
        data['closedAt'] = FieldValue.serverTimestamp();
        data['closedById'] = admin.id;
        data['closedByName'] = admin.displayName;
      }

      await _firestoreService.updateDoc(
        CollectionPaths.supportRequests,
        request.id,
        data,
      );

      await _notificationService.createNotification(
        AppNotification(
          id: '',
          userId: request.createdById,
          title: 'Request ${status.label.toLowerCase()}',
          body:
              'Your request "${request.title}" was marked as ${status.label.toLowerCase()}.',
          createdById: admin.id,
          createdByRole: admin.role.name,
          createdByName: admin.displayName,
          type: 'support_request_status',
          requestId: request.id,
        ),
      );

      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> markRead({
    required String requestId,
    required bool asAdmin,
  }) async {
    try {
      await _firestoreService.updateDoc(
        CollectionPaths.supportRequests,
        requestId,
        {
          if (asAdmin) 'adminUnread': false else 'requesterUnread': false,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }
}
