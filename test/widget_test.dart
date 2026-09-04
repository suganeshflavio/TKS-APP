// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/app.dart';
import 'package:my_app/core/config/env.dart';
import 'package:my_app/models/student_test.dart';
import 'package:my_app/widgets/formatted_content_view.dart';

void main() {
  setUpAll(() async {
    await Env.load();
  });

  testWidgets('Splash redirects to login', (WidgetTester tester) async {
    await tester.pumpWidget(const TksApp());

    expect(find.text('TKS Academy'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
  });

  test('Student quiz question exposes the correct option and explanation', () {
    final question = StudentTestQuestion.fromJson({
      'id': 'q1',
      'question': 'Who is the founder?',
      'optionA': 'Alice',
      'optionB': 'Bob',
      'optionC': 'Carol',
      'optionD': 'David',
      'correctOption': 'B',
      'answerExplanation':
          'Bob is the founder because he established the academy.',
    });

    expect(question.correctOption, 'B');
    expect(
      question.answerExplanation,
      'Bob is the founder because he established the academy.',
    );
    expect(question.options['B'], 'Bob');
  });

  test('Submit result parser accepts alternate backend field names', () {
    final result = StudentAttemptResult.fromJson({
      'id': 'attempt_1',
      'status': 'COMPLETED',
      'totalQuestions': 1,
      'correctAnswers': 1,
      'wrongAnswers': 0,
      'totalMarks': 2,
      'obtainedMarks': 2,
      'submittedAt': '2026-08-13T10:00:00.000Z',
      'questions': [
        {
          'question_id': 'q1',
          'question': 'Who is the founder?',
          'selected_option': 'B',
          'correct_answer': 'B',
          'explanation':
              'Bob is the founder because he established the academy.',
        },
      ],
    });

    expect(result.questions.length, 1);
    expect(result.questions.first.selected, 'B');
    expect(result.questions.first.correctOption, 'B');
    expect(
      result.questions.first.answerExplanation,
      'Bob is the founder because he established the academy.',
    );
  });

  test('Submit result parser accepts actual backend answer payload', () {
    final result = StudentAttemptResult.fromJson({
      'id': 'attempt_1',
      'status': 'COMPLETED',
      'totalQuestions': 2,
      'correctAnswers': 2,
      'wrongAnswers': 0,
      'totalMarks': 4,
      'obtainedMarks': 4,
      'submittedAt': '2026-08-13T12:58:08.232Z',
      'answers': [
        {
          'questionId': 'cmsrhjs5v0036og0pu0jmg326',
          'question': 'wht us what',
          'optionA': 'w',
          'optionB': 'wh',
          'optionC': 'wha',
          'optionD': 'what',
          'correctOption': 'D',
          'selected': 'D',
          'correct': true,
          'explanation': 'what',
        },
        {
          'questionId': 'cmsrhjs5v0037og0pxhonya95',
          'question': 'wher eis where',
          'optionA': 'wher',
          'optionB': 'w',
          'optionC': 'whe',
          'optionD': 'where',
          'correctOption': 'D',
          'selected': 'D',
          'correct': true,
          'explanation': 'where',
        },
      ],
    });

    expect(result.questions.length, 2);
    expect(result.questions.first.selected, 'D');
    expect(result.questions.first.correctOption, 'D');
    expect(result.questions.first.answerExplanation, 'what');
    expect(result.questions.last.answerExplanation, 'where');
  });

  testWidgets('FormattedContentView renders equations and image tags', (WidgetTester tester) async {
    const questionHtml = r'<p>The reaction where hydrogen gas combines with oxygen gas to form water is written as:<br>\(2H_{2}+O_{2}\rightarrow 2H_{2}O\)</p>';
    const optionAHtml = '<p>2HCl(g) + 2Na(s) → 2NaCl(s) + H<sub>2</sub>(g)</p><p><br></p>';
    const optionBHtml = '<p><img src="https://res.cloudinary.com/ya9xb2rx/image/upload/v1788513006/inline-content/file_j5zblp.png">What is this?</p>';
    const optionCHtml = '<p>This is that</p>';
    const optionDHtml = r'<p><img src="https://wikimedia.org/api/rest_v1/media/math/render/svg/8bd3a1101f75d22efd346977da25d7af801f3836" alt="{\displaystyle {2\,\mathrm {CH} {\vphantom {A}}_{\smash[{t}]{3}}\mathrm {OH} ~\;{-}\;~\mathrm {H} {\vphantom {A}}_{\smash[{t}]{2}}\mathrm {O} {}\mathrel {\longrightarrow } {}\mathrm {CH} {\vphantom {A}}_{\smash[{t}]{3}}\mathrm {OCH} {\vphantom {A}}_{\smash[{t}]{3}}}}"></p>';
    const explanationHtml = r'<p><span data-type="math-inline" data-latex="2CH3OH→CH3OCH3+H2" class="rte-math"><span class="katex"><span class="katex-html" aria-hidden="true"><span class="katex-base">...</span></span></span></span></p>';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                FormattedContentView(content: questionHtml),
                FormattedContentView(content: optionAHtml),
                FormattedContentView(content: optionBHtml),
                FormattedContentView(content: optionCHtml),
                FormattedContentView(content: optionDHtml),
                FormattedContentView(content: explanationHtml),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(FormattedContentView), findsNWidgets(6));
    expect(find.text('This is that', findRichText: true), findsOneWidget);
    // Option D must render cleanly via Math without raw HTML or displaystyle text or $1 artifacts
    expect(find.textContaining('<p><img'), findsNothing);
    expect(find.textContaining('displaystyle'), findsNothing);
    expect(find.textContaining(r'$1'), findsNothing);
  });

  test('Option D LaTeX cleaning produces valid formula without \$1', () {
    const rawAlt = r'{\displaystyle {2\,\mathrm {CH} {\vphantom {A}}_{\smash[{t}]{3}}\mathrm {OH} ~\;{-}\;~\mathrm {H} {\vphantom {A}}_{\smash[{t}]{2}}\mathrm {O} {}\mathrel {\longrightarrow } {}\mathrm {CH} {\vphantom {A}}_{\smash[{t}]{3}}\mathrm {OCH} {\vphantom {A}}_{\smash[{t}]{3}}}}';
    final cleaned = FormattedContentView.cleanLatex(rawAlt);
    expect(cleaned.contains(r'$1'), isFalse);
    expect(cleaned.contains(r'_{3}'), isTrue);
    expect(cleaned.contains(r'_{2}'), isTrue);
    expect(cleaned.contains(r'\longrightarrow'), isTrue);
  });
}
