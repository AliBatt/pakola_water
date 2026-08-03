import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import '../widgets/storage_network_image.dart';
import 'support_request_status_l10n.dart';
import 'support_requests_controller.dart';

Future<void> showSupportRequestDetailSheet({
  required BuildContext context,
  required SupportRequest request,
  bool isAdminView = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => SupportRequestDetailSheet(
      requestId: request.id,
      fallback: request,
      isAdminView: isAdminView,
    ),
  );
}

class SupportRequestDetailSheet extends StatefulWidget {
  const SupportRequestDetailSheet({
    super.key,
    required this.requestId,
    required this.fallback,
    this.isAdminView = false,
  });

  final String requestId;
  final SupportRequest fallback;
  final bool isAdminView;

  @override
  State<SupportRequestDetailSheet> createState() =>
      _SupportRequestDetailSheetState();
}

class _SupportRequestDetailSheetState extends State<SupportRequestDetailSheet> {
  final _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportRequestsController>().markRead(widget.fallback);
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply(SupportRequest request) async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    final controller = context.read<SupportRequestsController>();
    final result = await controller.reply(request: request, message: text);
    if (!mounted) return;
    switch (result) {
      case Success():
        _replyController.clear();
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  Future<void> _setStatus(
    SupportRequest request,
    SupportRequestStatus status,
  ) async {
    final l10n = context.l10n;
    final result = await context.read<SupportRequestsController>().updateStatus(
          request: request,
          status: status,
        );
    if (!mounted) return;
    switch (result) {
      case Success():
        AppSnackBar.success(
          context,
          l10n.markedAsStatus(status.localizedLabel(l10n)),
        );
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = context.watch<SupportRequestsController>();
    final height = MediaQuery.sizeOf(context).height * 0.92;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return SizedBox(
      height: height,
      child: StreamBuilder<SupportRequest?>(
        stream: controller.watchById(widget.requestId),
        initialData: widget.fallback,
        builder: (context, snapshot) {
          final request = snapshot.data ?? widget.fallback;
          final canReply = request.status.isOpen;
          final statusLabel = request.status.localizedLabel(l10n);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.title,
                            style: context.texts.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Chip(label: Text(statusLabel)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      [
                        request.createdByName,
                        request.roleLabel,
                        DateTimeFormatter.formatLong(request.createdAt),
                      ].join(' · '),
                      style: context.texts.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(request.description),
                    if (request.imageUrl != null &&
                        request.imageUrl!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        child: StorageNetworkImage(
                          url: request.imageUrl!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    if (widget.isAdminView) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.adminActions,
                        style: context.texts.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          if (request.status == SupportRequestStatus.open)
                            OutlinedButton(
                              onPressed: () => _setStatus(
                                request,
                                SupportRequestStatus.inProgress,
                              ),
                              child: Text(l10n.markInProgress),
                            ),
                          OutlinedButton(
                            onPressed: request.status.isTerminal
                                ? null
                                : () => _setStatus(
                                      request,
                                      SupportRequestStatus.completed,
                                    ),
                            child: Text(l10n.completeAction),
                          ),
                          OutlinedButton(
                            onPressed: request.status.isTerminal
                                ? null
                                : () => _setStatus(
                                      request,
                                      SupportRequestStatus.rejected,
                                    ),
                            child: Text(l10n.rejectAction),
                          ),
                          OutlinedButton(
                            onPressed: request.status.isTerminal
                                ? null
                                : () => _setStatus(
                                      request,
                                      SupportRequestStatus.closed,
                                    ),
                            child: Text(l10n.close),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: AppSpacing.xl),
                    Text(
                      l10n.conversation,
                      style: context.texts.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    StreamBuilder<List<SupportRequestReply>>(
                      stream: controller.watchReplies(request.id),
                      builder: (context, replySnap) {
                        final replies = replySnap.data ?? [];
                        if (replies.isEmpty) {
                          return Text(
                            l10n.noRepliesYet,
                            style: context.texts.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          );
                        }
                        return Column(
                          children: replies.map((reply) {
                            final mine = reply.isFromAdmin == widget.isAdminView;
                            return Align(
                              alignment: mine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.sizeOf(context).width * 0.8,
                                ),
                                decoration: BoxDecoration(
                                  color: mine
                                      ? context.colors.primaryContainer
                                      : context.colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${reply.createdByName} · ${reply.createdByRole}',
                                      style: context.texts.labelSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(reply.message),
                                    if (reply.createdAt != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        DateTimeFormatter.format(
                                          reply.createdAt,
                                        ),
                                        style: context.texts.labelSmall
                                            ?.copyWith(
                                          color:
                                              context.colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (canReply)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg + bottom,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _replyController,
                          labelText: l10n.writeAReply,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton.filled(
                        onPressed: controller.isSubmitting
                            ? null
                            : () => _sendReply(request),
                        icon: controller.isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    l10n.requestNoLongerAcceptsReplies(statusLabel),
                    style: context.texts.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
