import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/onboarding_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/login_bloc.dart';
import '../../features/auth/presentation/bloc/otp_bloc.dart';
import '../../features/auth/presentation/bloc/register_bloc.dart';

import '../../features/facilities/data/datasources/facility_remote_data_source.dart';
import '../../features/facilities/data/repositories/facility_repository_impl.dart';
import '../../features/facilities/domain/repositories/facility_repository.dart';
import '../../features/facilities/domain/usecases/facility_usecases.dart';
import '../../features/facilities/presentation/bloc/emergency_bloc.dart';
import '../../features/facilities/presentation/bloc/facility_detail_bloc.dart';
import '../../features/facilities/presentation/bloc/map_bloc.dart';
import '../../features/facilities/presentation/bloc/recommendations_bloc.dart';

import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/home_usecases.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/submit_medical_profile.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';

import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/profile_usecases.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

import '../../features/symptoms/domain/repositories/symptom_repository.dart';
import '../../features/symptoms/domain/usecases/symptom_usecases.dart';
import '../../features/symptoms/presentation/bloc/symptom_analysis_bloc.dart';

import '../../core/location/current_location_provider.dart';
import '../../core/cache/last_diagnosis_cache.dart';
import '../../features/symptoms/data/repositories/symptom_http_repository_impl.dart';
import '../../core/cache/user_session_cache.dart'; 
import '../../features/profile/data/datasources/profile_http_data_source.dart';

import '../network/api_client.dart';
import '../network/token_storage.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
}

void _registerDataSources() {
  sl
    ..registerLazySingleton<ApiClient>(ApiClient.new)
    ..registerLazySingleton<TokenStorage>(TokenStorage.new)
    ..registerLazySingleton<CurrentLocationProvider>(CurrentLocationProvider.new)
    ..registerLazySingleton<LastDiagnosisCache>(LastDiagnosisCache.new)

    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthHttpDataSource(
        apiClient: sl<ApiClient>(),
        tokenStorage: sl<TokenStorage>(),
        sessionCache: sl<UserSessionCache>(),
      ),
    )

    ..registerLazySingleton<OnboardingRemoteDataSource>(
      () => OnboardingHttpDataSource(
        apiClient: sl<ApiClient>(),
        tokenStorage: sl<TokenStorage>(),
        sessionCache: sl<UserSessionCache>(),
      ),
    )

    ..registerLazySingleton<FacilityRemoteDataSource>(
      () => FacilityHttpDataSource(
        apiClient: sl<ApiClient>(),
        locationProvider: sl<CurrentLocationProvider>(),
        diagnosisCache: sl<LastDiagnosisCache>(),
      ),
    )

    ..registerLazySingleton(() => UpdateProfile(sl<ProfileRepository>()))

    ..registerLazySingleton<UserSessionCache>(UserSessionCache.new)

    ..registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileHttpDataSource(
      sessionCache: sl<UserSessionCache>(),
      apiClient: sl<ApiClient>(),
      tokenStorage: sl<TokenStorage>(),
    ),
  );
}

void _registerRepositories() {
  sl
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
    )

    ..registerLazySingleton<FacilityRepository>(
      () => FacilityRepositoryImpl(sl<FacilityRemoteDataSource>()),
    )

    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<ProfileLocalDataSource>()),
    )

    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(sl<OnboardingRemoteDataSource>()),
    )

    ..registerLazySingleton<SymptomRepository>(
      () => SymptomHttpRepositoryImpl(
        apiClient: sl<ApiClient>(),
        locationProvider: sl<CurrentLocationProvider>(),
        profileRepository: sl<ProfileRepository>(),
        diagnosisCache: sl<LastDiagnosisCache>(),
      ),
    )

    ..registerLazySingleton<HomeRepository>(HomeRepositoryImpl.new);   // ← was missing entirely
}

void _registerUseCases() {
  sl
    ..registerLazySingleton(() => SignInWithEmail(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignUpWithEmail(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignInWithProvider(sl<AuthRepository>()))
    ..registerLazySingleton(() => VerifyOtp(sl<AuthRepository>()))
    ..registerLazySingleton(() => ResendOtp(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignOut(sl<AuthRepository>()))

    ..registerLazySingleton(() => GetNearbyFacilities(sl<FacilityRepository>()))
    ..registerLazySingleton(() => GetRecommendations(sl<FacilityRepository>()))
    ..registerLazySingleton(() => GetEmergencyMatch(sl<FacilityRepository>()))
    ..registerLazySingleton(() => GetFacilityById(sl<FacilityRepository>()))

    ..registerLazySingleton(() => AnalyzeSymptoms(sl<SymptomRepository>()))
    ..registerLazySingleton(() => GetQuickSymptoms(sl<SymptomRepository>()))
    ..registerLazySingleton(() => GetRecentSymptoms(sl<SymptomRepository>()))

    ..registerLazySingleton(() => GetDailyTip(sl<HomeRepository>()))
    ..registerLazySingleton(
      () => GetUnreadNotificationCount(sl<HomeRepository>()),
    )

    ..registerLazySingleton(
      () => SubmitMedicalProfile(sl<OnboardingRepository>()),
    )

    ..registerLazySingleton(() => GetPatientProfile(sl<ProfileRepository>()))
    ..registerLazySingleton(
      () => SetNotificationsEnabled(sl<ProfileRepository>()),
    )
    ..registerLazySingleton(
      () => SetEmergencyAlertsEnabled(sl<ProfileRepository>()),
    );
}

void _registerBlocs() {
  sl
    ..registerFactory(
      () => LoginBloc(
        signInWithEmail: sl<SignInWithEmail>(),
        signInWithProvider: sl<SignInWithProvider>(),
      ),
    )

    ..registerFactory(
      () => RegisterBloc(
        signUpWithEmail: sl<SignUpWithEmail>(),
        signInWithProvider: sl<SignInWithProvider>(),
      ),
    )

    ..registerFactory(
      () => OtpBloc(
        verifyOtp: sl<VerifyOtp>(),
        resendOtp: sl<ResendOtp>(),
      ),
    )

    ..registerFactory(
      () => OnboardingBloc(
        submitMedicalProfile: sl<SubmitMedicalProfile>(),
      ),
    )

    ..registerFactory(() {
    final Map<String, dynamic>? user = sl<UserSessionCache>().current;
    final String name = (user?['fullname'] as String?) ?? 'there';
    return HomeBloc(
      getNearbyFacilities: sl<GetNearbyFacilities>(),
      getQuickSymptoms: sl<GetQuickSymptoms>(),
      getRecentSymptoms: sl<GetRecentSymptoms>(),
      getDailyTip: sl<GetDailyTip>(),
      getUnreadNotificationCount: sl<GetUnreadNotificationCount>(),
      patientName: name,
    );
  }
)

    ..registerFactory(
      () => SymptomAnalysisBloc(
        analyzeSymptoms: sl<AnalyzeSymptoms>(),
      ),
    )

    ..registerFactory(
      () => RecommendationsBloc(
        getRecommendations: sl<GetRecommendations>(),
      ),
    )

    ..registerFactory(
      () => FacilityDetailBloc(
        getFacilityById: sl<GetFacilityById>(),
      ),
    )

    ..registerFactory(
      () => EmergencyBloc(
        getEmergencyMatch: sl<GetEmergencyMatch>(),
      ),
    )

    ..registerFactory(
      () => MapBloc(
        getRecommendations: sl<GetRecommendations>(),
      ),
    )

    ..registerFactory(
      () => ProfileBloc(
        getPatientProfile: sl<GetPatientProfile>(),
        setNotificationsEnabled: sl<SetNotificationsEnabled>(),
        setEmergencyAlertsEnabled: sl<SetEmergencyAlertsEnabled>(),
        updateProfile: sl<UpdateProfile>(),
        signOut: sl<SignOut>(),
      ),
    );
}