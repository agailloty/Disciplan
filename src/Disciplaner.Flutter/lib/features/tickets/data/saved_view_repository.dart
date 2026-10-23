import 'package:dio/dio.dart';
import '../../../core/models/collaboration_models.dart';
import '../../../core/models/ticket_models.dart';
import '../../../core/network/dio_client.dart';

class SavedViewRepository {
  final Dio _dio;

  SavedViewRepository(this._dio);

  Future<List<SavedViewDto>> getAll() async {
    try {
      final response = await _dio.get('/api/saved-views');
      return (response.data as List<dynamic>)
          .map((e) => SavedViewDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<SavedViewDto> create(CreateSavedViewRequest request) async {
    try {
      final response = await _dio.post(
        '/api/saved-views',
        data: request.toJson(),
      );
      return SavedViewDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<SavedViewDto> update(String viewId, CreateSavedViewRequest request) async {
    try {
      final response = await _dio.put(
        '/api/saved-views/$viewId',
        data: request.toJson(),
      );
      return SavedViewDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<void> delete(String viewId) async {
    try {
      await _dio.delete('/api/saved-views/$viewId');
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<List<TicketDto>> execute(String viewId) async {
    try {
      final response = await _dio.get('/api/saved-views/$viewId/tickets');
      return (response.data as List<dynamic>)
          .map((e) => TicketDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
