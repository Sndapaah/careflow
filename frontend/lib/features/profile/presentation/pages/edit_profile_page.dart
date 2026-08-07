import 'package:careflow_app/app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../onboarding/domain/entities/medical_profile_draft.dart';
import '../../../onboarding/presentation/widgets/gender_choice.dart';
import '../../../onboarding/presentation/widgets/option_chip.dart';
import '../bloc/profile_bloc.dart';
import '../../../profile/domain/entities/patient_profile.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.profile});

  final PatientProfile profile;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late Gender _gender;
  late DateTime _dateOfBirth;
  late String _bloodType;
  late Set<String> _allergies;
  late Set<String> _conditions;
  late TextEditingController _contactName;
  String _relationship = '';
  late TextEditingController _contactPhone;

  @override
  void initState() {
    super.initState();
    final PatientProfile p = widget.profile;
    _gender = p.gender;
    _dateOfBirth = p.dateOfBirth;
    _bloodType = p.bloodType;
    _allergies = p.allergies.toSet();
    _conditions = p.conditions.toSet();
    _contactName = TextEditingController(text: p.emergencyContact.fullName);
    _relationship = p.emergencyContact.relationship;
    _contactPhone = TextEditingController(text: p.emergencyContact.phoneNumber);
  }

  @override
  void dispose() {
    _contactName.dispose();
    _contactPhone.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _pickRelationship() async {
    final String? choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: AppSpacing.sm),
            for (final String option in MedicalProfileDraft.relationshipOptions)
              ListTile(
                title: Text(option, style: AppTextStyles.bodyLarge),
                onTap: () => Navigator.of(sheetContext).pop(option),
              ),
          ],
        ),
      ),
    );
    if (choice != null) setState(() => _relationship = choice);
  }

  void _toggle(Set<String> set, String value) {
    setState(() {
      if (set.contains(value)) {
        set.remove(value);
      } else {
        set.add(value);
      }
    });
  }

  void _save(BuildContext context) {
    final PatientProfile updated = widget.profile.copyWithEdits(
      gender: _gender,
      dateOfBirth: _dateOfBirth,
      bloodType: _bloodType,
      allergies: _allergies.toList(),
      conditions: _conditions.toList(),
      emergencyContact: EmergencyContact(
        fullName: _contactName.text.trim(),
        relationship: _relationship,
        phoneNumber: _contactPhone.text.trim(),
      ),
    );
    context.read<ProfileBloc>().add(ProfileUpdateRequested(updated));
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (ProfileState p, ProfileState c) => p.status != c.status,
        listener: (BuildContext context, ProfileState state) {
          if (state.status.isSuccess) {
           // context.pop();
          context.go(AppRoutes.profile);
          } else if (state.status.isFailure && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (BuildContext innerContext, ProfileState state) {
          return Column(
            children: <Widget>[
              const AppTopBar(title: 'Edit Profile'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    AppSpacing.md,
                    AppSpacing.gutter,
                    AppSpacing.xl,
                  ),
                  children: <Widget>[
                          Text('Gender', 
                          style: AppTextStyles.h3.copyWith(fontSize: 17)),
                          const SizedBox(height: AppSpacing.sm),
                          GenderChoice(
                            selected: _gender,
                            onSelect: (Gender g) => setState(() => _gender = g),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text('Date of birth', style: AppTextStyles.h3.copyWith(fontSize: 17)),
                          const SizedBox(height: AppSpacing.sm),
                          AppPickerField(
                            label: 'Select Date',
                            value: DateFormat('yyyy-MM-dd').format(_dateOfBirth),
                            trailing: Icons.calendar_month_outlined,
                            onTap: _pickDate,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text('Blood type', style: AppTextStyles.h3.copyWith(fontSize: 17)),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.sm,
                            children: <Widget>[
                              for (final String option in MedicalProfileDraft.bloodTypeOptions)
                                OptionChip(
                                  label: option,
                                  selected: _bloodType == option,
                                  onTap: () => setState(() => _bloodType = option),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text('Allergies', style: AppTextStyles.h3.copyWith(fontSize: 17)),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.sm,
                            children: <Widget>[
                              for (final String option in MedicalProfileDraft.allergyOptions)
                                OptionChip(
                                  label: option,
                                  selected: _allergies.contains(option),
                                  onTap: () => _toggle(_allergies, option),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text('Conditions', style: AppTextStyles.h3.copyWith(fontSize: 17)),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.sm,
                            children: <Widget>[
                              for (final String option in MedicalProfileDraft.conditionOptions)
                                OptionChip(
                                  label: option,
                                  selected: _conditions.contains(option),
                                  onTap: () => _toggle(_conditions, option),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text('Emergency Contact', style: AppTextStyles.h3.copyWith(fontSize: 17)),
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(hint: 'Full Name', controller: _contactName),
                          const SizedBox(height: AppSpacing.md),
                          AppPickerField(
                            label: 'Select Relationship Type',
                            value: _relationship.isEmpty ? null : _relationship,
                            onTap: _pickRelationship,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            hint: 'Phone Number',
                            controller: _contactPhone,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          // PrimaryButton(
                          //   label: 'Save Changes',
                          //   borderRadius: AppRadius.pill,
                          //   onPressed: () => _save(context),
                          // ),                    
                          // const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: 'Save Changes',
                      borderRadius: AppRadius.pill,
                      isLoading: state.status.isLoading,
                      onPressed: state.status.isLoading
                          ? null
                          : () => _save(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}}