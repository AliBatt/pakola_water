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

  List<AppUser> _customers = [];
  String? _selectedCustomerId;
  bool _loadingCustomers = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCustomers());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    final result =
        await context.read<UserRepository>().listByRole(AppRole.customer);
    if (!mounted) return;
    switch (result) {
      case Success<List<AppUser>>(:final value):
        setState(() {
          _customers = value
            ..sort((a, b) => a.displayName.compareTo(b.displayName));
          _loadingCustomers = false;
        });
      case FailureResult<List<AppUser>>(:final failure):
        setState(() => _loadingCustomers = false);
        AppSnackBar.error(context, failure.message);
    }
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) {
      AppSnackBar.warning(context, context.l10n.selectCustomer);
      return;
    }

    final sender = context.read<AuthProvider>().user;
    if (sender == null) return;

    setState(() => _sending = true);
    final result = await context.read<NotificationRepository>().createNotification(
          AppNotification(
            id: '',
            userId: _selectedCustomerId!,
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
            createdById: sender.id,
            createdByRole: sender.role.name,
            createdByName: sender.displayName,
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
              'Send a message to a customer. Supervisors and riders can also create notifications via the shared API.',
              style: context.texts.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_loadingCustomers)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedCustomerId,
                decoration: InputDecoration(labelText: l10n.selectCustomer),
                items: _customers
                    .map(
                      (customer) => DropdownMenuItem(
                        value: customer.id,
                        child: Text(
                          '${customer.displayName} (${customer.email})',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCustomerId = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.selectCustomer;
                  }
                  return null;
                },
              ),
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
                onPressed: _sending ? null : _send,
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
