import 'package:dio/dio.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/network/dio_client.dart';

class SprintRepository {
  final Dio _dio;

  SprintRepository(this._dio);

  Future<List<SprintDto>> getActive() async {
    try {
      final response = await _dio.get('/api/sprints/active');
      return (response.data as List<dynamic>)
          .map((e) => SprintDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<List<SprintDto>> getWithDates() async {
    try {
      final response = await _dio.get('/api/sprints/with-dates');
      return (response.data as List<dynamic>)
          .map((e) => SprintDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<SprintDetailDto> getById(String id) async {
    try {
      final response = await _dio.get('/api/sprints/$id');
      return SprintDetailDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<List<SprintDto>> getByProject(String projectId) async {
    try {
      final response = await _dio.get('/api/projects/$projectId/sprints');
      return (response.data as List<dynamic>)
          .map((e) => SprintDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<SprintDto> create(String projectId, CreateSprintRequest request) async {
    try {
      final response = await _dio.post(
        '/api/projects/$projectId/sprints',
        data: request.toJson(),
      );
      return SprintDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<SprintDto> update(String sprintId, UpdateSprintRequest request) async {
    try {
      final response = await _dio.put(
        '/api/sprints/$sprintId',
        data: request.toJson(),
      );
      return SprintDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<SprintDto> start(String sprintId, StartSprintRequest request) async {
    try {
      final response = await _dio.put(
        '/api/sprints/$sprintId/start',
        data: request.toJson(),
      );
      return SprintDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<SprintDto> close(String sprintId) async {
    try {
      final response = await _dio.put('/api/sprints/$sprintId/close');
      return SprintDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<void> delete(String sprintId) async {
    try {
      await _dio.delete('/api/sprints/$sprintId');
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
