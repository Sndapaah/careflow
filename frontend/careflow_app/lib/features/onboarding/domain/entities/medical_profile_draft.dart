import 'package:equatable/equatable.dart';

import '../../../profile/domain/entities/patient_profile.dart';

/// The answers collected across the five onboarding steps.
///
/// Kept as an immutable draft so the bloc can rebuild it step by step and the
/// UI can validate "can this step advance?" from a single source.
class MedicalProfileDraft extends Equatable {
  const MedicalProfileDraft({
    this.gender,
    this.dateOfBirth,
    this.conditions = const <String>{},
    this.allergies = const <String>{},
    this.emergencyContact = EmergencyContact.empty,
    this.bloodType,
  });

  final Gender? gender;
  final DateTime? dateOfBirth;
  final Set<String> conditions;
  final Set<String> allergies;
  final EmergencyContact emergencyContact;
  final String? bloodType;

  /// Options offered on step 2.
  static const List<String> conditionOptions = <String>[
    'Hypertension',
    'Diabetes',
    'Asthma',
    'Kidney disease',
    'Heart disease',
    'Other',
    'None',
  ];

  /// Options offered on step 3.
  static const List<String> allergyOptions = <String>[
    'Penicillin',
    'Seafood',
    'Latex',
    'Nuts',
    'Other',
    'None',
  ];

  /// Options offered on step 5.
  static const List<String> bloodTypeOptions = <String>[
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  static const List<String> relationshipOptions = <String>[
    'Parent',
    'Sibling',
    'Spouse',
    'Child',
    'Relative',
    'Friend',
    'Guardian',
    'Other',
  ];

  /// The exclusive option — picking it clears every other selection.
  static const String noneOption = 'None';

  MedicalProfileDraft copyWith({
    Gender? gender,
    DateTime? dateOfBirth,
    Set<String>? conditions,
    Set<String>? allergies,
    EmergencyContact? emergencyContact,
    String? bloodType,
  }) => MedicalProfileDraft(
    gender: gender ?? this.gender,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    conditions: conditions ?? this.conditions,
    allergies: allergies ?? this.allergies,
    emergencyContact: emergencyContact ?? this.emergencyContact,
    bloodType: bloodType ?? this.bloodType,
  );

  bool get isIdentityComplete => gender != null && dateOfBirth != null;

  bool get isContactComplete => emergencyContact.isComplete;

  /// Whether the given zero-based step has enough input to move forward.
  bool canAdvanceFrom(int step) => switch (step) {
    0 => isIdentityComplete,
    1 => conditions.isNotEmpty,
    2 => allergies.isNotEmpty,
    3 => isContactComplete,
    4 => bloodType != null,
    _ => false,
  };

  @override
  List<Object?> get props => <Object?>[
    gender,
    dateOfBirth,
    conditions,
    allergies,
    emergencyContact,
    bloodType,
  ];
}
