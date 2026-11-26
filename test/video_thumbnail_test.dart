import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/catalog_models.dart';
import 'package:my_app/models/user_access_models.dart';
import 'package:my_app/models/video_lesson.dart';
import 'package:my_app/widgets/video_thumbnail.dart';

void main() {
  group('Video thumbnail model parsing', () {
    test('VideoLesson parses thumbnailFileName and thumbnailUrl', () {
      final withThumb = VideoLesson.fromJson({
        'id': 'v1',
        'videoName': 'Kinematics',
        'videoUrl': 'https://cdn.example.com/v1.mp4',
        'description': 'Intro',
        'isActive': true,
        'isPreview': false,
        'thumbnailFileName': 'thumb.jpg',
        'thumbnailUrl': 'https://cdn.example.com/thumb.jpg?sig=abc',
      });

      expect(withThumb.thumbnailFileName, 'thumb.jpg');
      expect(
        withThumb.thumbnailUrl,
        'https://cdn.example.com/thumb.jpg?sig=abc',
      );

      final withoutThumb = VideoLesson.fromJson({
        'id': 'v2',
        'videoName': 'No Thumb',
        'videoUrl': 'https://cdn.example.com/v2.mp4',
        'description': '',
        'thumbnailFileName': null,
        'thumbnailUrl': null,
      });

      expect(withoutThumb.thumbnailFileName, isNull);
      expect(withoutThumb.thumbnailUrl, isNull);
    });

    test('TopicDetail parses topic.videos[i].thumbnailUrl', () {
      final topic = TopicDetail.fromJson({
        'id': 't1',
        'name': 'Motion',
        'videos': [
          {
            'id': 'v1',
            'videoName': 'Part 1',
            'thumbnailFileName': null,
            'thumbnailUrl': null,
          },
          {
            'id': 'v2',
            'videoName': 'Part 2',
            'thumbnailFileName': 'part2.png',
            'thumbnailUrl': 'https://cdn.example.com/part2.png?sig=123',
          },
        ],
        'notes': [],
        'mcqTests': [],
      });

      expect(topic.videos[0].thumbnailUrl, isNull);
      expect(
        topic.videos[1].thumbnailUrl,
        'https://cdn.example.com/part2.png?sig=123',
      );
      expect(
        topic.primaryVideoThumbnailUrl,
        'https://cdn.example.com/part2.png?sig=123',
      );
    });

    test('CourseVideoRef parses course.videos[i].video.thumbnailUrl', () {
      final ref = CourseVideoRef.fromJson({
        'video': {
          'id': 'v1',
          'videoName': 'Course Video',
          'thumbnailFileName': 'course.jpg',
          'thumbnailUrl': 'https://cdn.example.com/course.jpg?sig=xyz',
        },
      });

      expect(ref.id, 'v1');
      expect(ref.videoName, 'Course Video');
      expect(ref.thumbnailFileName, 'course.jpg');
      expect(ref.thumbnailUrl, 'https://cdn.example.com/course.jpg?sig=xyz');
    });

    test('UserAccessVideo parses courses[i].videos[j].thumbnailUrl', () {
      final access = UserAccessResponse.fromJson({
        'success': true,
        'data': {
          'user': {
            'id': 'u1',
            'name': 'Student',
            'email': 's@example.com',
          },
          'courses': [
            {
              'courseId': 'c1',
              'courseName': 'Physics',
              'videos': [
                {
                  'videoId': 'v1',
                  'videoName': 'Lesson 1',
                  'thumbnailFileName': 'l1.jpg',
                  'thumbnailUrl': 'https://cdn.example.com/l1.jpg?sig=aaa',
                },
              ],
              'notes': [],
              'mcqTests': [],
            },
          ],
        },
      });

      final course = access.data.courses.first;
      expect(
        course.videos.first.thumbnailUrl,
        'https://cdn.example.com/l1.jpg?sig=aaa',
      );
      expect(
        course.primaryThumbnailUrl,
        'https://cdn.example.com/l1.jpg?sig=aaa',
      );
    });
  });

  group('VideoThumbnail widget', () {
    testWidgets('uses bundled static image when thumbnailUrl is null or empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoThumbnail(
              thumbnailUrl: null,
              width: 80,
              height: 50,
            ),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        VideoThumbnail.defaultFallbackAsset,
      );
    });

    testWidgets('uses NetworkImage when thumbnailUrl is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoThumbnail(
              thumbnailUrl: 'https://cdn.example.com/thumb.jpg?sig=abc',
              width: 80,
              height: 50,
            ),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<NetworkImage>());
      expect(
        (image.image as NetworkImage).url,
        'https://cdn.example.com/thumb.jpg?sig=abc',
      );
    });
  });
}

