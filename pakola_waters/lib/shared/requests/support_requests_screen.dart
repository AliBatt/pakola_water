import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import '../orders/others_date_preset.dart';
import 'create_support_request_sheet.dart';
import 'support_request_detail_sheet.dart';
import 'support_request_status_l10n.dart';
import 'support_requests_controller.dart';

class SupportRequestsScreen extends StatefulWidget {
  const SupportRequestsScreen({
    super.key,
    this.isAdminView = false,
    this.title,
    this.showCreateButton = true,
    this.showAppBar = true,
  });

  final bool isAdminView;
  final String? title;
  final bool showCreateButton;
  final bool showAppBar;

  @override
  State<SupportRequestsScreen> createState() => _SupportRequestsScreenState();
}

class _SupportRequestsScreenState extends State<SupportRequestsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomRange(SupportRequestsController controller) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: controller.customRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
    );
    if (picked != null) {
      controller.setCustomRange(
        DateTimeRange(
          start: picked.start.copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          ),
          end: picked.end.copyWith(
            hour: 23,
            minute: 59,
            second: 59,
            millisecond: 999,
            microsecond: 999,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = context.watch<SupportRequestsController>();
    final requests = controller.filteredRequests;
    if (_searchController.text != controller.search) {
      _searchController.value = TextEditingValue(
        text: controller.search,
        selection: TextSelection.collapsed(offset: controller.search.length),
      );
    }

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(widget.title ?? l10n.myRequests),
              actions: [
                if (widget.showCreateButton)
                  IconButton(
                    tooltip: l10n.newRequest,
                    onPressed: () => showCreateSupportRequestSheet(context),
                    icon: const Icon(Icons.add),
                  ),
              ],
            )
          : null,
      floatingActionButton: widget.showCreateButton
          ? FloatingActionButton.extended(
              onPressed: () => showCreateSupportRequestSheet(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.newRequest),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: controller.setSearch,
                  decoration: InputDecoration(
                    hintText: widget.isAdminView
                        ? l10n.searchRequestsAdmin
                        : l10n.searchYourRequests,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: controller.search.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              controller.setSearch('');
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final preset in OthersDatePreset.values)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: FilterChip(
                            label: Text(preset.label),
                            selected: controller.datePreset == preset,
                            onSelected: (_) {
                              if (preset == OthersDatePreset.custom) {
                                _pickCustomRange(controller);
                              } else {
                                controller.setDatePreset(preset);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text(l10n.allStatuses),
                        selected: controller.statusFilter == null,
                        onSelected: (_) => controller.setStatusFilter(null),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      for (final status in SupportRequestStatus.values)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: FilterChip(
                            label: Text(status.localizedLabel(l10n)),
                            selected: controller.statusFilter == status,
                            onSelected: (_) =>
                                controller.setStatusFilter(status),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: requests.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.45,
                          child: EmptyStateView(
                            title: l10n.noRequests,
                            subtitle: widget.isAdminView
                                ? l10n.noRequestsAdminSubtitle
                                : l10n.noRequestsSubtitle,
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: requests.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        final unread = widget.isAdminView
                            ? request.adminUnread
                            : request.requesterUnread;
                        final statusLabel = request.status.localizedLabel(l10n);
                        return Card(
                          child: ListTile(
                            onTap: () => showSupportRequestDetailSheet(
                              context: context,
                              request: request,
                              isAdminView: widget.isAdminView,
                            ),
                            leading: CircleAvatar(
                              child: Icon(
                                unread
                                    ? Icons.mark_email_unread_outlined
                                    : Icons.inbox_outlined,
                              ),
                            ),
                            title: Text(
                              request.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight:
                                    unread ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              [
                                if (widget.isAdminView)
                                  '${request.createdByName} (${request.roleLabel})',
                                statusLabel,
                                if (request.lastReplyPreview != null)
                                  request.lastReplyPreview!,
                                DateTimeFormatter.formatLong(request.createdAt),
                              ].join(' · '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: unread
                                ? Badge(
                                    child: Chip(
                                      label: Text(statusLabel),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                : Chip(
                                    label: Text(statusLabel),
                                    visualDensity: VisualDensity.compact,
                                  ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
