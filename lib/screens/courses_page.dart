import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_access_models.dart';
import '../state/session_state.dart';
import '../widgets/inline_search_field.dart';
import '../widgets/skeleton.dart';
import 'subject_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final courses = session.courses
        .where(
          (course) => course.courseName.toLowerCase().contains(
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
        title: const Text('All Courses'),
      ),
      body: session.isLoadingCourses
          ? const CourseListSkeleton()
          : RefreshIndicator(
              onRefresh: () => context.read<SessionState>().refreshCourses(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  InlineSearchField(
                    hintText: 'Search courses',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 14),
                  if (courses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              session.errorMessage ?? 'No courses found.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF6E4D37)),
                            ),
                            if (session.errorMessage != null) ...[
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () =>
                                    context.read<SessionState>().refreshCourses(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF97316),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  else
                    ...courses.map((course) => _CourseCard(course: course)),
                ],
              ),
            ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final UserCourse course;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFDDBF)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        title: Text(
          course.courseName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3A1E0B),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${course.subjects.length} subjects  •  ${course.chapterCount} chapters',
            style: const TextStyle(color: Color(0xFF8A6A55)),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFFF97316),
          size: 28,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SubjectPage(course: course),
            ),
          );
        },
      ),
    );
  }
}
