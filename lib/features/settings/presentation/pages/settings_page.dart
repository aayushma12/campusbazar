import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shake_theme_provider.dart';
import '../../../../core/providers/theme_mode_provider.dart';
import '../../../../core/services/service_locator.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(settingsNotifierProvider.notifier).loadSettings());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsNotifierProvider);
    final themeMode = ref.watch(themeModeProvider);
    final shakeEnabled = ref.watch(shakeToToggleProvider);

    ref.listen(settingsNotifierProvider, (previous, next) {
      if (!mounted) return;

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(settingsNotifierProvider.notifier).clearMessages();
      }

      if (next.successMessage != null && next.successMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: Colors.green),
        );
        ref.read(settingsNotifierProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: state.pushNotificationsEnabled,
                        onChanged: state.isSaving
                            ? null
                            : (value) {
                                ref.read(settingsNotifierProvider.notifier).setPushNotificationsEnabled(value);
                              },
                        secondary: const Icon(Icons.notifications_active_outlined),
                        title: const Text('Push Notifications'),
                        subtitle: const Text('Enable or disable push notifications from server.'),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: themeMode == ThemeMode.dark,
                        onChanged: (value) {
                          ref.read(themeModeProvider.notifier).toggleDarkMode(value);
                        },
                        secondary: const Icon(Icons.dark_mode_outlined),
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Apply dark theme across the app.'),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: shakeEnabled,
                        onChanged: (value) async {
                          await ref.read(shakeToToggleProvider.notifier).setEnabled(value);
                        },
                        secondary: const Icon(Icons.vibration_outlined),
                        title: const Text('Enable Shake to Toggle Dark Mode'),
                        subtitle: const Text('Shake device to switch between light and dark modes.'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: const Text('Change Password'),
                        subtitle: const Text('Update your account password securely.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: state.isSaving ? null : () => _showChangePasswordDialog(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                        subtitle: const Text('This action is permanent and cannot be undone.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: state.isSaving ? null : () => _showDeleteAccountFlow(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: currentController,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          suffixIcon: IconButton(
                            onPressed: () => setLocalState(() => obscureCurrent = !obscureCurrent),
                            icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty ? 'Current password is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: newController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          suffixIcon: IconButton(
                            onPressed: () => setLocalState(() => obscureNew = !obscureNew),
                            icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                        validator: (value) {
                          final password = (value ?? '').trim();
                          final strongPassword = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$');
                          if (password.isEmpty) return 'New password is required';
                          if (!strongPassword.hasMatch(password)) {
                            return 'Min 8 chars with upper, lower, number, special';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            onPressed: () => setLocalState(() => obscureConfirm = !obscureConfirm),
                            icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) return 'Please confirm your password';
                          if ((value ?? '').trim() != newController.text.trim()) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final ok = await ref.read(settingsNotifierProvider.notifier).changePassword(
                          currentPassword: currentController.text.trim(),
                          newPassword: newController.text.trim(),
                          confirmPassword: confirmController.text.trim(),
                        );
                    if (!context.mounted) return;
                    if (ok) Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

  Future<void> _showDeleteAccountFlow(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text('This action is permanent and cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    final passwordController = TextEditingController();
    bool obscurePassword = true;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Confirm Password'),
              content: TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () => setLocalState(() => obscurePassword = !obscurePassword),
                    icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final password = passwordController.text.trim();
                    if (password.isEmpty) return;

                    final ok = await ref.read(settingsNotifierProvider.notifier).deleteAccount(password: password);
                    if (!context.mounted) return;

                    if (ok) {
                      await sl<AuthLocalDataSource>().clearCache();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                    }
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );

    passwordController.dispose();
  }
}
