import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/user_settings_model.dart';

class SettingsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<UserSettings?> getSettingsStream(String userId) {
    return _client
        .from('user_settings')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((data) => data.isNotEmpty ? UserSettings.fromJson(data.first) : null);
  }

  Future<void> updateSettings(UserSettings settings) async {
    await _client
        .from('user_settings')
        .update(settings.toJson())
        .eq('user_id', settings.userId);
  }
}
