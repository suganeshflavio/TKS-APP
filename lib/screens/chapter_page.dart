import 'package:flutter/material.dart';

import '../models/dashboard_content.dart';
import 'topic_page.dart';

class ChapterPage extends StatelessWidget {
  const ChapterPage({super.key, required this.course, required this.subject});

  final CourseItem course;
  final SubjectItem subject;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EE),
        foregroundColor: const Color(0xFF3A1E0B),
        elevation: 0,
        title: const Text('Chapters'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            subject.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3A1E0B),
            ),
          ),
          const SizedBox(height: 14),
          ...subject.chapters.map((chapter) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFDDBF)),
              ),
              child: ListTile(
                title: Text(
                  chapter.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${chapter.topics.length} topics'),
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TopicPage(
                        course: course,
                        subject: subject,
                        chapter: chapter,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
