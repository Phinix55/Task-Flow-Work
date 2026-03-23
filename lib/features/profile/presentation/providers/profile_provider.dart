import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile.dart';
import '../../data/profile_repository.dart';
import '../../../../core/providers/supabase_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

// Provides the real-time stream of the user's Profile
final profileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(profileRepositoryProvider).getProfileStream(user.id);
});

// Action provider for profile updates
final profileActionsProvider = Provider<ProfileActions>((ref) {
  return ProfileActions(ref.watch(profileRepositoryProvider), ref);
});

class ProfileActions {
  final ProfileRepository _repository;
  final Ref _ref;
  ProfileActions(this._repository, this._ref);

  Future<void> updateProfile(UserProfile profile) => _repository.updateProfile(profile);

  Future<void> updateName(String name) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    
    final currentProfile = _ref.read(profileProvider).value;
    if (currentProfile != null) {
      await _repository.updateProfile(currentProfile.copyWith(name: name, updatedAt: DateTime.now()));
    } else {
      await _repository.updateProfile(UserProfile(
        id: user.id,
        name: name,
        email: user.email ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> updateAvatar(String avatarUrl) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    
    final currentProfile = _ref.read(profileProvider).value;
    if (currentProfile != null) {
      await _repository.updateProfile(currentProfile.copyWith(avatarUrl: avatarUrl, updatedAt: DateTime.now()));
    }
  }
}
