import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/student_test.dart';
import '../models/video_lesson.dart';
import '../repositories/student_test_repository.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.video});

  final VideoLesson video;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final StudentTestRepository _repository = StudentTestRepository(ApiClient());

  late Future<List<StudentTest>> _testsFuture;

  StudentTest? _activeTest;
  DateTime? _startedAt;
  bool _isSubmitting = false;
  StudentAttemptResult? _result;

  final Map<String, String> _answersByQuestionId = <String, String>{};

  @override
  void initState() {
    super.initState();
    _testsFuture = _repository.fetchTestsByVideo(widget.video.id);
  }

  Future<void> _loadTest(String testId) async {
    setState(() {
      _activeTest = null;
      _startedAt = null;
      _result = null;
      _answersByQuestionId.clear();
    });

    try {
      final fullTest = await _repository.fetchTestById(testId);
      if (!mounted) return;
      setState(() {
        _activeTest = fullTest;
        _startedAt = DateTime.now().toUtc();
      });
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : 'Unable to load test.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _submit() async {
    final test = _activeTest;
    final startedAt = _startedAt;
    if (test == null || startedAt == null || _isSubmitting) return;

    final total = test.questions.length;
    if (_answersByQuestionId.length != total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before submitting.'),
        ),
      );
      return;
    }

    final invalidSelection = _answersByQuestionId.values.any(
      (value) => value != 'A' && value != 'B' && value != 'C' && value != 'D',
    );
    if (invalidSelection) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid option detected.')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final answers = test.questions
          .map(
            (question) => AttemptAnswer(
              questionId: question.id,
              selected: _answersByQuestionId[question.id]!,
            ),
          )
          .toList(growable: false);

      final result = await _repository.submitAttempt(
        testId: test.id,
        videoId: test.videoId.isNotEmpty ? test.videoId : widget.video.id,
        startedAt: startedAt,
        submittedAt: DateTime.now().toUtc(),
        answers: answers,
        status: 'COMPLETED',
      );

      if (!mounted) return;
      setState(() => _result = result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test submitted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException
          ? e.message
          : 'Unable to submit attempt.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EE),
        foregroundColor: const Color(0xFF3A1E0B),
        elevation: 0,
        title: const Text('MCQ/Test'),
      ),
      body: FutureBuilder<List<StudentTest>>(
        future: _testsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Unable to load tests.';
            return _ErrorView(
              message: message,
              onRetry: () {
                setState(() {
                  _testsFuture = _repository.fetchTestsByVideo(widget.video.id);
                });
              },
            );
          }

          final tests = snapshot.data ?? <StudentTest>[];
          if (tests.isEmpty) {
            return const Center(
              child: Text(
                'No MCQ/Test available for this video yet.',
                style: TextStyle(color: Color(0xFF6E4D37)),
              ),
            );
          }

          if (_activeTest == null) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final test = tests[index];
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
                      Text(
                        test.testName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3A1E0B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${test.totalQuestions} questions • ${test.marksPerQuestion} mark(s) each',
                        style: const TextStyle(color: Color(0xFF8F6A4D)),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _loadTest(test.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Start MCQ'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          final test = _activeTest!;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: test.questions.length,
                  itemBuilder: (context, index) {
                    final question = test.questions[index];
                    final selected = _answersByQuestionId[question.id];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFDDBF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}. ${question.question}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3A1E0B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...question.options.entries.map((entry) {
                            final isSelected = selected == entry.key;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  setState(() {
                                    _answersByQuestionId[question.id] =
                                        entry.key;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFFF1E7)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFF97316)
                                          : const Color(0xFFFFDDBF),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        color: isSelected
                                            ? const Color(0xFFF97316)
                                            : const Color(0xFF8F6A4D),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${entry.key}. ${entry.value}',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF6EE),
                  border: Border(top: BorderSide(color: Color(0xFFFFDDBF))),
                ),
                child: Column(
                  children: [
                    if (_result != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Score: ${_result!.obtainedMarks}/${_result!.totalMarks} '
                          '(Correct: ${_result!.correctAnswers}, Wrong: ${_result!.wrongAnswers})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3A1E0B),
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => setState(() {
                                    _activeTest = null;
                                    _startedAt = null;
                                    _result = null;
                                    _answersByQuestionId.clear();
                                  }),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF97316),
                              side: const BorderSide(color: Color(0xFFF97316)),
                              minimumSize: const Size.fromHeight(46),
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(46),
                            ),
                            child: Text(
                              _isSubmitting ? 'Submitting...' : 'Submit Test',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6E4D37)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
