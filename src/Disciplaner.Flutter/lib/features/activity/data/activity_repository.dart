import 'package:dio/dio.dart';
import '../../../../core/models/collaboration_models.dart';

class ActivityRepository {
  final Dio _dio;

  ActivityRepository(this._dio);

  Future<List<ActivityItemDto>> getRecentActivity({int limit = 20}) async {
    final response = await _dio.get(
      '/api/activity/recent',
      queryParameters: {'limit': limit},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ActivityItemDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
