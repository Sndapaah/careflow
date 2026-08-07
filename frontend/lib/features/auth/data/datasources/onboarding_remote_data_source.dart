import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../features/onboarding/domain/entities/medical_profile_draft.dart';
import '../../../../core/cache/user_session_cache.dart';

abstract interface class OnboardingRemoteDataSource {
  Future<void> submit(MedicalProfileDraft draft);
}

/// Calls POST /api/auth/addPersonalization/:id on the real CareFlow API.
class OnboardingHttpDataSource implements OnboardingRemoteDataSource {
      OnboardingHttpDataSource({
        required ApiClient apiClient,
        required TokenStorage tokenStorage,
        required UserSessionCache sessionCache,   
      }) : _api = apiClient,
          _tokenStorage = tokenStorage,
          _sessionCache = sessionCache;          

      final ApiClient _api;
      final TokenStorage _tokenStorage;
      final UserSessionCache _sessionCache;       

      @override
      Future<void> submit(MedicalProfileDraft draft) async {
        final String? userId = await _tokenStorage.readUserId();
        if (userId == null) {
          throw const AuthFailure('You need to be signed in to continue.');
        }
        if (draft.gender == null || draft.dateOfBirth == null) {
          throw const ServerFailure('Gender and date of birth are required.');
        }

        final Map<String, dynamic> body = <String, dynamic>{
          'gender': draft.gender!.name,
          'birthdate': draft.dateOfBirth!.toIso8601String(),
          'emergencyContact': <String, dynamic>{
            'fullname': draft.emergencyContact.fullName,
            'relType': draft.emergencyContact.relationship,
            'contact': draft.emergencyContact.phoneNumber,
          },
          'existingHealthConds': draft.conditions.toList(),
          'allergies': draft.allergies.toList(),
          'bloodType': draft.bloodType,
        };

        await _api.post(
          '/auth/addPersonalization/$userId',
          authenticated: true,
          body: body,
        );

        _sessionCache.patch(body);   
      }
    }