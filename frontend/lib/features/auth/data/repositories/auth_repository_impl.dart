import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) => _guard(() => _remote.signIn(email, password));

  @override
  Future<AuthUser> signUpWithEmail({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) => _guard(
    () => _remote.signUp(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    ),
  );

  @override
  Future<AuthUser> signInWithProvider(SocialProvider provider) =>
      _guard(() => _remote.signInWithProvider(provider));

  @override
  Future<AuthUser> verifyOtp(String code) =>
      _guard(() => _remote.verifyOtp(code));

  @override
  Future<Duration> resendOtp() => _guard(_remote.resendOtp);

  @override
  Future<void> signOut() => _guard(_remote.signOut);

  /// Lets domain failures through untouched and converts anything else into
  /// a [ServerFailure], so callers only ever see [Failure].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const ServerFailure();
    }
  }
}
