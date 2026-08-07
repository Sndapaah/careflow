// lib/core/utils/field_validators.dart

class FieldValidators {
  static final RegExp _email = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
  static final RegExp _phone = RegExp(r'^\+?[0-9]{9,15}$');
  static final RegExp _nameLike = RegExp(r'^[A-Za-z\s\.\-]{2,}$');

  static String? email(String value) {
    if (value.isEmpty) return null;
    return _email.hasMatch(value) ? null : 'Enter a valid email address';
  }

  static String? phone(String value) {
    if (value.isEmpty) return null;
    return _phone.hasMatch(value) ? null : 'Enter a valid phone number';
  }

  static String? fullName(String value) {
    if (value.isEmpty) return null;
    if (RegExp(r'[0-9]').hasMatch(value)) return 'Name cannot contain numbers';
    return _nameLike.hasMatch(value) ? null : 'Enter your full name';
  }

  static String? password(String value) {
    if (value.isEmpty) return null;
    return value.length >= 6 ? null : 'Password must be at least 6 characters';
  }
}