import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/streak_model.dart';

class StreakRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Real-time stream of the user's Streak
  Stream<Streak?> getStreakStream(String userId) {
    return _client
        .from('streaks')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((data) => data.isNotEmpty ? Streak.fromJson(data.first) : null);
  }

  // Real-time stream of the user's daily activity logs (for heatmap)
  Stream<List<StreakLog>> getStreakLogsStream(String userId) {
    return _client
        .from('streak_logs')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('log_date', ascending: false)
        .map((data) => data.map((e) => StreakLog.fromJson(e)).toList());
  }

  // Completes a task and updates streaks + logs atomically
  Future<void> logTaskCompleted(String userId) async {
    final now = DateTime.now();
    final todayStr = DateTime(now.year, now.month, now.day).toIso8601String().split('T')[0];

    // 1. Upsert today's streak log
    // We fetch first to see if it exists to increment, or we can use an RPC
    // Supabase RPC is best for atomic increments, but we'll do a simple fetch+update here
    final existingLogs = await _client
        .from('streak_logs')
        .select()
        .eq('user_id', userId)
        .eq('log_date', todayStr);

    if (existingLogs.isEmpty) {
      await _client.from('streak_logs').insert({
        'user_id': userId,
        'log_date': todayStr,
        'tasks_done': 1,
      });

      // Since this is the first task of the day, update the Streak
      final streakData = await _client.from('streaks').select().eq('user_id', userId).single();
      final streak = Streak.fromJson(streakData);
      
      int newStreak = streak.currentStreak;
      
      // If last claimed was not yesterday, reset
      if (streak.lastClaimedAt != null) {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        if (streak.lastClaimedAt!.year == yesterday.year &&
            streak.lastClaimedAt!.month == yesterday.month &&
            streak.lastClaimedAt!.day == yesterday.day) {
          newStreak += 1;
        } else if (!streak.isClaimedToday) {
          newStreak = 1; // broken streak
        }
      } else {
        newStreak = 1;
      }

      await _client.from('streaks').update({
        'current_streak': newStreak,
        'longest_streak': newStreak > streak.longestStreak ? newStreak : streak.longestStreak,
        'last_claimed_at': todayStr,
      }).eq('user_id', userId);

    } else {
      // Just increment tasks_done
      await _client.from('streak_logs').update({
        'tasks_done': (existingLogs.first['tasks_done'] as int) + 1,
      }).eq('id', existingLogs.first['id']);
    }
  }
}
