import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/collaboration_models.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/activity_repository.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ActivityRepository(dioClient.dio);
});

final recentActivityProvider =
    FutureProvider.autoDispose<List<ActivityItemDto>>((ref) async {
  final repo = ref.watch(activityRepositoryProvider);
  return await repo.getRecentActivity();
});
