import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../state/session_state.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<SessionState>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionState>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight,
                          border: Border.all(color: AppColors.primary, width: 2),
                          boxShadow: AppColors.primaryShadow,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      // const SizedBox(height: 16),
                      // Text(
                      //   user?.name ?? 'Student Name',
                      //   style: AppTypography.displayMedium.copyWith(fontSize: 22),
                      // ),
                      // const SizedBox(height: 4),
                      // Text(
                      //   user?.email ?? 'student@example.com',
                      //   style: AppTypography.bodyMedium,
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Details',
                        style: AppTypography.titleLarge.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      _ProfileTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Full Name',
                        value: user?.name ?? '-',
                      ),
                      const Divider(height: 24, color: AppColors.cardBorder),
                      _ProfileTile(
                        icon: Icons.email_outlined,
                        label: 'Email Address',
                        value: user?.email ?? '-',
                      ),
                      const Divider(height: 24, color: AppColors.cardBorder),
                      _ProfileTile(
                        icon: Icons.phone_android_rounded,
                        label: 'Mobile Number',
                        value: user?.mobile ?? 'Not provided',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  text: 'Sign Out',
                  icon: Icons.logout_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  onPressed: () => _handleLogout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.titleMedium.copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
