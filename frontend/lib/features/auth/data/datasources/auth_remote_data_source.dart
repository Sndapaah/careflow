import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/cache/user_session_cache.dart';
import '../../domain/entities/auth_user.dart';
import '../models/auth_user_model.dart';

/// Boundary the repository talks to.
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

/// Talks to the real CareFlow Express API.
class AuthHttpDataSource implements AuthRemoteDataSource {
  AuthHttpDataSource({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
    required UserSessionCache sessionCache,  
  }) : _api = apiClient,
      _tokenStorage = tokenStorage,
      _sessionCache = sessionCache;          

  final ApiClient _api;
  final TokenStorage _tokenStorage;
  final UserSessionCache _sessionCache;        

  // Held only long enough to auto-login right after OTP verification
  // succeeds, since /verifyOTP/:id returns no token itself. Cleared
  // immediately after use — never written to disk.
  String? _pendingId;
  String? _pendingEmail;
  String? _pendingPassword;

  @override
  Future<AuthUserModel> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final Map<String, dynamic> json = await _api.post(
      '/auth/register',
      body: <String, dynamic>{
        'fullname': fullName,
        'email': email,
        'contact': phoneNumber,
        'password': password,
      },
    );

    _pendingId = json['id'] as String;
    _pendingEmail = email;
    _pendingPassword = password;

    return AuthUserModel(
      id: _pendingId!,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      isVerified: false,
      hasCompletedOnboarding: false,
    );
  }

  @override
  Future<AuthUserModel> verifyOtp(String code) async {
    final String? id = _pendingId;
    final String? email = _pendingEmail;
    final String? password = _pendingPassword;

    if (id == null) {
      throw const AuthFailure('Start registration again before verifying.');
    }

    await _api.post(
      '/auth/verifyOTP/$id',
      body: <String, dynamic>{'otp': code},
    );

    if (email != null && password != null) {
      final AuthUserModel user = await signIn(email, password);
      _pendingId = null;
      _pendingEmail = null;
      _pendingPassword = null;
      return user;
    }

    _pendingId = null;
    return AuthUserModel(
      id: id,
      fullName: '',
      email: email ?? '',
      isVerified: true,
    );
  }

  @override
Future<AuthUserModel> signIn(String email, String password) async {
  final Map<String, dynamic> json = await _api.post(
    '/auth/login',
    body: <String, dynamic>{'email': email, 'password': password},
  );

  final Map<String, dynamic> userJson =
      json['user'] as Map<String, dynamic>;
  final String? token = userJson['accessToken'] as String?;
  if (token != null) await _tokenStorage.save(token);

  final String? userId = userJson['_id'] as String?;
  if (userId != null) await _tokenStorage.saveUserId(userId);

   _sessionCache.store(userJson);

  return AuthUserModel.fromBackendJson(userJson, isVerified: true);
}

  @override
  Future<Duration> resendOtp() async {
    final String? email = _pendingEmail;
    if (email == null) {
      throw const AuthFailure('No pending verification to resend.');
    }
    await _api.post('/auth/resend_otp_code/$email');
    return const Duration(minutes: 15);
  }

  @override
  Future<AuthUserModel> signInWithProvider(SocialProvider provider) {
    throw const ServerFailure('Social sign-in is not available yet.');
  }

  @override
  Future<void> signOut() async {
    await _tokenStorage.clear();
  }
}