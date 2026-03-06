import 'package:flutter/material.dart';

import '../../forgot_password/presentation/pages/reset_password_page.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String email = '';
    String? otpOrToken;

    if (args is Map<String, dynamic>) {
      email = args['email']?.toString() ?? '';
      otpOrToken = args['otpOrToken']?.toString();
    }

    return ResetPasswordFeaturePage(
      email: email,
      otpOrToken: otpOrToken,
    );
  }
}
