import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/bloc_status.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/auth_usecases.dart';

// ----------------------------------------------------------------- events

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class RegisterFullNameChanged extends RegisterEvent {
  const RegisterFullNameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => <Object?>[value];
}

final class RegisterEmailChanged extends RegisterEvent {
  const RegisterEmailChanged(this.value);

  final String value;

  @override
  List<Object?> get props => <Object?>[value];
}

final class RegisterPhoneChanged extends RegisterEvent {
  const RegisterPhoneChanged(this.value);

  final String value;

  @override
  List<Object?> get props => <Object?>[value];
}

final class RegisterPasswordChanged extends RegisterEvent {
  const RegisterPasswordChanged(this.value);

  final String value;

  @override
  List<Object?> get props => <Object?>[value];
}

final class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted();
}

final class RegisterWithProviderPressed extends RegisterEvent {
  const RegisterWithProviderPressed(this.provider);

  final SocialProvider provider;

  @override
  List<Object?> get props => <Object?>[provider];
}

// ------------------------------------------------------------------ state

class RegisterState extends Equatable {
  const RegisterState({
    this.status = BlocStatus.initial,
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.password = '',
    this.user,
    this.errorMessage,
  });

  final BlocStatus status;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final AuthUser? user;
  final String? errorMessage;

  bool get canSubmit =>
      fullName.trim().length >= 2 &&
      email.contains('@') &&
      phoneNumber.trim().length >= 9 &&
      password.length >= 6;

  RegisterState copyWith({
    BlocStatus? status,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? password,
    AuthUser? user,
    String? errorMessage,
    bool clearError = false,
  }) => RegisterState(
    status: status ?? this.status,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    password: password ?? this.password,
    user: user ?? this.user,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    fullName,
    email,
    phoneNumber,
    password,
    user,
    errorMessage,
  ];
}

// ------------------------------------------------------------------- bloc

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required SignUpWithEmail signUpWithEmail,
    required SignInWithProvider signInWithProvider,
  }) : _signUpWithEmail = signUpWithEmail,
       _signInWithProvider = signInWithProvider,
       super(const RegisterState()) {
    on<RegisterFullNameChanged>(
      (RegisterFullNameChanged e, Emitter<RegisterState> emit) =>
          emit(state.copyWith(fullName: e.value, clearError: true)),
    );
    on<RegisterEmailChanged>(
      (RegisterEmailChanged e, Emitter<RegisterState> emit) =>
          emit(state.copyWith(email: e.value, clearError: true)),
    );
    on<RegisterPhoneChanged>(
      (RegisterPhoneChanged e, Emitter<RegisterState> emit) =>
          emit(state.copyWith(phoneNumber: e.value, clearError: true)),
    );
    on<RegisterPasswordChanged>(
      (RegisterPasswordChanged e, Emitter<RegisterState> emit) =>
          emit(state.copyWith(password: e.value, clearError: true)),
    );
    on<RegisterSubmitted>(_onSubmitted);
    on<RegisterWithProviderPressed>(_onProviderPressed);
  }

  final SignUpWithEmail _signUpWithEmail;
  final SignInWithProvider _signInWithProvider;

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (!state.canSubmit) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: 'Please fill in every field before continuing.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    await _run(
      emit,
      () => _signUpWithEmail(
        SignUpParams(
          fullName: state.fullName,
          email: state.email,
          phoneNumber: state.phoneNumber,
          password: state.password,
        ),
      ),
    );
  }

  Future<void> _onProviderPressed(
    RegisterWithProviderPressed event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    await _run(emit, () => _signInWithProvider(event.provider));
  }

  Future<void> _run(
    Emitter<RegisterState> emit,
    Future<AuthUser> Function() action,
  ) async {
    try {
      final AuthUser user = await action();
      emit(state.copyWith(status: BlocStatus.success, user: user));
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }
}
