import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_user.dart';
import '../models/auth_user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthUserModel> signIn(String email, String password);

  Future<AuthUserModel> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<AuthUserModel> signInWithProvider(SocialProvider provider);

  Future<AuthUserModel> verifyOtp(String code);

  Future<Duration> resendOtp();

  Future<void> signOut();
}

/// In-memory stand-in for the CareFlow auth API. Accepts any well-formed
/// credentials so the UI can be exercised end to end without a backend.
class AuthInMemoryDataSource implements AuthRemoteDataSource {
  static const Duration _latency = Duration(milliseconds: 600);
  static const Duration otpValidity = Duration(minutes: 5);

  /// The one code the stub treats as correct, alongside any six digits.
  static const String demoCode = '000000';

  AuthUserModel? _session;

  AuthUserModel _seed({
    String fullName = 'Nana Sarpong',
    String email = 'nanasarpong@gmail.com',
    String phoneNumber = '+233 55 925 5742',
  }) => AuthUserModel(
    id: 'CF-0113',
    fullName: fullName,
    email: email,
    phoneNumber: phoneNumber,
  );

  @override
  Future<AuthUserModel> signIn(String email, String password) async {
    await Future<void>.delayed(_latency);
    if (password.length < 6) {
      throw const AuthFailure('Password must be at least 6 characters.');
    }
    return _session = _seed(email: email).copyWithVerified(true);
  }

  @override
  Future<AuthUserModel> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    return _session = _seed(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<AuthUserModel> signInWithProvider(SocialProvider provider) async {
    await Future<void>.delayed(_latency);
    return _session = _seed().copyWithVerified(true);
  }

  @override
  Future<AuthUserModel> verifyOtp(String code) async {
    await Future<void>.delayed(_latency);
    if (code.length != 6 || int.tryParse(code) == null) {
      throw const AuthFailure('Enter the six digits we sent you.');
    }
    return _session = (_session ?? _seed()).copyWithVerified(true);
  }

  @override
  Future<Duration> resendOtp() async {
    await Future<void>.delayed(_latency);
    return otpValidity;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(_latency);
    _session = null;
  }
}

extension on AuthUserModel {
  AuthUserModel copyWithVerified(bool value) => AuthUserModel(
    id: id,
    fullName: fullName,
    email: email,
    phoneNumber: phoneNumber,
    isVerified: value,
    hasCompletedOnboarding: hasCompletedOnboarding,
  );
}
