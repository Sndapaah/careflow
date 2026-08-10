import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/bloc_status.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../facilities/domain/entities/facility.dart';
import '../../../facilities/domain/usecases/facility_usecases.dart';
import '../../../symptoms/domain/entities/symptom_analysis.dart';
import '../../../symptoms/domain/usecases/symptom_usecases.dart';
import '../../domain/entities/health_tip.dart';
import '../../domain/usecases/home_usecases.dart';

// ----------------------------------------------------------------- events

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads everything the home screen shows. Also used for pull-to-refresh.
final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class HomeSymptomQueryChanged extends HomeEvent {
  const HomeSymptomQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

/// Tapping one of the suggestion chips fills the search field.
final class HomeQuickSymptomSelected extends HomeEvent {
  const HomeQuickSymptomSelected(this.symptom);

  final String symptom;

  @override
  List<Object?> get props => <Object?>[symptom];
}

// ------------------------------------------------------------------ state

class HomeState extends Equatable {
  const HomeState({
    this.status = BlocStatus.initial,
    this.patientName = '',
    this.unreadNotifications = 0,
    this.nearby = const <Facility>[],
    this.quickSymptoms = const <String>[],
    this.recentSymptoms = const <RecentSymptom>[],
    this.tip,
    this.symptomQuery = '',
    this.errorMessage,
    this.isLoadingNearby = false,
  });

  final BlocStatus status;
  final String patientName;
  final int unreadNotifications;
  final List<Facility> nearby;
  final List<String> quickSymptoms;
  final List<RecentSymptom> recentSymptoms;
  final HealthTip? tip;
  final String symptomQuery;
  final String? errorMessage;

  /// True while the nearby-facilities network read is still in flight, so the
  /// strip can show its own loader without blocking the rest of the page.
  final bool isLoadingNearby;

  bool get canAnalyze => symptomQuery.trim().isNotEmpty;

  /// "Good Morning" / "Good Afternoon" / "Good Evening".
  String get greeting {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  HomeState copyWith({
    BlocStatus? status,
    String? patientName,
    int? unreadNotifications,
    List<Facility>? nearby,
    List<String>? quickSymptoms,
    List<RecentSymptom>? recentSymptoms,
    HealthTip? tip,
    String? symptomQuery,
    String? errorMessage,
    bool clearError = false,
    bool? isLoadingNearby,
  }) => HomeState(
    status: status ?? this.status,
    patientName: patientName ?? this.patientName,
    unreadNotifications: unreadNotifications ?? this.unreadNotifications,
    nearby: nearby ?? this.nearby,
    quickSymptoms: quickSymptoms ?? this.quickSymptoms,
    recentSymptoms: recentSymptoms ?? this.recentSymptoms,
    tip: tip ?? this.tip,
    symptomQuery: symptomQuery ?? this.symptomQuery,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    isLoadingNearby: isLoadingNearby ?? this.isLoadingNearby,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    patientName,
    unreadNotifications,
    nearby,
    quickSymptoms,
    recentSymptoms,
    tip,
    symptomQuery,
    errorMessage,
    isLoadingNearby,
  ];
}

// ------------------------------------------------------------------- bloc

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required GetNearbyFacilities getNearbyFacilities,
    required GetQuickSymptoms getQuickSymptoms,
    required GetRecentSymptoms getRecentSymptoms,
    required GetDailyTip getDailyTip,
    required GetUnreadNotificationCount getUnreadNotificationCount,
    required String patientName,
  }) : _getNearbyFacilities = getNearbyFacilities,
      _getQuickSymptoms = getQuickSymptoms,
      _getRecentSymptoms = getRecentSymptoms,
      _getDailyTip = getDailyTip,
      _getUnreadNotificationCount = getUnreadNotificationCount,
      super(HomeState(patientName: patientName)) {
    on<HomeStarted>(_onStarted);
    on<HomeSymptomQueryChanged>(
      (HomeSymptomQueryChanged e, Emitter<HomeState> emit) =>
          emit(state.copyWith(symptomQuery: e.query)),
    );
    on<HomeQuickSymptomSelected>(
      (HomeQuickSymptomSelected e, Emitter<HomeState> emit) =>
          emit(state.copyWith(symptomQuery: e.symptom)),
    );
  }

  final GetNearbyFacilities _getNearbyFacilities;
  final GetQuickSymptoms _getQuickSymptoms;
  final GetRecentSymptoms _getRecentSymptoms;
  final GetDailyTip _getDailyTip;
  final GetUnreadNotificationCount _getUnreadNotificationCount;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));

    // Phase 1 — local, instant reads (tip, quick symptoms, notification count).
    // Emit these straight away so the page paints immediately instead of
    // waiting behind the slower network calls below.
    final List<String> quickSymptoms =
        await _guard(() => _getQuickSymptoms(const NoParams()), const <String>[]);
    final HealthTip? tip =
        await _guard<HealthTip?>(() => _getDailyTip(const NoParams()), null);
    final int unread =
        await _guard(() => _getUnreadNotificationCount(const NoParams()), 0);

    emit(
      state.copyWith(
        status: BlocStatus.success,
        quickSymptoms: quickSymptoms,
        tip: tip,
        unreadNotifications: unread,
        isLoadingNearby: true,
      ),
    );

    // Phase 2 — network reads. Each is guarded on its own so a slow, failing,
    // or malformed response degrades just its section (to empty) instead of
    // freezing the whole screen or leaving the bloc stuck on the spinner.
    final List<Object?> results = await Future.wait(<Future<Object?>>[
      _guard<List<Facility>>(
        () => _getNearbyFacilities(const NoParams()),
        const <Facility>[],
      ),
      _guard<List<RecentSymptom>>(
        () => _getRecentSymptoms(const NoParams()),
        const <RecentSymptom>[],
      ),
    ]);

    emit(
      state.copyWith(
        nearby: results[0] as List<Facility>,
        recentSymptoms: results[1] as List<RecentSymptom>,
        isLoadingNearby: false,
      ),
    );
  }

  /// Runs [run] and swallows any error, returning [fallback] instead. Keeps a
  /// single failing read from taking down the whole home screen — every read
  /// here is optional to the page rendering.
  Future<T> _guard<T>(Future<T> Function() run, T fallback) async {
    try {
      return await run();
    } catch (_) {
      return fallback;
    }
  }
}
