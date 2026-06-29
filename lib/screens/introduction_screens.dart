import 'dart:async';

import 'package:flutter/material.dart';

import '../models/intro_page.dart';
import '../widgets/intro_page_widget.dart';
import 'login_page.dart';

class IntroductionScreens extends StatefulWidget {
  const IntroductionScreens({super.key});

  @override
  State<IntroductionScreens> createState() => _IntroductionScreensState();
}

class _IntroductionScreensState extends State<IntroductionScreens> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  final List<IntroPage> _introPages = [
    IntroPage(
      title: 'Welcome to TKS Academy',
      description: 'Learn from the best courses and mentors in the world',
      icon: Icons.rocket_launch_rounded,
      color: const Color(0xFFFFA500),
    ),
    IntroPage(
      title: 'Learn Anytime',
      description: 'Access your courses at your own pace, anytime and anywhere',
      icon: Icons.schedule_rounded,
      color: Color.lerp(const Color(0xFFFFA500), Colors.deepPurple, 0.3)!,
    ),
    const IntroPage(
      title: 'Improve Your Skills',
      description:
          'Develop expertise with our comprehensive curriculum and expert guidance',
      icon: Icons.trending_up_rounded,
      color: Colors.deepPurple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) {
        return;
      }
      final nextPage = (_currentPage + 1) % _introPages.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _introPages.length,
            itemBuilder: (context, index) =>
                IntroPageWidget(page: _introPages[index], isDark: isDark),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
