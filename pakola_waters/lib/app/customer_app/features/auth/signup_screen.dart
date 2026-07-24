import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:repositories/repositories.dart';
import 'package:shared_widgets/shared_widgets.dart';

import 'customer_location_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _addressController = TextEditingController();

  String _phone = '';
  GeoLocation? _location;
  List<Branch> _branches = [];
  String? _selectedBranchId;
  String? _nearestBranchId;
  bool _loadingBranches = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBranches());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    final result = await context.read<BranchRepository>().listBranches();
    if (!mounted) return;
    switch (result) {
      case Success<List<Branch>>(:final value):
        final active = value
            .where((branch) => branch.status == BranchStatus.active)
            .toList();
        setState(() {
          _branches = active;
          _loadingBranches = false;
        });
        if (_location != null) {
          _recommendNearest(_location!);
        }
      case FailureResult<List<Branch>>(:final failure):
        setState(() => _loadingBranches = false);
        AppSnackBar.error(context, failure.message);
    }
  }

  void _recommendNearest(GeoLocation location) {
    Branch? nearest;
    var nearestDistance = double.infinity;
    for (final branch in _branches) {
      final branchLocation = branch.location;
      if (branchLocation == null) continue;
      final distance = haversineKm(
        lat1: location.latitude,
        lng1: location.longitude,
        lat2: branchLocation.latitude,
        lng2: branchLocation.longitude,
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = branch;
      }
    }
    if (nearest == null) return;
    setState(() {
      _nearestBranchId = nearest!.id;
      _selectedBranchId ??= nearest.id;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_phone.trim().isEmpty) {
      AppSnackBar.warning(context, 'Phone is required');
      return;
    }
    if (_location == null) {
      AppSnackBar.warning(context, 'Set your delivery location on the map');
      return;
    }
    if (_selectedBranchId == null) {
      AppSnackBar.warning(context, 'Select a branch');
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      AppSnackBar.warning(context, 'Wait for location to resolve an address');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signUpCustomer(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
      phone: _phone.trim(),
      address: _addressController.text.trim(),
      location: _location!,
      primaryBranchId: _selectedBranchId!,
    );

    if (!mounted) return;
    if (success) {
      AppSnackBar.success(context, 'Account created');
      context.go(AuthRoutes.home);
    } else if (auth.errorMessage != null) {
      AppSnackBar.error(context, auth.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AuthRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppTextField(
                controller: _nameController,
                labelText: 'Full name',
                textInputAction: TextInputAction.next,
                prefix: Icon(Icons.person_outline, color: colors.onSurfaceVariant),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppPhoneField(
                labelText: 'Phone',
                onChanged: (value) => _phone = value.completeNumber,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefix: Icon(Icons.email_outlined, color: colors.onSurfaceVariant),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                prefix: Icon(Icons.lock_outline, color: colors.onSurfaceVariant),
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _confirmController,
                labelText: 'Confirm password',
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.next,
                prefix: Icon(Icons.lock_outline, color: colors.onSurfaceVariant),
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              CustomerLocationPicker(
                onChanged: (location) {
                  _location = location;
                  _recommendNearest(location);
                },
                onAddressResolved: (address) {
                  _addressController.text = address;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _addressController,
                labelText: 'Address (from location)',
                readOnly: true,
                prefix: Icon(Icons.home_outlined, color: colors.onSurfaceVariant),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Location address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Branch',
                style: context.texts.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_loadingBranches)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_branches.isEmpty)
                Text(
                  'No active branches available',
                  style: TextStyle(color: colors.error),
                )
              else
                ..._branches.map((branch) {
                  final isNearest = branch.id == _nearestBranchId;
                  final distance = _location != null && branch.location != null
                      ? haversineKm(
                          lat1: _location!.latitude,
                          lng1: _location!.longitude,
                          lat2: branch.location!.latitude,
                          lng2: branch.location!.longitude,
                        )
                      : null;
                  return RadioListTile<String>(
                    value: branch.id,
                    groupValue: _selectedBranchId,
                    onChanged: (value) =>
                        setState(() => _selectedBranchId = value),
                    title: Row(
                      children: [
                        Expanded(child: Text(branch.name)),
                        if (isNearest)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Recommended',
                              style: context.texts.labelSmall?.copyWith(
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      [
                        if (branch.address != null) branch.address!,
                        if (distance != null)
                          '${distance.toStringAsFixed(1)} km away',
                      ].where((e) => e.isNotEmpty).join(' · '),
                    ),
                  );
                }),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
                      : const Text('Create account'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
