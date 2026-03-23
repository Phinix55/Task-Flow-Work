import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/streak_model.dart';
import '../../data/streak_repository.dart';
import '../../../../core/providers/supabase_provider.dart';

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository();
});

// Provides the real-time stream of the user's primary Streak
final streakProvider = StreamProvider<Streak?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(streakRepositoryProvider).getStreakStream(user.id);
});

// Provides the real-time stream of the user's daily activity logs
final streakLogsProvider = StreamProvider<List<StreakLog>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(streakRepositoryProvider).getStreakLogsStream(user.id);
});

// Action provider for Gamification mutations
final streakActionsProvider = Provider<StreakActions>((ref) {
  return StreakActions(ref.watch(streakRepositoryProvider));
});

class StreakActions {
  final StreakRepository _repository;
  StreakActions(this._repository);

  // Automatically handles incrementing the day's tasks and updating the streak logically
  Future<void> logTaskCompleted(String userId) => _repository.logTaskCompleted(userId);
}
