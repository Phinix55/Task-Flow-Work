import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/user_profile.dart';

class ProfileRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<UserProfile?> getProfileStream(String userId) {
    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isNotEmpty ? UserProfile.fromJson(data.first) : null);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _client.from('profiles').update(profile.toJson()).eq('id', profile.id);
  }
}
