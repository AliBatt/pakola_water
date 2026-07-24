import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onSignUp,
  });

  static const String logoAsset = 'assets/images/logo.png';

  /// When set, shows a "Create an account" action (customer app).
  final VoidCallback? onSignUp;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (!success && auth.errorMessage != null) {
      AppSnackBar.error(context, auth.errorMessage!);
    }
  }

  void _onForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      AppSnackBar.warning(context, 'Enter your email first');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordResetEmail(email);
    if (!mounted) return;
    if (success) {
      AppSnackBar.success(
        context,
        'Password reset email sent. Check your inbox.',
      );
    } else if (auth.errorMessage != null) {
      AppSnackBar.error(context, auth.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = context.l10n;
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    Center(
                      child: Image.asset(
                        LoginScreen.logoAsset,
                        height: 96,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: context.texts.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      labelText: l10n.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      prefix: Icon(Icons.email_outlined, color: colors.onSurfaceVariant),
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.emailRequired;
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return l10n.emailInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      labelText: l10n.password,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      prefix: Icon(Icons.lock_outline, color: colors.onSurfaceVariant),
                      suffix: IconButton(
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: colors.onSurfaceVariant,
                        ),
                        tooltip: _obscurePassword ? l10n.password : l10n.password,
                      ),
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.passwordRequired;
                        }
                        if (value.length < 6) {
                          return l10n.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: auth.isLoading ? null : _onForgotPassword,
                        child: Text(l10n.forgotPassword),
                      ),
                    ),
                    if (auth.errorMessage != null) ...[
                      Text(
                        auth.errorMessage!,
                        textAlign: TextAlign.center,
                        style: context.texts.bodyMedium?.copyWith(
                          color: colors.error,
                        ),
                      ),
                    ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
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
                            : Text(l10n.login),
                      ),
                    ),
                    if (widget.onSignUp != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: auth.isLoading ? null : widget.onSignUp,
                        child: Text(context.l10n.createAccount),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
