import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/catalog_models.dart';
import '../models/user_access_models.dart';
import '../repositories/catalog_repository.dart';
import '../state/session_state.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import '../widgets/inline_search_field.dart';
import '../widgets/skeleton.dart';
import 'chapter_page.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key, required this.course});

  final UserCourse course;

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  final _repository = CatalogRepository(ApiClient());
  late Future<List<CourseSubjectGroup>> _future;
  String _query = '';
  String? _resolvingSubjectId;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<CourseSubjectGroup>> _load() {
    return _repository.fetchCourseSubjects(widget.course.courseId);
  }

  void _retry() => setState(() => _future = _load());

  void _openChapters(String classId, String subjectName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChapterPage(
          course: widget.course,
          classId: classId,
          subjectName: subjectName,
        ),
      ),
    );
  }

  /// Auto-resolves the Class from the student's profile — the legacy path,
  /// used when this subject was linked to the course without pinning it to
  /// a specific class.
  Future<void> _autoResolveAndOpen(CourseSubjectGroup subject) async {
    final classes = await _repository.fetchClasses(subject.subjectId);
    if (!mounted) return;
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No classes found for this subject.')),
      );
      return;
    }

    final className = context.read<SessionState>().user?.className;
    final resolved = className == null
        ? classes.first
        : classes.firstWhere(
            (c) => c.name.trim().toLowerCase() == className.trim().toLowerCase(),
            orElse: () => classes.first,
          );

    _openChapters(resolved.id, subject.subjectName);
  }

  Future<void> _pickClassAndOpen(
    CourseSubjectGroup subject,
    List<CourseSubjectClassLink> options,
  ) async {
    final chosen = await showModalBottomSheet<CourseSubjectClassLink>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${subject.subjectName} — Choose a class', style: AppTypography.titleLarge.copyWith(fontSize: 17)),
                const SizedBox(height: 4),
                Text(
                  'This course covers more than one class for this subject.',
                  style: AppTypography.labelSmall,
                ),
                const SizedBox(height: 16),
                ...options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      onTap: () => Navigator.of(sheetContext).pop(option),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.className ?? 'Class',
                              style: AppTypography.titleMedium,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.textMuted,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (chosen?.classId != null) {
      _openChapters(chosen!.classId!, subject.subjectName);
    }
  }

  Future<void> _openSubject(CourseSubjectGroup subject) async {
    setState(() => _resolvingSubjectId = subject.subjectId);
    try {
      final links = subject.classLinks;
      final hasUnrestrictedLink = links.any((link) => link.classId == null);

      if (hasUnrestrictedLink) {
        await _autoResolveAndOpen(subject);
        return;
      }

      final specificLinks = links.where((link) => link.classId != null).toList();
      if (specificLinks.length == 1) {
        _openChapters(specificLinks.first.classId!, subject.subjectName);
        return;
      }

      await _pickClassAndOpen(subject, specificLinks);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _resolvingSubjectId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.courseName),
      ),
      body: AppBackground(
        child: FutureBuilder<List<CourseSubjectGroup>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const VideoListSkeleton();
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Unable to load subjects.';
              return Center(
                child: AppCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 44,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      AppPrimaryButton(text: 'Retry', height: 44, onPressed: _retry),
                    ],
                  ),
                ),
              );
            }

            final subjects = (snapshot.data ?? [])
                .where(
                  (subject) => subject.subjectName.toLowerCase().contains(
                    _query.trim().toLowerCase(),
                  ),
                )
                .toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              children: [
                InlineSearchField(
                  hintText: 'Search subjects...',
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 18),
                if (subjects.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: AppCard(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 44,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No subjects found.',
                              style: AppTypography.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...subjects.map((subject) {
                    final isResolving = _resolvingSubjectId == subject.subjectId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: AppCard(
                        padding: const EdgeInsets.all(18),
                        onTap: isResolving ? null : () => _openSubject(subject),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryLight,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.topic_outlined,
                                color: AppColors.secondaryDark,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                subject.subjectName,
                                style: AppTypography.titleMedium,
                              ),
                            ),
                            if (isResolving)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.textMuted,
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}
