import 'package:dio/dio.dart';
import '../../../core/models/ticket_models.dart';
import '../../../core/network/dio_client.dart';

/// Gestion des étiquettes globales (CRUD réservé aux administrateurs côté
/// API) : création, édition, suppression et consultation.
class LabelRepository {
  final Dio _dio;

  LabelRepository(this._dio);

  Future<List<LabelDto>> getLabels() async {
    try {
      final response = await _dio.get('/api/labels');
      final list = (response.data as List<dynamic>)
          .map((e) => LabelDto.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<LabelDto> createLabel({
    required String name,
    required String color,
  }) async {
    try {
      final response = await _dio.post('/api/labels', data: {
        'name': name,
        'color': color,
      });
      return LabelDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<LabelDto> updateLabel(
    String id, {
    required String name,
    required String color,
  }) async {
    try {
      final response = await _dio.put('/api/labels/$id', data: {
        'name': name,
        'color': color,
      });
      return LabelDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<void> deleteLabel(String id) async {
    try {
      await _dio.delete('/api/labels/$id');
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
