import 'package:equatable/equatable.dart';

/// Third-party identity providers offered on the auth screens.
enum SocialProvider { google, facebook }

/// The signed-in account.
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber = '',
    this.isVerified = false,
    this.hasCompletedOnboarding = false,
  });

  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final bool isVerified;
  final bool hasCompletedOnboarding;

  AuthUser copyWith({bool? isVerified, bool? hasCompletedOnboarding}) {
    return AuthUser(
      id: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      isVerified: isVerified ?? this.isVerified,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    fullName,
    email,
    phoneNumber,
    isVerified,
    hasCompletedOnboarding,
  ];
}
