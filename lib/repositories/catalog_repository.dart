import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/catalog_models.dart';

/// Read-only access to the Subject -> Class -> Chapter -> Topic content
/// hierarchy. Used to drill down into a "video" category course.
class CatalogRepository {
  CatalogRepository(this._client);

  final ApiClient _client;

  List<dynamic> _listFrom(dynamic body, String key) {
    if (body is! Map<String, dynamic>) return const [];
    final data = body['data'];
    if (data is! Map<String, dynamic>) return const [];
    final list = data[key];
    return list is List<dynamic> ? list : const [];
  }

  Map<String, dynamic>? _dataOf(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    final data = body['data'];
    return data is Map<String, dynamic> ? data : null;
  }

  Future<List<SubjectItem>> fetchSubjects() async {
    try {
      final response = await _client.get(
        '/api/subjects',
        queryParameters: {'limit': 200},
      );
      return _listFrom(response.data, 'subjects')
          .map((e) => SubjectItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Subjects linked to a specific course, via `GET /api/courses/:id`.
  Future<List<SubjectItem>> fetchCourseSubjects(String courseId) async {
    try {
      final response = await _client.get('/api/courses/$courseId');
      final data = _dataOf(response.data);
      final links = data?['subjects'] as List<dynamic>? ?? const [];
      return links
          .map((e) => (e as Map<String, dynamic>)['subject'])
          .whereType<Map<String, dynamic>>()
          .map(SubjectItem.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<ClassItem>> fetchClasses(String subjectId) async {
    try {
      final response = await _client.get(
        '/api/classes',
        queryParameters: {'subjectId': subjectId, 'limit': 200},
      );
      return _listFrom(response.data, 'classes')
          .map((e) => ClassItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<ChapterItem>> fetchChapters(String classId) async {
    try {
      final response = await _client.get(
        '/api/chapters',
        queryParameters: {'classId': classId, 'limit': 200},
      );
      return _listFrom(response.data, 'chapters')
          .map((e) => ChapterItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<TopicItem>> fetchTopics(String chapterId) async {
    try {
      final response = await _client.get(
        '/api/topics',
        queryParameters: {'chapterId': chapterId, 'limit': 200},
      );
      final topics = _listFrom(response.data, 'topics')
          .map((e) => TopicItem.fromJson(e as Map<String, dynamic>))
          .toList();
      topics.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
      return topics;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<TopicDetail> fetchTopicById(String topicId) async {
    try {
      final response = await _client.get('/api/topics/$topicId');
      final data = _dataOf(response.data);
      if (data == null) {
        throw ApiException('Unable to load topic.');
      }
      return TopicDetail.fromJson(data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
