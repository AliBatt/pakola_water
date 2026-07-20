import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:models/models.dart';
import 'package:services/services.dart';
import 'package:shared_widgets/shared_widgets.dart';

import 'riders_controller.dart';

Future<void> showRiderFormDialog({
  required BuildContext context,
  required RidersController controller,
  AppUser? rider,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => RiderFormDialog(
      controller: controller,
      rider: rider,
    ),
  );
}

class RiderFormDialog extends StatefulWidget {
  const RiderFormDialog({
    super.key,
    required this.controller,
    this.rider,
  });

  final RidersController controller;
  final AppUser? rider;

  @override
  State<RiderFormDialog> createState() => _RiderFormDialogState();
}

class _RiderFormDialogState extends State<RiderFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cnicController = TextEditingController();
  final _experienceController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _notesController = TextEditingController();

  String? _phoneE164;
  UserStatus _status = UserStatus.active;
  List<String> _branchIds = [];
  bool _saving = false;

  bool get _isEditing => widget.rider != null;

  @override
  void initState() {
    super.initState();
    final rider = widget.rider;
    if (rider != null) {
      _nameController.text = rider.displayName;
      _emailController.text = rider.email;
      _addressController.text = rider.address ?? '';
      _cnicController.text = rider.cnic ?? '';
      _experienceController.text = rider.experience ?? '';
      _vehicleController.text = rider.vehiclePlate ?? '';
      _notesController.text = rider.notes ?? '';
      _phoneE164 = rider.phone;
      _status = rider.status == UserStatus.suspended
          ? UserStatus.inactive
          : rider.status;
      _branchIds = List<String>.from(rider.branchIds);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cnicController.dispose();
    _experienceController.dispose();
    _vehicleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_phoneE164 == null || _phoneE164!.trim().isEmpty) {
      AppSnackBar.error(context, 'Phone number is required');
      return;
    }
    if (_branchIds.isEmpty) {
      AppSnackBar.error(context, 'Select at least one preferred branch');
      return;
    }

    setState(() => _saving = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();
    final cnic = _cnicController.text.trim();
    final experience = _experienceController.text.trim();
    final vehicle = _vehicleController.text.trim();
    final notes = _notesController.text.trim();

    if (_isEditing) {
      final updated = widget.rider!.copyWith(
        displayName: name,
        email: email.isEmpty ? widget.rider!.email : email,
        phone: _phoneE164,
        address: address.isEmpty ? null : address,
        cnic: cnic.isEmpty ? null : cnic,
        experience: experience.isEmpty ? null : experience,
        vehiclePlate: vehicle.isEmpty ? null : vehicle,
        notes: notes.isEmpty ? null : notes,
        status: _status,
        branchIds: _branchIds,
        primaryBranchId: _branchIds.first,
      );
      final result = await widget.controller.update(updated);
      if (!mounted) return;
      setState(() => _saving = false);
      switch (result) {
        case Success():
          Navigator.of(context).pop();
          AppSnackBar.success(context, 'Rider updated');
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
      cnic: cnic.isEmpty ? null : cnic,
      experience: experience.isEmpty ? null : experience,
      vehiclePlate: vehicle.isEmpty ? null : vehicle,
      notes: notes.isEmpty ? null : notes,
      status: _status,
      branchIds: _branchIds,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    switch (result) {
      case Success<CreateUserAccountResult>(:final value):
        Navigator.of(context).pop();
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Rider created'),
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
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
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
                        _isEditing ? 'Edit rider' : 'Create rider',
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
                          labelText: 'Rider name *',
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
                        AppTextField(
                          controller: _addressController,
                          labelText: 'Address (where from) *',
                          maxLines: 2,
                          prefix: const Icon(Icons.home_outlined),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Address is required';
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
                        AppTextField(
                          controller: _cnicController,
                          labelText: 'CNIC *',
                          keyboardType: TextInputType.number,
                          prefix: const Icon(Icons.badge_outlined),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                            LengthLimitingTextInputFormatter(15),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'CNIC is required';
                            }
                            final digits =
                                value.replaceAll(RegExp(r'[^0-9]'), '');
                            if (digits.length != 13) {
                              return 'Enter a valid 13-digit CNIC';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Preferred branches *',
                          style: context.texts.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (branches.isEmpty)
                          Text(
                            'No branches available yet. Create a branch first.',
                            style: context.texts.bodySmall?.copyWith(
                              color: context.colors.error,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: branches.map((branch) {
                              final selected =
                                  _branchIds.contains(branch.id);
                              return FilterChip(
                                label: Text(branch.name),
                                selected: selected,
                                onSelected: (value) {
                                  setState(() {
                                    if (value) {
                                      _branchIds = [..._branchIds, branch.id];
                                    } else {
                                      _branchIds = _branchIds
                                          .where((id) => id != branch.id)
                                          .toList();
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _experienceController,
                          labelText: 'Experience',
                          hintText: 'e.g. 2 years delivery experience',
                          prefix: const Icon(Icons.work_history_outlined),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _vehicleController,
                          labelText: 'Vehicle plate (optional)',
                          textCapitalization: TextCapitalization.characters,
                          prefix: const Icon(Icons.two_wheeler),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<UserStatus>(
                          value: _status == UserStatus.pending
                              ? UserStatus.active
                              : (_status == UserStatus.suspended
                                  ? UserStatus.inactive
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
                        onPressed: _saving || branches.isEmpty ? null : _submit,
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
