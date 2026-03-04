import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/forgot_password_provider.dart';
import '../providers/forgot_password_state.dart';
import '../widgets/recovery_text_field.dart';
import 'otp_verification_page.dart';

class ForgotPasswordFeaturePage extends ConsumerStatefulWidget {
  const ForgotPasswordFeaturePage({super.key});

  @override
  ConsumerState<ForgotPasswordFeaturePage> createState() => _ForgotPasswordFeaturePageState();
}

class _ForgotPasswordFeaturePageState extends ConsumerState<ForgotPasswordFeaturePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cachedEmail = ref.read(forgotPasswordNotifierProvider).email;
      if (cachedEmail.isNotEmpty) {
        _emailController.text = cachedEmail;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
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

      if (next.forgotStatus == ForgotPasswordStateStatus.otpSent) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => OtpVerificationPage(email: _emailController.text.trim()),
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
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            }
          },
        ),
        title: const Text('Forgot Password'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            const Text(
              'Enter your email to receive an OTP or reset link.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            RecoveryTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'example@university.edu',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final v = (value ?? '').trim();
                if (v.isEmpty) return 'Email is required';
                const pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
                if (!RegExp(pattern).hasMatch(v)) return 'Enter a valid email';
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
                        await ref.read(forgotPasswordNotifierProvider.notifier)
                            .requestPasswordReset(_emailController.text.trim());
                      },
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
