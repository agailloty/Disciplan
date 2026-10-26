import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/collaboration_models.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/mcp_token_models.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SettingsRepository(dioClient.dio);
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
