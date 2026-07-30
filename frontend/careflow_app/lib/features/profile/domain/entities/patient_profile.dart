import 'package:equatable/equatable.dart';

enum Gender {
  male('Male'),
  female('Female');

  const Gender(this.label);

  final String label;
}

/// Who to call on the patient's behalf in an emergency.
class EmergencyContact extends Equatable {
  const EmergencyContact({
    required this.fullName,
    required this.relationship,
    required this.phoneNumber,
  });

  static const EmergencyContact empty = EmergencyContact(
    fullName: '',
    relationship: '',
    phoneNumber: '',
  );

  final String fullName;
  final String relationship;
  final String phoneNumber;

  bool get isComplete =>
      fullName.isNotEmpty && relationship.isNotEmpty && phoneNumber.isNotEmpty;

  EmergencyContact copyWith({
    String? fullName,
    String? relationship,
    String? phoneNumber,
  }) => EmergencyContact(
    fullName: fullName ?? this.fullName,
    relationship: relationship ?? this.relationship,
    phoneNumber: phoneNumber ?? this.phoneNumber,
  );

  @override
  List<Object?> get props => <Object?>[fullName, relationship, phoneNumber];
}

/// Everything the Profile tab renders.
class PatientProfile extends Equatable {
  const PatientProfile({
    required this.patientId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodType,
    required this.allergies,
    required this.conditions,
    required this.emergencyContact,
    this.notificationsEnabled = true,
    this.emergencyAlertsEnabled = true,
  });

  final String patientId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final Gender gender;
  final String bloodType;
  final List<String> allergies;
  final List<String> conditions;
  final EmergencyContact emergencyContact;
  final bool notificationsEnabled;
  final bool emergencyAlertsEnabled;

  /// "NS" — shown in the avatar circle on the profile header.
  String get initials {
    final List<String> parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String get allergiesLabel =>
      allergies.isEmpty ? 'None' : allergies.join(', ');

  String get conditionsLabel =>
      conditions.isEmpty ? 'None' : conditions.join(', ');

  PatientProfile copyWith({
    bool? notificationsEnabled,
    bool? emergencyAlertsEnabled,
  }) => PatientProfile(
    patientId: patientId,
    fullName: fullName,
    email: email,
    phoneNumber: phoneNumber,
    dateOfBirth: dateOfBirth,
    gender: gender,
    bloodType: bloodType,
    allergies: allergies,
    conditions: conditions,
    emergencyContact: emergencyContact,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    emergencyAlertsEnabled:
        emergencyAlertsEnabled ?? this.emergencyAlertsEnabled,
  );

  @override
  List<Object?> get props => <Object?>[
    patientId,
    fullName,
    email,
    phoneNumber,
    dateOfBirth,
    gender,
    bloodType,
    allergies,
    conditions,
    emergencyContact,
    notificationsEnabled,
    emergencyAlertsEnabled,
  ];
}
