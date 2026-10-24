import 'package:dio/dio.dart';
import '../../../../core/models/collaboration_models.dart';

class CalendarRepository {
  final Dio _dio;

  CalendarRepository(this._dio);

  Future<CalendarTokenDto?> getToken() async {
    try {
      final response = await _dio.get('/api/calendar/token');
      if (response.statusCode == 200 && response.data != null) {
        return CalendarTokenDto.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<CalendarTokenDto> generateToken() async {
    final response = await _dio.post('/api/calendar/token');
    return CalendarTokenDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> revokeToken() async {
    await _dio.delete('/api/calendar/token');
  }
}
