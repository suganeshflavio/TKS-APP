import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/video_lesson.dart';

class VideoRepository {
  VideoRepository(this._client);

  final ApiClient _client;

  Future<VideosData> fetchVideos({
    required String courseId,
    required String chapter,
  }) async {
    debugPrint(
      '[VideoRepository] GET /api/videos courseId=$courseId chapter=$chapter',
    );
    try {
      final response = await _client.get(
        '/api/videos',
        queryParameters: {'courseId': courseId, 'chapter': chapter},
      );
      debugPrint(
        '[VideoRepository] success (${response.statusCode}): ${response.data}',
      );
      final body = VideosResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (!body.success || body.data == null) {
        throw ApiException(body.message);
      }
      return body.data!;
    } on DioException catch (e) {
      final error = mapDioError(e);
      debugPrint(
        '[VideoRepository] error: ${error.message} (status ${error.statusCode})',
      );
      throw error;
    } catch (e) {
      debugPrint('[VideoRepository] unexpected error: $e');
      rethrow;
    }
  }
}
