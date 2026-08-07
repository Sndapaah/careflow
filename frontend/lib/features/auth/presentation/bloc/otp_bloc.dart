import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/bloc_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/auth_usecases.dart';

// ----------------------------------------------------------------- events

sealed class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Starts the validity countdown when the screen opens.
final class OtpStarted extends OtpEvent {
  const OtpStarted();
}

final class OtpCodeChanged extends OtpEvent {
  const OtpCodeChanged(this.code);

  final String code;

  @override
  List<Object?> get props => <Object?>[code];
}

final class OtpSubmitted extends OtpEvent {
  const OtpSubmitted();
}

final class OtpResendPressed extends OtpEvent {
  const OtpResendPressed();
}

/// Emitted once a second by the internal timer.
final class OtpTicked extends OtpEvent {
  const OtpTicked();
}

// ------------------------------------------------------------------ state

class OtpState extends Equatable {
  const OtpState({
    this.status = BlocStatus.initial,
    this.code = '',
    this.remaining = Duration.zero,
    this.user,
    this.errorMessage,
  });

  static const int codeLength = 6;

  final BlocStatus status;
  final String code;
  final Duration remaining;
  final AuthUser? user;
  final String? errorMessage;

  bool get isComplete => code.length == codeLength;

  bool get hasExpired => remaining == Duration.zero;

  /// "2:59"
  String get countdownLabel {
    final int minutes = remaining.inMinutes;
    final int seconds = remaining.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  OtpState copyWith({
    BlocStatus? status,
    String? code,
    Duration? remaining,
    AuthUser? user,
    String? errorMessage,
    bool clearError = false,
  }) => OtpState(
    status: status ?? this.status,
    code: code ?? this.code,
    remaining: remaining ?? this.remaining,
    user: user ?? this.user,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    code,
    remaining,
    user,
    errorMessage,
  ];
}

// ------------------------------------------------------------------- bloc

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  OtpBloc({required VerifyOtp verifyOtp, required ResendOtp resendOtp})
    : _verifyOtp = verifyOtp,
      _resendOtp = resendOtp,
      super(const OtpState()) {
    on<OtpStarted>(_onStarted);
    on<OtpCodeChanged>(_onCodeChanged);
    on<OtpTicked>(_onTicked);
    on<OtpSubmitted>(_onSubmitted);
    on<OtpResendPressed>(_onResendPressed);
  }

  static const Duration _validity = Duration(minutes: 5);

  final VerifyOtp _verifyOtp;
  final ResendOtp _resendOtp;

  Timer? _timer;

  void _onStarted(OtpStarted event, Emitter<OtpState> emit) {
    emit(state.copyWith(remaining: _validity, clearError: true));
    _startTimer();
  }

  void _onCodeChanged(OtpCodeChanged event, Emitter<OtpState> emit) {
    emit(state.copyWith(code: event.code, clearError: true));
  }

  void _onTicked(OtpTicked event, Emitter<OtpState> emit) {
    if (state.remaining <= const Duration(seconds: 1)) {
      _timer?.cancel();
      emit(state.copyWith(remaining: Duration.zero));
      return;
    }
    emit(
      state.copyWith(remaining: state.remaining - const Duration(seconds: 1)),
    );
  }

  Future<void> _onSubmitted(OtpSubmitted event, Emitter<OtpState> emit) async {
    if (!state.isComplete) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: 'Enter all six digits.',
        ),
      );
      return;
    }
    if (state.hasExpired) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: 'That code expired. Request a new one.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      final AuthUser user = await _verifyOtp(state.code);
      _timer?.cancel();
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

  Future<void> _onResendPressed(
    OtpResendPressed event,
    Emitter<OtpState> emit,
  ) async {
    emit(
      state.copyWith(status: BlocStatus.loading, code: '', clearError: true),
    );
    try {
      final Duration validity = await _resendOtp(const NoParams());
      emit(state.copyWith(status: BlocStatus.initial, remaining: validity));
      _startTimer();
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) add(const OtpTicked());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
