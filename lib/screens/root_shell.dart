import 'package:flutter/material.dart';

import '../widgets/review_sheet.dart';
import 'courses_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _pages = [HomePage(), CoursesPage(), ProfilePage()];
  static const _reviewDestinationIndex = 3;

  void _onDestinationSelected(int index) {
    if (index == _reviewDestinationIndex) {
      showReviewSheet(context);
      return;
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Course',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.rate_review_rounded),
            label: 'Review',
          ),
        ],
      ),
    );
  }
}
