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

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'full_name': fullName,
    'email': email,
    'phone_number': phoneNumber,
    'is_verified': isVerified,
    'has_completed_onboarding': hasCompletedOnboarding,
  };
}
