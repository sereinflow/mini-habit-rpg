/// Local user identity (replaces Firebase Auth [User] in demo mode).
class AppUser {
  const AppUser({required this.uid, required this.email});

  final String uid;
  final String email;
}
