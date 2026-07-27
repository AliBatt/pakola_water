import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:repositories/repositories.dart';
import 'package:shared_widgets/shared_widgets.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _searchController = TextEditingController();

  AppRole _role = AppRole.customer;
  List<AppUser> _recipients = [];
  List<AppUser> _filtered = [];
  String? _selectedUserId;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRecipients);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecipients());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipients() async {
    setState(() {
      _loading = true;
      _selectedUserId = null;
    });

    final result =
        await context.read<UserRepository>().listByRole(_role);
    if (!mounted) return;

    switch (result) {
      case Success<List<AppUser>>(:final value):
        setState(() {
          _recipients = value
            ..sort((a, b) => a.displayName.compareTo(b.displayName));
          _filtered = _recipients;
          _loading = false;
        });
        _filterRecipients();
      case FailureResult<List<AppUser>>(:final failure):
        setState(() => _loading = false);
        AppSnackBar.error(context, failure.message);
    }
  }

  void _filterRecipients() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? _recipients
          : _recipients.where((user) {
              return user.displayName.toLowerCase().contains(query) ||
                  user.email.toLowerCase().contains(query) ||
                  (user.phone ?? '').contains(query);
            }).toList();
    });
  }

  String _roleLabel(AppRole role) {
    switch (role) {
      case AppRole.customer:
        return 'Customer';
      case AppRole.supervisor:
        return 'Supervisor';
      case AppRole.driver:
        return 'Rider';
      case AppRole.admin:
        return 'Admin';
    }
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUserId == null) {
      AppSnackBar.warning(context, 'Select a recipient');
      return;
    }

    final sender = context.read<AuthProvider>().user;
    if (sender == null) return;

    setState(() => _sending = true);
    final result =
        await context.read<NotificationRepository>().createNotification(
              AppNotification(
                id: '',
                userId: _selectedUserId!,
                title: _titleController.text.trim(),
                body: _bodyController.text.trim(),
                createdById: sender.id,
                createdByRole: sender.role.name,
                createdByName: sender.displayName,
                type: 'admin_message',
              ),
            );
    if (!mounted) return;
    setState(() => _sending = false);

    switch (result) {
      case Success():
        AppSnackBar.success(context, context.l10n.notificationSent);
        _titleController.clear();
        _bodyController.clear();
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              l10n.sendNotification,
              style: context.texts.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Send a message to any customer, supervisor, or rider. They will see it in their notifications.',
              style: context.texts.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SegmentedButton<AppRole>(
              segments: const [
                ButtonSegment(
                  value: AppRole.customer,
                  label: Text('Customers'),
                  icon: Icon(Icons.person_outline),
                ),
                ButtonSegment(
                  value: AppRole.supervisor,
                  label: Text('Supervisors'),
                  icon: Icon(Icons.supervisor_account_outlined),
                ),
                ButtonSegment(
                  value: AppRole.driver,
                  label: Text('Riders'),
                  icon: Icon(Icons.delivery_dining_outlined),
                ),
              ],
              selected: {_role},
              onSelectionChanged: (selection) {
                _role = selection.first;
                _loadRecipients();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              AppTextField(
                controller: _searchController,
                labelText: 'Search ${_roleLabel(_role).toLowerCase()}',
                prefix: const Icon(Icons.search),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                value: _selectedUserId,
                decoration: InputDecoration(
                  labelText: 'Select ${_roleLabel(_role).toLowerCase()}',
                ),
                items: _filtered
                    .map(
                      (user) => DropdownMenuItem(
                        value: user.id,
                        child: Text('${user.displayName} (${user.email})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedUserId = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select a recipient';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _titleController,
              labelText: l10n.notificationTitle,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.notificationTitle;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _bodyController,
              labelText: l10n.notificationBody,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.notificationBody;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _sending || _loading ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(l10n.sendNotification),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
