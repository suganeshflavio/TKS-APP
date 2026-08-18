import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/brand_title.dart';
import '../widgets/custom_card.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Card
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 28,
                          horizontal: 20,
                        ),
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            const AppLogo(size: 72),
                            const SizedBox(height: 14),
                            BrandTitle(
                              style: AppTypography.displayMedium.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Empowering Education Everywhere',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'TKS Academy is a premier digital learning platform dedicated to transforming education. We combine structured curricula, expert mentorship, and cutting-edge technology to make quality learning accessible to students across the country.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge.copyWith(
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Key Statistics Grid
                Text(
                  'Our Impact in Numbers',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: const [
                    _StatCard(
                      value: '50,000+',
                      label: 'Active Students',
                      icon: Icons.people_alt_rounded,
                      color: AppColors.primary,
                    ),
                    _StatCard(
                      value: '120+',
                      label: 'Expert Courses',
                      icon: Icons.school_rounded,
                      color: AppColors.secondary,
                    ),
                    _StatCard(
                      value: '98%',
                      label: 'Pass Rate',
                      icon: Icons.verified_rounded,
                      color: AppColors.success,
                    ),
                    _StatCard(
                      value: '4.9 ★',
                      label: 'Student Rating',
                      icon: Icons.star_rounded,
                      color: AppColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Mission & Vision Cards
                Text(
                  'Our Purpose',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const _PurposeTile(
                        icon: Icons.rocket_launch_rounded,
                        iconColor: AppColors.primary,
                        title: 'Our Mission',
                        description:
                            'To empower learners with top-notch study materials, interactive assessments, and clear concepts that inspire academic confidence and excellence.',
                      ),
                      const Divider(height: 28, color: AppColors.cardBorder),
                      const _PurposeTile(
                        icon: Icons.visibility_rounded,
                        iconColor: AppColors.secondary,
                        title: 'Our Vision',
                        description:
                            'To be the leading personalized learning platform that bridges educational divides and enables every student to realize their full potential.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Core Features
                // Text(
                //   'Why Students Love TKS',
                //   style: AppTypography.titleLarge,
                // ),
                // const SizedBox(height: 12),
                // AppCard(
                //   padding: const EdgeInsets.all(20),
                //   child: Column(
                //     children: const [
                //       _FeatureRow(
                //         icon: Icons.play_circle_fill_rounded,
                //         color: Color(0xFF3B82F6),
                //         title: 'High-Definition Video Lessons',
                //         subtitle:
                //             'Engaging HD video lectures curated by experienced subject matter experts.',
                //       ),
                //       SizedBox(height: 16),
                //       _FeatureRow(
                //         icon: Icons.quiz_rounded,
                //         color: Color(0xFF10B981),
                //         title: 'Interactive Mock Tests & Quizzes',
                //         subtitle:
                //             'Real-time quiz evaluation with instant detailed explanations and scores.',
                //       ),
                //       SizedBox(height: 16),
                //       _FeatureRow(
                //         icon: Icons.description_rounded,
                //         color: Color(0xFFF59E0B),
                //         title: 'Comprehensive Study Notes',
                //         subtitle:
                //             'Downloadable chapter summaries, formula sheets, and key concept notes.',
                //       ),
                //       SizedBox(height: 16),
                //       _FeatureRow(
                //         icon: Icons.insights_rounded,
                //         color: Color(0xFF8B5CF6),
                //         title: 'Smart Analytics & Progress Tracking',
                //         subtitle:
                //             'Track study hours, chapter progress, and subject strengths effortlessly.',
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 24),

                // Leadership & Team
                Text(
                  'Our Leadership',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      _TeamCard(
                        name: 'Prof. K.Tharani',
                        role: 'Founder of TKS Academy',
                        // qualification: 'CEO of TKS Academy',
                        icon: Icons.person_rounded,
                      ),
                      SizedBox(width: 14),
                      // _TeamCard(
                      //   name: 'Prof. Meera Nair',
                      //   role: 'Head of Content & Research',
                      //   qualification: 'M.Sc. Mathematics, Senior Educator',
                      //   icon: Icons.person_rounded,
                      // ),
                      // SizedBox(width: 14),
                      // _TeamCard(
                      //   name: 'Rajesh Kumar',
                      //   role: 'Chief Technology Officer',
                      //   qualification: 'B.Tech CS, EdTech Innovator',
                      //   icon: Icons.person_rounded,
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Footer Info
                // Center(
                //   child: Column(
                //     children: [
                //       Text(
                //         'TKS Academy Mobile App',
                //         style: AppTypography.labelLarge.copyWith(
                //           color: AppColors.textSecondary,
                //         ),
                //       ),
                //       const SizedBox(height: 4),
                //       Text(
                //         'Version 1.0.0 • Building a Brighter Future',
                //         style: AppTypography.labelSmall,
                //       ),
                //       const SizedBox(height: 16),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 6),
              Text(
                value,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PurposeTile extends StatelessWidget {
  const _PurposeTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.bodyMedium.copyWith(
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.name,
    required this.role,
    required this.icon,
  });

  final String name;
  final String role;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryDark,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              role,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
