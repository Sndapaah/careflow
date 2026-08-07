import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInParams extends Equatable {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => <Object?>[email, password];
}

class SignUpParams extends Equatable {
  const SignUpParams({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;

  @override
  List<Object?> get props => <Object?>[fullName, email, phoneNumber, password];
}

class SignInWithEmail implements UseCase<AuthUser, SignInParams> {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthUser> call(SignInParams params) => _repository.signInWithEmail(
    email: params.email,
    password: params.password,
  );
}

class SignUpWithEmail implements UseCase<AuthUser, SignUpParams> {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthUser> call(SignUpParams params) => _repository.signUpWithEmail(
    fullName: params.fullName,
    email: params.email,
    phoneNumber: params.phoneNumber,
    password: params.password,
  );
}

class SignInWithProvider implements UseCase<AuthUser, SocialProvider> {
  const SignInWithProvider(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthUser> call(SocialProvider params) =>
      _repository.signInWithProvider(params);
}

class VerifyOtp implements UseCase<AuthUser, String> {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthUser> call(String params) => _repository.verifyOtp(params);
}

class ResendOtp implements UseCase<Duration, NoParams> {
  const ResendOtp(this._repository);

  final AuthRepository _repository;

  @override
  Future<Duration> call(NoParams params) => _repository.resendOtp();
}

class SignOut implements UseCase<void, NoParams> {
  const SignOut(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.signOut();
}
