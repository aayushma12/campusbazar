import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_mode_provider.dart';
import '../../../../core/services/service_locator.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../domain/entities/profile_entity.dart';
import '../state/profile_state.dart';
import '../view_model/profile_viewmodel.dart';
import 'edit_profile_page.dart';

/// Profile view screen.
///
/// Responsibilities:
/// - Fetch and display user profile
/// - Navigate to edit screen
/// - Show loading/success/error feedback
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileViewModelProvider.notifier).getProfile());
    Future.microtask(() => ref.read(notificationNotifierProvider.notifier).refreshUnreadCount());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
      if (!mounted) return;
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
      if (!isCurrentRoute) return;

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(profileViewModelProvider.notifier).clearMessages();
      }

      if (next.successMessage != null && next.successMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: Colors.green),
        );
        ref.read(profileViewModelProvider.notifier).clearMessages();
      }
    });

    final state = ref.watch(profileViewModelProvider);
    final themeMode = ref.watch(themeModeProvider);
    final unreadNotifications = ref.watch(unreadNotificationCountProvider);
    final profile = state.profile;

    if ((state.status == ProfileStatus.initial || state.status == ProfileStatus.loading) && profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_outline, size: 72, color: Colors.grey),
                const SizedBox(height: 14),
                const Text('No profile data found.'),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => ref.read(profileViewModelProvider.notifier).getProfile(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Badge.count(
              isLabelVisible: unreadNotifications > 0,
              count: unreadNotifications,
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: 'Notifications',
            onPressed: () async {
              await Navigator.pushNamed(context, '/notifications');
              if (!mounted) return;
              await ref.read(notificationNotifierProvider.notifier).refreshUnreadCount();
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EditProfilePage(initialProfile: profile),
                ),
              );

              if (!mounted) return;
              await ref.read(profileViewModelProvider.notifier).getProfile();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileViewModelProvider.notifier).getProfile(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _headerCard(profile),
            const SizedBox(height: 14),
            _infoCard(profile),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Marketplace',
              children: [
                _actionTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'My Orders',
                  subtitle: 'Purchases and sales',
                  onTap: () => Navigator.pushNamed(context, '/orders'),
                ),
                _actionTile(
                  icon: Icons.favorite_border,
                  title: 'Wishlist',
                  subtitle: 'Saved products',
                  onTap: () => Navigator.pushNamed(context, '/wishlist'),
                ),
                _actionTile(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Cart',
                  subtitle: 'Items waiting for checkout',
                  onTap: () => Navigator.pushNamed(context, '/cart'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sectionCard(
              title: 'Preferences',
              children: [
                SwitchListTile(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).toggleDarkMode(v),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Apply dark theme across the app'),
                ),
                _actionTile(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  subtitle: unreadNotifications > 0
                      ? '$unreadNotifications unread notifications'
                      : 'View your notifications',
                  onTap: () async {
                    await Navigator.pushNamed(context, '/notifications');
                    if (!mounted) return;
                    await ref.read(notificationNotifierProvider.notifier).refreshUnreadCount();
                  },
                ),
                _actionTile(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'Notifications, password, theme, account actions',
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sectionCard(
              title: 'Account',
              children: [
                _actionTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => EditProfilePage(initialProfile: profile),
                      ),
                    );

                    if (!context.mounted) return;
                    await ref.read(profileViewModelProvider.notifier).getProfile();
                  },
                ),
                _actionTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out from this device',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () async {
                    await sl<AuthLocalDataSource>().clearCache();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(Profile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: (profile.profilePicture != null && profile.profilePicture!.isNotEmpty)
                  ? NetworkImage(profile.profilePicture!)
                  : null,
              child: (profile.profilePicture == null || profile.profilePicture!.isEmpty)
                  ? const Icon(Icons.person, size: 32)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(profile.email, style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(Profile profile) {
    Widget row(String label, String? value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(width: 100, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
            Expanded(
              child: Text(
                (value == null || value.isEmpty) ? 'Not set' : value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            row('Phone', profile.phoneNumber),
            row('Student ID', profile.studentId),
            row('Batch', profile.batch),
            row('College ID', profile.collegeId),
            row('University', profile.university),
            row('Campus', profile.campus),
            row('Bio', profile.bio),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
