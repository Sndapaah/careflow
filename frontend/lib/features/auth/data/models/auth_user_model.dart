import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    super.isVerified,
    super.hasCompletedOnboarding,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
    id: json['id'] as String,
    fullName: json['full_name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phoneNumber: json['phone_number'] as String? ?? '',
    isVerified: json['is_verified'] as bool? ?? false,
    hasCompletedOnboarding: json['has_completed_onboarding'] as bool? ?? false,
  );

  /// Maps the CareFlow Express API's actual field names, which differ from
  /// the snake_case shape [fromJson] expects (kept for compatibility with
  /// any local caching that already used it).
  factory AuthUserModel.fromBackendJson(
    Map<String, dynamic> json, {
    bool isVerified = false,
  }) => AuthUserModel(
    id: json['_id'] as String? ?? json['id'] as String,
    fullName: json['fullname'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phoneNumber: json['contact'] as String? ?? '',
    isVerified: isVerified,
    // Backend has no explicit "onboarding complete" flag; birthdate/gender
    // are only ever set via addPersonalization, so their presence is a
    // reasonable stand-in until the backend adds a real flag.
    hasCompletedOnboarding:
        json['birthdate'] != null && json['gender'] != null,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'full_name': fullName,
    'email': email,
    'phone_number': phoneNumber,
    'is_verified': isVerified,
    'has_completed_onboarding': hasCompletedOnboarding,
  };
}