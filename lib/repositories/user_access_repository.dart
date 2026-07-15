import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/user_access_models.dart';

class UserAccessRepository {
  UserAccessRepository(this._client);

  final ApiClient _client;

  Future<UserAccessData> fetchUserAccess(String userId) async {
    debugPrint('[UserAccess] GET /api/user-access/$userId');
    try {
      final response = await _client.get('/api/user-access/$userId');
      debugPrint(
        '[UserAccess] success (${response.statusCode}): ${response.data}',
      );
      final body = UserAccessResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return body.data;
    } on DioException catch (e) {
      final error = mapDioError(e);
      debugPrint(
        '[UserAccess] error: ${error.message} (status ${error.statusCode})',
      );
      throw error;
    } catch (e) {
      debugPrint('[UserAccess] unexpected error parsing response: $e');
      rethrow;
    }
  }
}
