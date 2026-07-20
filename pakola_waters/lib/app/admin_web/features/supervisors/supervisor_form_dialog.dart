import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:services/services.dart';
import 'package:shared_widgets/shared_widgets.dart';

import 'supervisors_controller.dart';

Future<void> showSupervisorFormDialog({
  required BuildContext context,
  required SupervisorsController controller,
  AppUser? supervisor,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => SupervisorFormDialog(
      controller: controller,
      supervisor: supervisor,
    ),
  );
}

class SupervisorFormDialog extends StatefulWidget {
  const SupervisorFormDialog({
    super.key,
    required this.controller,
    this.supervisor,
  });

  final SupervisorsController controller;
  final AppUser? supervisor;

  @override
  State<SupervisorFormDialog> createState() => _SupervisorFormDialogState();
}

class _SupervisorFormDialogState extends State<SupervisorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String? _phoneE164;
  UserStatus _status = UserStatus.active;
  String? _branchId;
  bool _saving = false;

  bool get _isEditing => widget.supervisor != null;

  @override
  void initState() {
    super.initState();
    final user = widget.supervisor;
    if (user != null) {
      _nameController.text = user.displayName;
      _emailController.text = user.email;
      _addressController.text = user.address ?? '';
      _notesController.text = user.notes ?? '';
      _phoneE164 = user.phone;
      _status = user.status == UserStatus.suspended
          ? UserStatus.inactive
          : user.status;
      _branchId = user.primaryBranchId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_phoneE164 == null || _phoneE164!.trim().isEmpty) {
      AppSnackBar.error(context, 'Phone number is required');
      return;
    }

    setState(() => _saving = true);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();
    final notes = _notesController.text.trim();

    if (_isEditing) {
      final updated = widget.supervisor!.copyWith(
        displayName: name,
        email: email.isEmpty ? widget.supervisor!.email : email,
        phone: _phoneE164,
        address: address.isEmpty ? null : address,
        notes: notes.isEmpty ? null : notes,
        status: _status,
        primaryBranchId: _branchId,
        clearPrimaryBranch: _branchId == null,
        branchIds: _branchId == null ? const [] : [_branchId!],
      );
      final result = await widget.controller.update(updated);
      if (!mounted) return;
      setState(() => _saving = false);
      switch (result) {
        case Success():
          Navigator.of(context).pop();
          AppSnackBar.success(context, 'Supervisor updated');
        case FailureResult(:final failure):
          AppSnackBar.error(context, failure.message);
      }
      return;
    }

    final result = await widget.controller.create(
      displayName: name,
      phone: _phoneE164!,
      email: email.isEmpty ? null : email,
      address: address.isEmpty ? null : address,
      notes: notes.isEmpty ? null : notes,
      status: _status,
      primaryBranchId: _branchId,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    switch (result) {
      case Success<CreateUserAccountResult>(:final value):
        Navigator.of(context).pop();
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supervisor created'),
            content: Text(
              'Login email: ${value.user.email}\n'
              'Temporary password: ${value.temporaryPassword}'
              '${value.generatedEmail ? '\n\n(Email was auto-generated from phone)' : ''}',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      case FailureResult<CreateUserAccountResult>(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branches = widget.controller.branches;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? 'Edit supervisor' : 'Create supervisor',
                        style: context.texts.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _nameController,
                          labelText: 'Name *',
                          textCapitalization: TextCapitalization.words,
                          prefix: const Icon(Icons.person_outline),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppPhoneField(
                          initialValue: _phoneE164,
                          labelText: 'Phone number *',
                          onChanged: (phone) {
                            _phoneE164 = phone.completeNumber;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _emailController,
                          labelText: 'Email (optional)',
                          keyboardType: TextInputType.emailAddress,
                          prefix: const Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                .hasMatch(value.trim());
                            return ok ? null : 'Enter a valid email';
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String?>(
                          value: _branchId,
                          decoration: const InputDecoration(
                            labelText: 'Branch (optional)',
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('No branch assigned'),
                            ),
                            ...branches.map(
                              (branch) => DropdownMenuItem<String?>(
                                value: branch.id,
                                child: Text(branch.name),
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _branchId = value),
                        ),
                        if (branches.isEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'No branches yet — you can assign one later.',
                            style: context.texts.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _addressController,
                          labelText: 'Living address',
                          maxLines: 2,
                          prefix: const Icon(Icons.home_outlined),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<UserStatus>(
                          value: _status == UserStatus.suspended
                              ? UserStatus.inactive
                              : (_status == UserStatus.pending
                                  ? UserStatus.active
                                  : _status),
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: UserStatus.active,
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: UserStatus.inactive,
                              child: Text('Inactive'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _status = value);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _notesController,
                          labelText: 'Notes',
                          maxLines: 3,
                          prefix: const Icon(Icons.notes_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_isEditing ? 'Save' : 'Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
