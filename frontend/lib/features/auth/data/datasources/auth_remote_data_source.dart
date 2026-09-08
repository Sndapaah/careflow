import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/cache/user_session_cache.dart';
import '../../domain/entities/auth_user.dart';
import '../models/auth_user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/network/api_config.dart';

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
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword({required String email, required String otp, required String password});
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

    final Object? rawId = json['_id'] ?? json['id'];
    if (rawId is! String || rawId.isEmpty) {
      final Object? rawMessage = json['message'] ?? json['error'];
      final String message = rawMessage is String && rawMessage.isNotEmpty
          ? rawMessage
          : 'Registration failed.';
      throw AuthFailure(message);
    }

    _pendingId = rawId;
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

    // The current backend wraps the user in `user`, while some deployments
    // return the user fields at the top level. Support both envelopes.
    final Object? dataField = json['data'];
    final Map<String, dynamic>? dataJson = dataField is Map<String, dynamic>
        ? dataField
        : null;
    final Object? userField = json['user'] ?? dataJson?['user'];
    final Map<String, dynamic>? userJson = userField is Map<String, dynamic>
        ? userField
        : (dataJson != null &&
              (dataJson['_id'] != null || dataJson['id'] != null))
        ? dataJson
        : (json['_id'] != null || json['id'] != null)
        ? json
        : null;
    if (userJson == null) {
      final Object? rawMessage = json['message'] ?? json['error'];
      final String message = rawMessage is String && rawMessage.isNotEmpty
          ? rawMessage
          : 'Login response did not contain a user account.';
      throw AuthFailure(message);
    }

    final String? token = userJson['accessToken'] as String?;
    if (token != null) await _tokenStorage.save(token);

    final String? userId = userJson['_id'] as String?;
    if (userId != null) await _tokenStorage.saveUserId(userId);

    _sessionCache.store(userJson);
    await _tokenStorage.saveUser(userJson);

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
    if (provider != SocialProvider.google) {
      throw const ServerFailure('This sign-in provider is not available yet.');
    }
    return _signInWithGoogle();
  }

  Future<AuthUserModel> _signInWithGoogle() async {
    final GoogleSignInAccount? account = await GoogleSignIn(
      serverClientId: ApiConfig.googleServerClientId.isEmpty
          ? null
          : ApiConfig.googleServerClientId,
    ).signIn();
    if (account == null) throw const AuthFailure('Google sign-in was cancelled.');
    final GoogleSignInAuthentication auth = await account.authentication;
    final String? idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const AuthFailure('Google did not return an identity token.');
    }
    final Map<String, dynamic> json = await _api.post(
      '/auth/google',
      body: <String, dynamic>{'idToken': idToken},
    );
    final Map<String, dynamic>? user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : null;
    final String? token = user?['accessToken'] as String?;
    final String? userId = user?['_id']?.toString();
    if (user == null || token == null || userId == null) {
      throw AuthFailure((json['message'] ?? 'Google sign-in failed.').toString());
    }
    await _tokenStorage.save(token);
    await _tokenStorage.saveUserId(userId);
    _sessionCache.store(user);
    await _tokenStorage.saveUser(user);
    return AuthUserModel.fromBackendJson(user, isVerified: true);
  }

  @override
  Future<void> signOut() async {
    await _tokenStorage.clear();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _api.post('/auth/resetPassword', body: <String, dynamic>{'email': email});
  }

  @override
  Future<void> resetPassword({required String email, required String otp, required String password}) async {
    await _api.post('/auth/reset-user-password', body: <String, dynamic>{'email': email, 'otp': otp, 'password': password});
  }
}
