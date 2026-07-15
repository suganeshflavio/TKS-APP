import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/auth_models.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<LoginData> login({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    try {
      final response = await _client.post(
        '/api/auth/login',
        data: {'email': email, 'password': password, 'deviceId': deviceId},
      );
      final body = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (!body.success) throw ApiException(body.message);
      return body.data;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _client.post('/api/auth/logout');
    } on DioException {
      // Best-effort: the local session is cleared regardless of this call's outcome.
    }
  }
}
