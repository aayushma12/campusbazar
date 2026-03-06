import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/forgot_password_provider.dart';
import '../providers/forgot_password_state.dart';
import '../widgets/recovery_text_field.dart';
import 'reset_password_page.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String email;

  const OtpVerificationPage({super.key, required this.email});

  @override
  ConsumerState<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
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

      if (next.forgotStatus == ForgotPasswordStateStatus.verified && next.otpOrToken != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => ResetPasswordFeaturePage(
              email: widget.email,
              otpOrToken: next.otpOrToken,
            ),
          ),
        );
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
        title: const Text('Verify OTP'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Enter the OTP sent to ${widget.email}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            RecoveryTextField(
              controller: _otpController,
              label: 'OTP',
              hint: 'Enter 6-digit OTP',
              keyboardType: TextInputType.number,
              validator: (value) {
                final v = (value ?? '').trim();
                if (v.isEmpty) return 'OTP is required';
                if (v.length < 4) return 'Enter a valid OTP';
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
                        await ref.read(forgotPasswordNotifierProvider.notifier).verifyOtp(
                              widget.email,
                              _otpController.text.trim(),
                            );
                      },
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify OTP'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      await ref.read(forgotPasswordNotifierProvider.notifier).requestPasswordReset(widget.email);
                    },
              child: const Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
