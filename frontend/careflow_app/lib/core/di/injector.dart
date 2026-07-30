import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
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
import '../../features/symptoms/data/repositories/symptom_repository_impl.dart';
import '../../features/symptoms/domain/repositories/symptom_repository.dart';
import '../../features/symptoms/domain/usecases/symptom_usecases.dart';
import '../../features/symptoms/presentation/bloc/symptom_analysis_bloc.dart';

/// Service locator. Data sources and repositories are singletons; blocs are
/// registered as factories so each screen gets a fresh instance.
final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
}

void _registerDataSources() {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(AuthInMemoryDataSource.new)
    ..registerLazySingleton<FacilityRemoteDataSource>(
      FacilityInMemoryDataSource.new,
    )
    ..registerLazySingleton<ProfileLocalDataSource>(
      ProfileInMemoryDataSource.new,
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
    ..registerLazySingleton<SymptomRepository>(SymptomRepositoryImpl.new)
    ..registerLazySingleton<HomeRepository>(HomeRepositoryImpl.new)
    ..registerLazySingleton<OnboardingRepository>(OnboardingRepositoryImpl.new);
}

void _registerUseCases() {
  sl
    // auth
    ..registerLazySingleton(() => SignInWithEmail(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignUpWithEmail(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignInWithProvider(sl<AuthRepository>()))
    ..registerLazySingleton(() => VerifyOtp(sl<AuthRepository>()))
    ..registerLazySingleton(() => ResendOtp(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignOut(sl<AuthRepository>()))
    // facilities
    ..registerLazySingleton(() => GetNearbyFacilities(sl<FacilityRepository>()))
    ..registerLazySingleton(() => GetRecommendations(sl<FacilityRepository>()))
    ..registerLazySingleton(() => GetEmergencyMatch(sl<FacilityRepository>()))
    ..registerLazySingleton(() => GetFacilityById(sl<FacilityRepository>()))
    // symptoms
    ..registerLazySingleton(() => AnalyzeSymptoms(sl<SymptomRepository>()))
    ..registerLazySingleton(() => GetQuickSymptoms(sl<SymptomRepository>()))
    ..registerLazySingleton(() => GetRecentSymptoms(sl<SymptomRepository>()))
    // home
    ..registerLazySingleton(() => GetDailyTip(sl<HomeRepository>()))
    ..registerLazySingleton(
      () => GetUnreadNotificationCount(sl<HomeRepository>()),
    )
    // onboarding
    ..registerLazySingleton(
      () => SubmitMedicalProfile(sl<OnboardingRepository>()),
    )
    // profile
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
      () => OtpBloc(verifyOtp: sl<VerifyOtp>(), resendOtp: sl<ResendOtp>()),
    )
    ..registerFactory(
      () => OnboardingBloc(submitMedicalProfile: sl<SubmitMedicalProfile>()),
    )
    ..registerFactory(
      () => HomeBloc(
        getNearbyFacilities: sl<GetNearbyFacilities>(),
        getQuickSymptoms: sl<GetQuickSymptoms>(),
        getRecentSymptoms: sl<GetRecentSymptoms>(),
        getDailyTip: sl<GetDailyTip>(),
        getUnreadNotificationCount: sl<GetUnreadNotificationCount>(),
        patientName: 'Nana Sarpong',
      ),
    )
    ..registerFactory(
      () => SymptomAnalysisBloc(analyzeSymptoms: sl<AnalyzeSymptoms>()),
    )
    ..registerFactory(
      () => RecommendationsBloc(getRecommendations: sl<GetRecommendations>()),
    )
    ..registerFactory(
      () => FacilityDetailBloc(getFacilityById: sl<GetFacilityById>()),
    )
    ..registerFactory(
      () => EmergencyBloc(getEmergencyMatch: sl<GetEmergencyMatch>()),
    )
    ..registerFactory(
      () => MapBloc(getRecommendations: sl<GetRecommendations>()),
    )
    ..registerFactory(
      () => ProfileBloc(
        getPatientProfile: sl<GetPatientProfile>(),
        setNotificationsEnabled: sl<SetNotificationsEnabled>(),
        setEmergencyAlertsEnabled: sl<SetEmergencyAlertsEnabled>(),
        signOut: sl<SignOut>(),
      ),
    );
}
