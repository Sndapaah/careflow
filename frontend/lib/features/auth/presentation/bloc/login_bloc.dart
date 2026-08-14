import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/bloc_status.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/auth_usecases.dart';

// ----------------------------------------------------------------- events

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class LoginEmailChanged extends LoginEvent {
  const LoginEmailChanged(this.email);

  final String email;

  @override
  List<Object?> get props => <Object?>[email];
}

final class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password);

  final String password;

  @override
  List<Object?> get props => <Object?>[password];
}

final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

final class LoginWithProviderPressed extends LoginEvent {
  const LoginWithProviderPressed(this.provider);

  final SocialProvider provider;

  @override
  List<Object?> get props => <Object?>[provider];
}

// ------------------------------------------------------------------ state

class LoginState extends Equatable {
  const LoginState({
    this.status = BlocStatus.initial,
    this.email = '',
    this.password = '',
    this.user,
    this.errorMessage,
  });

  final BlocStatus status;
  final String email;
  final String password;
  final AuthUser? user;
  final String? errorMessage;

  bool get canSubmit => email.contains('@') && password.length >= 6;

  LoginState copyWith({
    BlocStatus? status,
    String? email,
    String? password,
    AuthUser? user,
    String? errorMessage,
    bool clearError = false,
  }) => LoginState(
    status: status ?? this.status,
    email: email ?? this.email,
    password: password ?? this.password,
    user: user ?? this.user,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    email,
    password,
    user,
    errorMessage,
  ];
}

// ------------------------------------------------------------------- bloc

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required SignInWithEmail signInWithEmail,
    required SignInWithProvider signInWithProvider,
  }) : _signInWithEmail = signInWithEmail,
       _signInWithProvider = signInWithProvider,
       super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginWithProviderPressed>(_onProviderPressed);
  }

  final SignInWithEmail _signInWithEmail;
  final SignInWithProvider _signInWithProvider;

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email, clearError: true));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password, clearError: true));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.canSubmit) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: 'Enter a valid email and a password of 6+ characters.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    await _run(
      emit,
      () => _signInWithEmail(
        SignInParams(email: state.email, password: state.password),
      ),
    );
  }

  Future<void> _onProviderPressed(
    LoginWithProviderPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    await _run(emit, () => _signInWithProvider(event.provider));
  }

  Future<void> _run(
    Emitter<LoginState> emit,
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
