import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> signUpWithEmail({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<AuthUser> signInWithProvider(SocialProvider provider);

  /// Confirms the six-digit code sent to the user's contact.
  Future<AuthUser> verifyOtp(String code);

  /// Requests a fresh code and returns how long it stays valid.
  Future<Duration> resendOtp();

  Future<void> signOut();
}
