import 'package:flutter/material.dart';

import '../models/user_access_models.dart';
import '../widgets/inline_search_field.dart';
import 'chapter_page.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key, required this.course});

  final UserCourse course;

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final subjects = widget.course.subjects
        .where(
          (subject) => subject.subject.toLowerCase().contains(
            _query.trim().toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EE),
        foregroundColor: const Color(0xFF3A1E0B),
        elevation: 0,
        title: Text(widget.course.courseName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InlineSearchField(
            hintText: 'Search subjects',
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 14),
          ...subjects.map((subject) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFDDBF)),
              ),
              child: ListTile(
                title: Text(
                  subject.subject,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${subject.chapters.length} chapters'),
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ChapterPage(course: widget.course, subject: subject),
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
