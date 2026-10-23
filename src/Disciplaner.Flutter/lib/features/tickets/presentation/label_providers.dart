import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/ticket_models.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/label_repository.dart';

final labelRepositoryProvider = Provider<LabelRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return LabelRepository(dioClient.dio);
});

/// Toutes les étiquettes disponibles (lecture pour tout membre authentifié).
final labelsListProvider =
    FutureProvider.autoDispose<List<LabelDto>>((ref) async {
  final repo = ref.watch(labelRepositoryProvider);
  return repo.getLabels();
});
