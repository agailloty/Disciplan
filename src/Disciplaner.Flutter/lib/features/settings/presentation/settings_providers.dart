import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/collaboration_models.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/presentation/auth_state.dart';
import '../data/mcp_token_models.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SettingsRepository(dioClient.dio);
});

final usersListProvider =
    FutureProvider.autoDispose<List<UserSummaryDto>>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return await repo.getUsers();
});

final currentUserProfileSummaryProvider =
    FutureProvider.autoDispose<UserSummaryDto?>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  if (authState is! AuthAuthenticated) return null;
  final users = await ref.watch(usersListProvider.future);
  final email = authState.session.email.toLowerCase();
  for (final user in users) {
    if (user.email.toLowerCase() == email) {
      return user;
    }
  }
  return null;
});

final profilePictureBytesProvider =
    FutureProvider.family.autoDispose<Uint8List, String>((ref, storagePath) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return await repo.downloadProfilePicture(storagePath);
});

final adminUsersListProvider =
    FutureProvider.autoDispose<List<AdminUserDto>>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return await repo.getAdminUsers();
});

final adminInvitationsListProvider =
    FutureProvider.autoDispose<List<InvitationDto>>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return await repo.getInvitations();
});

final mcpTokensListProvider =
    FutureProvider.autoDispose<List<McpTokenDto>>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return await repo.getMcpTokens();
});
