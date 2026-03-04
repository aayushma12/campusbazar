import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/forgot_password_provider.dart';
import '../providers/forgot_password_state.dart';
import '../widgets/password_rules_hint.dart';
import '../widgets/recovery_text_field.dart';

class ResetPasswordFeaturePage extends ConsumerStatefulWidget {
  final String email;
  final String? otpOrToken;

  const ResetPasswordFeaturePage({
    super.key,
    required this.email,
    this.otpOrToken,
  });

  @override
  ConsumerState<ResetPasswordFeaturePage> createState() => _ResetPasswordFeaturePageState();
}

class _ResetPasswordFeaturePageState extends ConsumerState<ResetPasswordFeaturePage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpOrTokenController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _otpOrTokenController.text = widget.otpOrToken ?? '';
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpOrTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ForgotPasswordState>(forgotPasswordNotifierProvider, (previous, next) {
      if (!mounted) return;

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }

      if (next.successMessage != null && next.successMessage!.isNotEmpty &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: Colors.green),
        );
      }

      if (next.resetStatus == ResetPasswordStateStatus.success) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });

    final state = ref.watch(forgotPasswordNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/forgot', (route) => false);
            }
          },
        ),
        title: const Text('Reset Password'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Reset password for ${widget.email}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            RecoveryTextField(
              controller: _otpOrTokenController,
              label: 'OTP / Reset Token',
              hint: 'Enter OTP or token',
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return 'OTP or token is required';
                return null;
              },
            ),
            const SizedBox(height: 14),
            const PasswordRulesHint(),
            const SizedBox(height: 14),
            RecoveryTextField(
              controller: _newPasswordController,
              label: 'New Password',
              hint: 'Enter new password',
              obscureText: _obscureNew,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
              ),
              validator: (value) {
                final v = (value ?? '').trim();
                if (v.isEmpty) return 'New password is required';
                if (v.length < 8) return 'Minimum 8 characters required';
                final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
                final hasNumber = RegExp(r'\d').hasMatch(v);
                if (!hasLetter || !hasNumber) return 'Include letters and numbers';
                return null;
              },
            ),
            const SizedBox(height: 14),
            RecoveryTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Re-enter new password',
              obscureText: _obscureConfirm,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
              ),
              validator: (value) {
                final v = (value ?? '').trim();
                if (v.isEmpty) return 'Confirm password is required';
                if (v != _newPasswordController.text.trim()) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        await ref.read(forgotPasswordNotifierProvider.notifier).resetPassword(
                              email: widget.email,
                              newPassword: _newPasswordController.text.trim(),
                              confirmPassword: _confirmPasswordController.text.trim(),
                              otpOrToken: _otpOrTokenController.text.trim(),
                            );
                      },
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Reset Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
