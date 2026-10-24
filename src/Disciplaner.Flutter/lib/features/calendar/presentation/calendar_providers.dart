import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/collaboration_models.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/calendar_repository.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CalendarRepository(dioClient.dio);
});

class CalendarTokenNotifier extends AsyncNotifier<CalendarTokenDto?> {
  @override
  Future<CalendarTokenDto?> build() async {
    final repo = ref.watch(calendarRepositoryProvider);
    return await repo.getToken();
  }

  Future<void> regenerate() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(calendarRepositoryProvider);
      return await repo.generateToken();
    });
  }

  Future<void> revoke() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(calendarRepositoryProvider);
      await repo.revokeToken();
      return null;
    });
  }
}

final calendarTokenProvider =
    AsyncNotifierProvider<CalendarTokenNotifier, CalendarTokenDto?>(
  CalendarTokenNotifier.new,
);
