import 'package:flutter/material.dart';

class PasswordRulesHint extends StatelessWidget {
  const PasswordRulesHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Use at least 8 characters, including one letter and one number.',
        style: TextStyle(fontSize: 13),
      ),
    );
  }
}
