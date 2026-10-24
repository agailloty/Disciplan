import 'package:dio/dio.dart';
import '../../../../core/models/collaboration_models.dart';

class SettingsRepository {
  final Dio _dio;

  SettingsRepository(this._dio);

  Future<void> updateDisplayName(String displayName) async {
    await _dio.put(
      '/api/users/me/display-name',
      data: {'displayName': displayName.trim()},
    );
  }

  Future<List<AdminUserDto>> getAdminUsers() async {
    final response = await _dio.get('/api/admin/users');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => AdminUserDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminUserDto> createUser({
    required String email,
    required String displayName,
    required String password,
    required String role,
  }) async {
    final response = await _dio.post(
      '/api/admin/users',
      data: {
        'email': email.trim(),
        'displayName': displayName.trim(),
        'password': password,
        'role': role,
      },
    );
    return AdminUserDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> activateUser(String userId) async {
    await _dio.post('/api/admin/users/$userId/activate');
  }

  Future<void> deactivateUser(String userId) async {
    await _dio.post('/api/admin/users/$userId/deactivate');
  }

  Future<void> changeRole(String userId, String role) async {
    await _dio.put(
      '/api/admin/users/$userId/role',
      data: {'role': role},
    );
  }

  Future<List<InvitationDto>> getInvitations() async {
    final response = await _dio.get('/api/admin/invitations');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => InvitationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InvitationDto> createInvitation(String email) async {
    final response = await _dio.post(
      '/api/admin/invitations',
      data: {'email': email.trim()},
    );
    return InvitationDto.fromJson(response.data as Map<String, dynamic>);
  }
}
