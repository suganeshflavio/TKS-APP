import 'package:flutter/material.dart';

import '../models/dashboard_content.dart';

class TestsPage extends StatelessWidget {
  const TestsPage({super.key, required this.tests});

  final List<TestItem> tests;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EE),
        foregroundColor: const Color(0xFF3A1E0B),
        elevation: 0,
        title: const Text('Tests'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tests.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = tests[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFDDBF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3A1E0B),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: item.status == 'Available'
                            ? const Color(0xFFE8FBEF)
                            : const Color(0xFFFFF1E7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: item.status == 'Available'
                              ? const Color(0xFF168A4A)
                              : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.subject,
                  style: const TextStyle(
                    color: Color(0xFF7B5B43),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.questionCount} questions • ${item.duration}',
                  style: const TextStyle(color: Color(0xFF9A775C)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      item.status == 'Available'
                          ? 'Start Test'
                          : 'Set Reminder',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
