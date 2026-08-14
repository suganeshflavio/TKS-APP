import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AppBackground(
        useHeroGradient: true,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: AppCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          boxShadow: AppColors.primaryShadow,
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          size: 40,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Forgot Password?',
                        style: AppTypography.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the email associated with your account and we\'ll send you instructions to reset your password.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 28),
                      AppTextField(
                        controller: _emailController,
                        labelText: 'Email Address',
                        hintText: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      AppPrimaryButton(
                        text: 'Send Reset Instructions',
                        icon: Icons.send_rounded,
                        onPressed: () {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);

                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              content: const Text(
                                'Password reset link sent to your email!',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                          Future.delayed(const Duration(seconds: 1), () {
                            if (!mounted) return;
                            navigator.pop();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
