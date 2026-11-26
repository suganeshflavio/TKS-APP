/// Domain models for the course catalog, content structures, and playback.
library;

/// The browsable content hierarchy: Subject -> Class -> Chapter -> Topic.
/// A Topic optionally links a Video, Notes, and/or an MCQ test.

class SubjectItem {
  const SubjectItem({required this.id, required this.name});

  final String id;
  final String name;

  factory SubjectItem.fromJson(Map<String, dynamic> json) => SubjectItem(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
  );
}

class ClassItem {
  const ClassItem({
    required this.id,
    required this.name,
    required this.subjectId,
  });

  final String id;
  final String name;
  final String subjectId;

  factory ClassItem.fromJson(Map<String, dynamic> json) => ClassItem(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    subjectId: json['subjectId'] as String? ?? '',
  );
}

class ChapterItem {
  const ChapterItem({
    required this.id,
    required this.name,
    required this.classId,
  });

  final String id;
  final String name;
  final String classId;

  factory ChapterItem.fromJson(Map<String, dynamic> json) => ChapterItem(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    classId: json['classId'] as String? ?? '',
  );
}

class TopicItem {
  const TopicItem({required this.id, required this.name, this.order});

  final String id;
  final String name;
  final int? order;

  factory TopicItem.fromJson(Map<String, dynamic> json) => TopicItem(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    order: (json['order'] as num?)?.toInt(),
  );
}

/// One of a course's Subject↔Class links (`CourseSubject`). `classId` null
/// means the link is unrestricted — the app auto-resolves the class from
/// the student's own profile, same as before this feature existed.
class CourseSubjectClassLink {
  const CourseSubjectClassLink({this.classId, this.className});

  final String? classId;
  final String? className;
}

/// A subject linked to a course, grouped with every Class it was explicitly
/// scoped to (a course can link the same subject more than once to bundle
/// several grades — e.g. a combined 9th/10th English course).
class CourseSubjectGroup {
  const CourseSubjectGroup({
    required this.subjectId,
    required this.subjectName,
    required this.classLinks,
  });

  final String subjectId;
  final String subjectName;
  final List<CourseSubjectClassLink> classLinks;
}

/// One of a course's Topic links (`CourseTopic`) — the primary way a course
/// now grants Subject/Class/Chapter/Topic hierarchy access. Carries the
/// full chapter -> class -> subject chain so the app can derive the whole
/// browsable tree from this flat list alone, no separate catalog calls.
class CourseTopicRef {
  const CourseTopicRef({
    required this.topicId,
    required this.topicName,
    required this.chapterId,
    required this.chapterName,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
  });

  final String topicId;
  final String topicName;
  final String chapterId;
  final String chapterName;
  final String classId;
  final String className;
  final String subjectId;
  final String subjectName;
}

class TopicContentRef {
  const TopicContentRef({
    required this.id,
    required this.name,
    this.thumbnailFileName,
    this.thumbnailUrl,
  });

  final String id;
  final String name;
  final String? thumbnailFileName;
  final String? thumbnailUrl;
}

class CourseVideoRef {
  const CourseVideoRef({
    required this.id,
    required this.videoName,
    this.thumbnailFileName,
    this.thumbnailUrl,
  });

  final String id;
  final String videoName;
  final String? thumbnailFileName;
  final String? thumbnailUrl;

  factory CourseVideoRef.fromJson(Map<String, dynamic> json) {
    final video = json['video'] is Map<String, dynamic>
        ? json['video'] as Map<String, dynamic>
        : json;
    return CourseVideoRef(
      id: (video['id'] ?? json['videoId']) as String? ?? '',
      videoName: video['videoName'] as String? ?? '',
      thumbnailFileName: video['thumbnailFileName'] as String?,
      thumbnailUrl: video['thumbnailUrl'] as String?,
    );
  }
}

class TopicDetail {
  const TopicDetail({
    required this.id,
    required this.name,
    required this.videos,
    required this.notes,
    required this.mcqTests,
  });

  final String id;
  final String name;
  final List<TopicContentRef> videos;
  final List<TopicContentRef> notes;
  final List<TopicContentRef> mcqTests;

  bool get hasAnyContent =>
      videos.isNotEmpty || notes.isNotEmpty || mcqTests.isNotEmpty;

  String? get primaryVideoThumbnailUrl {
    for (final video in videos) {
      final url = video.thumbnailUrl?.trim();
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  factory TopicDetail.fromJson(Map<String, dynamic> json) {
    List<TopicContentRef> parseRefs(String key, String nameKey) {
      return (json[key] as List<dynamic>? ?? [])
          .map((e) {
            final map = e as Map<String, dynamic>;
            return TopicContentRef(
              id: map['id'] as String? ?? '',
              name: map[nameKey] as String? ?? '',
              thumbnailFileName: map['thumbnailFileName'] as String?,
              thumbnailUrl: map['thumbnailUrl'] as String?,
            );
          })
          .toList();
    }

    return TopicDetail(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      videos: parseRefs('videos', 'videoName'),
      notes: parseRefs('notes', 'title'),
      mcqTests: parseRefs('mcqTests', 'testName'),
    );
  }
}
