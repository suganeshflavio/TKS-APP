import 'package:flutter/material.dart';

import '../models/user_access_models.dart';
import '../widgets/inline_search_field.dart';
import 'videos_page.dart';

class ChapterPage extends StatefulWidget {
  const ChapterPage({super.key, required this.course, required this.subject});

  final UserCourse course;
  final UserSubject subject;

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final chapters = widget.subject.chapters
        .where(
          (chapter) =>
              chapter.toLowerCase().contains(_query.trim().toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EE),
        foregroundColor: const Color(0xFF3A1E0B),
        elevation: 0,
        title: Text(widget.subject.subject),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InlineSearchField(
            hintText: 'Search chapters',
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 14),
          ...chapters.map((chapterName) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFDDBF)),
              ),
              child: ListTile(
                title: Text(
                  chapterName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VideosPage(
                        courseId: widget.course.courseId,
                        courseName: widget.course.courseName,
                        subjectName: widget.subject.subject,
                        chapterName: chapterName,
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
