import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/network/dio_client.dart';

abstract class IProjectRepository {
  Future<List<ProjectSummaryDto>> getAll();
  Future<ProjectDetailDto> getById(String id);
  Future<ProjectDetailDto> create(CreateProjectRequest request);
  Future<ProjectDetailDto> update(String id, UpdateProjectRequest request);
  Future<ProjectDetailDto> updateDefaults(String id, UpdateProjectDefaultsRequest request);
  Future<void> delete(String id);
  Future<TicketStatusDto> addStatus(String projectId, CreateTicketStatusRequest request);
  Future<TicketStatusDto> updateStatus(String projectId, String statusId, UpdateTicketStatusRequest request);
  Future<void> deleteStatus(String projectId, String statusId);
  Future<List<MemberDto>> getMembers(String projectId);
  Future<MemberDto> addMember(String projectId, AddMemberRequest request);
  Future<MemberDto> updateMemberRole(String projectId, String userId, UpdateMemberRoleRequest request);
  Future<void> removeMember(String projectId, String userId);
}

class ProjectRepository implements IProjectRepository {
  final DioClient _client;

  ProjectRepository(this._client);

  @override
  Future<List<ProjectSummaryDto>> getAll() async {
    try {
      final res = await _client.dio.get('/api/projects');
      final list = res.data as List<dynamic>? ?? [];
      return list.map((e) => ProjectSummaryDto.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<ProjectDetailDto> getById(String id) async {
    try {
      final res = await _client.dio.get('/api/projects/$id');
      return ProjectDetailDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<ProjectDetailDto> create(CreateProjectRequest request) async {
    try {
      final res = await _client.dio.post('/api/projects', data: request.toJson());
      return ProjectDetailDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<ProjectDetailDto> update(String id, UpdateProjectRequest request) async {
    try {
      final res = await _client.dio.put('/api/projects/$id', data: request.toJson());
      return ProjectDetailDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<ProjectDetailDto> updateDefaults(String id, UpdateProjectDefaultsRequest request) async {
    try {
      final res = await _client.dio.put('/api/projects/$id/defaults', data: request.toJson());
      return ProjectDetailDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.dio.delete('/api/projects/$id');
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<TicketStatusDto> addStatus(String projectId, CreateTicketStatusRequest request) async {
    try {
      final res = await _client.dio.post('/api/projects/$projectId/statuses', data: request.toJson());
      return TicketStatusDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<TicketStatusDto> updateStatus(
    String projectId,
    String statusId,
    UpdateTicketStatusRequest request,
  ) async {
    try {
      final res = await _client.dio.put(
        '/api/projects/$projectId/statuses/$statusId',
        data: request.toJson(),
      );
      return TicketStatusDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<void> deleteStatus(String projectId, String statusId) async {
    try {
      await _client.dio.delete('/api/projects/$projectId/statuses/$statusId');
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<List<MemberDto>> getMembers(String projectId) async {
    try {
      final res = await _client.dio.get('/api/projects/$projectId/members');
      final list = res.data as List<dynamic>? ?? [];
      return list.map((e) => MemberDto.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<MemberDto> addMember(String projectId, AddMemberRequest request) async {
    try {
      final res = await _client.dio.post(
        '/api/projects/$projectId/members',
        data: request.toJson(),
      );
      return MemberDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<MemberDto> updateMemberRole(
    String projectId,
    String userId,
    UpdateMemberRoleRequest request,
  ) async {
    try {
      final res = await _client.dio.put(
        '/api/projects/$projectId/members/$userId',
        data: request.toJson(),
      );
      return MemberDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<void> removeMember(String projectId, String userId) async {
    try {
      await _client.dio.delete('/api/projects/$projectId/members/$userId');
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
