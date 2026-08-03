import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';

import '../orders/others_date_preset.dart';

class SupportRequestsController extends ChangeNotifier {
  SupportRequestsController({
    required SupportRequestRepository requestRepository,
  }) : _requestRepository = requestRepository;

  final SupportRequestRepository _requestRepository;

  AppUser? _user;
  List<SupportRequest> _requests = [];
  bool _isSubmitting = false;
  String? _error;
  StreamSubscription<List<SupportRequest>>? _sub;

  String _search = '';
  OthersDatePreset _datePreset = OthersDatePreset.all;
  DateTimeRange? _customRange;
  SupportRequestStatus? _statusFilter;

  List<SupportRequest> get requests => _requests;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String get search => _search;
  OthersDatePreset get datePreset => _datePreset;
  DateTimeRange? get customRange => _customRange;
  SupportRequestStatus? get statusFilter => _statusFilter;

  bool get isAdmin => _user?.role == AppRole.admin;

  int get unreadCount {
    if (_user == null) return 0;
    if (isAdmin) {
      return _requests.where((r) => r.adminUnread).length;
    }
    return _requests.where((r) => r.requesterUnread).length;
  }

  List<SupportRequest> get filteredRequests {
    final query = _search.trim().toLowerCase();
    return _requests.where((request) {
      if (_statusFilter != null && request.status != _statusFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final haystack = [
          request.title,
          request.description,
          request.createdByName,
          request.roleLabel,
          request.lastReplyPreview ?? '',
        ].join(' ').toLowerCase();
        if (!haystack.contains(query)) return false;
      }

      final created = DateTime.tryParse(request.createdAt ?? '');
      if (created == null) return _datePreset == OthersDatePreset.all;
      final range = _dateRange();
      if (range == null) return true;
      return !created.isBefore(range.start) && !created.isAfter(range.end);
    }).toList();
  }

  DateTimeRange? _dateRange() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    switch (_datePreset) {
      case OthersDatePreset.all:
        return null;
      case OthersDatePreset.today:
        return DateTimeRange(
          start: todayStart,
          end: todayStart
              .add(const Duration(days: 1))
              .subtract(const Duration(milliseconds: 1)),
        );
      case OthersDatePreset.yesterday:
        final start = todayStart.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: start,
          end: todayStart.subtract(const Duration(milliseconds: 1)),
        );
      case OthersDatePreset.week:
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 7)),
          end: now,
        );
      case OthersDatePreset.month:
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 30)),
          end: now,
        );
      case OthersDatePreset.custom:
        return _customRange;
    }
  }

  void bindUser(AppUser? user) {
    if (user?.id == _user?.id && user?.role == _user?.role) return;
    _user = user;
    _sub?.cancel();
    _requests = [];
    if (user == null) {
      notifyListeners();
      return;
    }
    _subscribe();
  }

  void _subscribe() {
    final user = _user;
    if (user == null) return;
    final stream = user.role == AppRole.admin
        ? _requestRepository.watchAll()
        : _requestRepository.watchForUser(user.id);
    _sub = stream.listen((requests) {
      _requests = requests;
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    _sub?.cancel();
    _subscribe();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setDatePreset(OthersDatePreset preset) {
    _datePreset = preset;
    if (preset != OthersDatePreset.custom) {
      _customRange = null;
    }
    notifyListeners();
  }

  void setCustomRange(DateTimeRange range) {
    _customRange = range;
    _datePreset = OthersDatePreset.custom;
    notifyListeners();
  }

  void setStatusFilter(SupportRequestStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  Stream<List<SupportRequestReply>> watchReplies(String requestId) {
    return _requestRepository.watchReplies(requestId);
  }

  Stream<SupportRequest?> watchById(String requestId) {
    return _requestRepository.watchById(requestId);
  }

  Future<Result<SupportRequest>> createRequest({
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    final user = _user;
    if (user == null) {
      return const FailureResult(AuthFailure('Not signed in'));
    }
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _requestRepository.createRequest(
      requester: user,
      title: title,
      description: description,
      imageUrl: imageUrl,
    );
    if (result case FailureResult(:final failure)) {
      _error = failure.message;
    }
    _isSubmitting = false;
    notifyListeners();
    return result;
  }

  Future<Result<SupportRequestReply>> reply({
    required SupportRequest request,
    required String message,
  }) async {
    final user = _user;
    if (user == null) {
      return const FailureResult(AuthFailure('Not signed in'));
    }
    _isSubmitting = true;
    notifyListeners();
    final result = await _requestRepository.addReply(
      request: request,
      sender: user,
      message: message,
    );
    _isSubmitting = false;
    notifyListeners();
    return result;
  }

  Future<Result<void>> updateStatus({
    required SupportRequest request,
    required SupportRequestStatus status,
  }) async {
    final user = _user;
    if (user == null) {
      return const FailureResult(AuthFailure('Not signed in'));
    }
    return _requestRepository.updateStatus(
      request: request,
      status: status,
      admin: user,
    );
  }

  Future<void> markRead(SupportRequest request) async {
    final user = _user;
    if (user == null) return;
    final asAdmin = user.role == AppRole.admin;
    final needs = asAdmin ? request.adminUnread : request.requesterUnread;
    if (!needs) return;
    await _requestRepository.markRead(
      requestId: request.id,
      asAdmin: asAdmin,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
