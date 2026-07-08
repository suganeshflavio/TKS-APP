import 'package:flutter/material.dart';

import '../models/dashboard_content.dart';
import 'topic_video_page.dart';

class TopicPage extends StatelessWidget {
  const TopicPage({
    super.key,
    required this.course,
    required this.subject,
    required this.chapter,
  });

  final CourseItem course;
  final SubjectItem subject;
  final ChapterItem chapter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EE),
        foregroundColor: const Color(0xFF3A1E0B),
        elevation: 0,
        title: const Text('Topics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            chapter.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3A1E0B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${course.title} • ${subject.title}',
            style: const TextStyle(color: Color(0xFF8F6A4D)),
          ),
          const SizedBox(height: 14),
          ...chapter.topics.map((topic) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFDDBF)),
              ),
              child: ListTile(
                title: Text(
                  topic.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${topic.duration} • Tap to open video'),
                leading: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Color(0xFFF97316),
                ),
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TopicVideoPage(
                        topic: topic,
                        chapterTitle: chapter.title,
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
