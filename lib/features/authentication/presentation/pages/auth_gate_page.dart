import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../state/auth_state.dart';
import 'login_page.dart';

/// Simple auth gate:
/// - loading/initial => splash-like loader
/// - unauthenticated => login screen
/// - authenticated => minimal success UI (replace with dashboard route as needed)
class AuthenticationGatePage extends ConsumerWidget {
  const AuthenticationGatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authNotifierProvider);

    if (state.status == AuthStatus.initial || state.status == AuthStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == AuthStatus.authenticated && state.user != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Authenticated')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hello, ${state.user!.name}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(state.user!.email),
                const SizedBox(height: 20),
                FilledButton.tonal(
                  onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const AuthenticationLoginPage();
  }
}
