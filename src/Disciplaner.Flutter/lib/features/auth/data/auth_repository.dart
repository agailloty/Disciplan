import 'package:disciplaner_flutter/core/models/auth_models.dart';
import 'package:disciplaner_flutter/core/network/dio_client.dart';

abstract class IAuthRepository {
  Future<SetupStatusResponse> getSetupStatus();
  Future<AuthResponse> executeSetup(SetupRequest request);
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<AuthResponse> refresh();
  Future<InvitationInfoResponse> getInvitation(String token);
  Future<AuthResponse> registerInvited(InvitationRegisterRequest request);
}

class AuthRepository implements IAuthRepository {
  final DioClient _client;

  AuthRepository(this._client);

  @override
  Future<SetupStatusResponse> getSetupStatus() async {
    try {
      final res = await _client.dio.get('/api/setup/status');
      return SetupStatusResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<AuthResponse> executeSetup(SetupRequest request) async {
    try {
      final res = await _client.dio.post('/api/setup', data: request.toJson());
      return AuthResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final res = await _client.dio.post('/api/auth/login', data: request.toJson());
      return AuthResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<AuthResponse> refresh() async {
    try {
      // L'intercepteur joint le token courant (même expiré) ; le serveur
      // l'échange contre un nouveau JWT s'il est dans la fenêtre de grâce.
      final res = await _client.dio.post('/api/auth/refresh');
      return AuthResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final res = await _client.dio.post('/api/auth/register', data: request.toJson());
      return AuthResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<InvitationInfoResponse> getInvitation(String token) async {
    try {
      final res = await _client.dio.get('/api/auth/invitation/$token');
      return InvitationInfoResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  @override
  Future<AuthResponse> registerInvited(InvitationRegisterRequest request) async {
    try {
      final res = await _client.dio.post('/api/auth/register-invited', data: request.toJson());
      return AuthResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
