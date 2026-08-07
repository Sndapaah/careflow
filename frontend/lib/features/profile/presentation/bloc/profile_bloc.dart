import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/bloc_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/usecases/profile_usecases.dart';

// ----------------------------------------------------------------- events

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

final class ProfileNotificationsToggled extends ProfileEvent {
  const ProfileNotificationsToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

final class ProfileEmergencyAlertsToggled extends ProfileEvent {
  const ProfileEmergencyAlertsToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

final class ProfileSignOutRequested extends ProfileEvent {
  const ProfileSignOutRequested();
}

final class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested(this.updated);

  final PatientProfile updated;

  @override
  List<Object?> get props => <Object?>[updated];
}

// ------------------------------------------------------------------ state

class ProfileState extends Equatable {
  const ProfileState({
    this.status = BlocStatus.initial,
    this.profile,
    this.isSignedOut = false,
    this.errorMessage,
  });

  final BlocStatus status;
  final PatientProfile? profile;
  final bool isSignedOut;
  final String? errorMessage;

  ProfileState copyWith({
    BlocStatus? status,
    PatientProfile? profile,
    bool? isSignedOut,
    String? errorMessage,
    bool clearError = false,
  }) => ProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    isSignedOut: isSignedOut ?? this.isSignedOut,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    profile,
    isSignedOut,
    errorMessage,
  ];
}

// ------------------------------------------------------------------- bloc

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetPatientProfile getPatientProfile,
    required SetNotificationsEnabled setNotificationsEnabled,
    required SetEmergencyAlertsEnabled setEmergencyAlertsEnabled,
    required UpdateProfile updateProfile,
    required SignOut signOut,
  }) : _getPatientProfile = getPatientProfile,
       _setNotificationsEnabled = setNotificationsEnabled,
       _setEmergencyAlertsEnabled = setEmergencyAlertsEnabled,
       _updateProfile = updateProfile,
       _signOut = signOut,
       super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
    on<ProfileNotificationsToggled>(_onNotificationsToggled);
    on<ProfileEmergencyAlertsToggled>(_onEmergencyAlertsToggled);
    on<ProfileSignOutRequested>(_onSignOutRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
  }
  final UpdateProfile _updateProfile;
  final GetPatientProfile _getPatientProfile;
  final SetNotificationsEnabled _setNotificationsEnabled;
  final SetEmergencyAlertsEnabled _setEmergencyAlertsEnabled;
  final SignOut _signOut;

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    await _load(emit, () => _getPatientProfile(const NoParams()));
  }

  Future<void> _onNotificationsToggled(
    ProfileNotificationsToggled event,
    Emitter<ProfileState> emit,
  ) async {
    await _load(emit, () => _setNotificationsEnabled(event.enabled));
  }

  Future<void> _onEmergencyAlertsToggled(
    ProfileEmergencyAlertsToggled event,
    Emitter<ProfileState> emit,
  ) async {
    await _load(emit, () => _setEmergencyAlertsEnabled(event.enabled));
  }

  Future<void> _onSignOutRequested(
    ProfileSignOutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _signOut(const NoParams());
      emit(state.copyWith(isSignedOut: true));
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }

  Future<void> _load(
    Emitter<ProfileState> emit,
    Future<PatientProfile> Function() action,
  ) async {
    try {
      final PatientProfile profile = await action();
      emit(state.copyWith(status: BlocStatus.success, profile: profile));
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Set status to loading and clear previous errors while processing
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    
    try {
      // Execute your UpdateProfile usecase contract passing the updated payload
      final PatientProfile profile = await _updateProfile(event.updated);
      emit(state.copyWith(status: BlocStatus.success, profile: profile));
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
