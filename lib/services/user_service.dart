import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:mini_habit_rpg/repositories/profile_repository.dart';

/// User profile storage — delegates to ProfileRepository.
class UserService {
  UserService({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  final ProfileRepository _repository;

  Future<UserProfile> getOrCreateProfile(String uid) =>
      _repository.getOrCreate(uid);

  Stream<UserProfile?> watchProfile(String uid) => _repository.watch(uid);

  Future<void> saveProfile(UserProfile profile) => _repository.save(profile);

  Future<void> completeOnboarding({
    required String uid,
    required String username,
    required int avatarId,
    required PersonalityArchetype archetype,
  }) =>
      _repository.completeOnboarding(
        uid: uid,
        username: username,
        avatarId: avatarId,
        archetype: archetype,
      );
}
