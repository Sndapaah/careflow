import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/bloc_status.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/facility.dart';
import '../../domain/usecases/facility_usecases.dart';

// ----------------------------------------------------------------- events

sealed class FacilityDetailEvent extends Equatable {
  const FacilityDetailEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FacilityDetailRequested extends FacilityDetailEvent {
  const FacilityDetailRequested(this.facilityId);

  final String facilityId;

  @override
  List<Object?> get props => <Object?>[facilityId];
}

// ------------------------------------------------------------------ state

class FacilityDetailState extends Equatable {
  const FacilityDetailState({
    this.status = BlocStatus.initial,
    this.facility,
    this.errorMessage,
  });

  final BlocStatus status;
  final Facility? facility;
  final String? errorMessage;

  @override
  List<Object?> get props => <Object?>[status, facility, errorMessage];
}

// ------------------------------------------------------------------- bloc

class FacilityDetailBloc
    extends Bloc<FacilityDetailEvent, FacilityDetailState> {
  FacilityDetailBloc({required GetFacilityById getFacilityById})
    : _getFacilityById = getFacilityById,
      super(const FacilityDetailState()) {
    on<FacilityDetailRequested>(_onRequested);
  }

  final GetFacilityById _getFacilityById;

  Future<void> _onRequested(
    FacilityDetailRequested event,
    Emitter<FacilityDetailState> emit,
  ) async {
    emit(const FacilityDetailState(status: BlocStatus.loading));
    try {
      final Facility facility = await _getFacilityById(event.facilityId);
      emit(FacilityDetailState(status: BlocStatus.success, facility: facility));
    } on Failure catch (failure) {
      emit(
        FacilityDetailState(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }
}
