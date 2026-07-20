import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:shared_widgets/shared_widgets.dart';

import 'widgets/branch_location_picker.dart';
import 'branches_controller.dart';

Future<void> showBranchFormDialog({
  required BuildContext context,
  required BranchesController controller,
  Branch? branch,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => BranchFormDialog(
      controller: controller,
      branch: branch,
    ),
  );
}

class BranchFormDialog extends StatefulWidget {
  const BranchFormDialog({
    super.key,
    required this.controller,
    this.branch,
  });

  final BranchesController controller;
  final Branch? branch;

  @override
  State<BranchFormDialog> createState() => _BranchFormDialogState();
}

class _BranchFormDialogState extends State<BranchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  BranchStatus _status = BranchStatus.active;
  String? _supervisorId;
  List<String> _riderIds = [];
  GeoLocation? _location;
  bool _saving = false;

  bool get _isEditing => widget.branch != null;

  @override
  void initState() {
    super.initState();
    final branch = widget.branch;
    if (branch != null) {
      _nameController.text = branch.name;
      _codeController.text = branch.code;
      _addressController.text = branch.address ?? '';
      _cityController.text = branch.city ?? '';
      _phoneController.text = branch.phone ?? '';
      _emailController.text = branch.email ?? '';
      _notesController.text = branch.notes ?? '';
      _status = branch.status;
      _supervisorId = branch.supervisorId;
      _riderIds = List<String>.from(branch.riderIds);
      _location = branch.location;
    } else {
      _location = BranchLocationPicker.defaultCenter;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_supervisorId == null) {
      AppSnackBar.error(context, 'Supervisor is required for a branch');
      return;
    }
    if (_location == null) {
      AppSnackBar.error(context, 'Select a branch location on the map');
      return;
    }

    setState(() => _saving = true);

    final draft = Branch(
      id: widget.branch?.id ?? '',
      name: _nameController.text.trim(),
      code: _codeController.text.trim().toUpperCase(),
      status: _status,
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      location: _location,
      supervisorId: _supervisorId,
      riderIds: _riderIds,
    );

    final result = _isEditing
        ? await widget.controller.update(draft)
        : await widget.controller.create(draft);

    if (!mounted) return;
    setState(() => _saving = false);

    switch (result) {
      case Success():
        Navigator.of(context).pop();
        AppSnackBar.success(
          context,
          _isEditing ? 'Branch updated' : 'Branch created',
        );
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final supervisors = widget.controller.supervisors;
    final riders = widget.controller.riders;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 820),
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
                        _isEditing ? 'Edit branch' : 'Create branch',
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _nameController,
                          labelText: 'Branch name *',
                          prefix: const Icon(Icons.store_outlined),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Branch name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _codeController,
                          labelText: 'Branch code *',
                          prefix: const Icon(Icons.tag),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Branch code is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        BranchLocationPicker(
                          initial: _location,
                          initialQuery: _addressController.text,
                          onChanged: (value) =>
                              setState(() => _location = value),
                          onAddressSelected: (address) {
                            setState(() {
                              _addressController.text = address;
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          value: _supervisorId,
                          decoration: const InputDecoration(
                            labelText: 'Supervisor *',
                          ),
                          items: supervisors
                              .map(
                                (user) => DropdownMenuItem(
                                  value: user.id,
                                  child: Text(user.displayName),
                                ),
                              )
                              .toList(),
                          onChanged: supervisors.isEmpty
                              ? null
                              : (value) =>
                                  setState(() => _supervisorId = value),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Select a supervisor';
                            }
                            return null;
                          },
                        ),
                        if (supervisors.isEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Create an active supervisor before creating a branch.',
                            style: context.texts.bodySmall?.copyWith(
                              color: context.colors.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Branch riders (optional)',
                            style: context.texts.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (riders.isEmpty)
                          Text(
                            'No riders available yet.',
                            style: context.texts.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: riders.map((rider) {
                              final selected = _riderIds.contains(rider.id);
                              return FilterChip(
                                label: Text(rider.displayName),
                                selected: selected,
                                onSelected: (value) {
                                  setState(() {
                                    if (value) {
                                      _riderIds = [..._riderIds, rider.id];
                                    } else {
                                      _riderIds = _riderIds
                                          .where((id) => id != rider.id)
                                          .toList();
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _addressController,
                          labelText: 'Street address',
                          prefix: const Icon(Icons.location_on_outlined),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _cityController,
                          labelText: 'City',
                          prefix: const Icon(Icons.location_city_outlined),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _phoneController,
                          labelText: 'Branch phone',
                          keyboardType: TextInputType.phone,
                          prefix: const Icon(Icons.phone_outlined),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _emailController,
                          labelText: 'Branch email',
                          keyboardType: TextInputType.emailAddress,
                          prefix: const Icon(Icons.email_outlined),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<BranchStatus>(
                          value: _status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: BranchStatus.active,
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: BranchStatus.inactive,
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
                        onPressed: _saving || supervisors.isEmpty
                            ? null
                            : _submit,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
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
