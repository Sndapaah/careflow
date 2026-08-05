import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../facilities/domain/entities/facility.dart';
import '../../../profile/domain/entities/patient_profile.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';
import '../../../symptoms/domain/entities/symptom_analysis.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => sl<HomeBloc>()..add(const HomeStarted()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _symptomFocus = FocusNode();

  @override
  void dispose() {
    _symptomController.dispose();
    _notesController.dispose();
    _symptomFocus.dispose();
    super.dispose();
  }

  /// Bundles the typed symptoms with any free-text notes before handing off
  /// to the AI analysis screen — notes ride along as one extra "symptom"
  /// entry so the analyzer sees the full picture the patient described.
  void _analyze(BuildContext context, String query) {
    final List<String> symptoms = query
        .split(RegExp(r'[,\n]'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();

    final String notes = _notesController.text.trim();
    if (notes.isNotEmpty) {
      symptoms.add('Additional notes: $notes');
    }

    if (symptoms.isEmpty) return;
    context.push(AppRoutes.analysis, extra: symptoms);
  }

  Future<void> _handleEmergencyFlow(BuildContext context) async {
    final bool? proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _EmergencyDetectedDialog(),
    );
    if (proceed != true || !context.mounted) return;

    final _EmergencyCallChoice? choice = await showDialog<_EmergencyCallChoice>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _EmergencyCallChoiceDialog(),
    );
    if (!context.mounted) return;

    if (choice == _EmergencyCallChoice.contact) {
      await _callEmergencyContact(context);
    }
    // "Call Facility" is handled on the Emergency page itself, once the
    // matched facility (and its number) has actually loaded.

    if (context.mounted) context.push(AppRoutes.emergency);
  }

  Future<void> _callEmergencyContact(BuildContext context) async {
    try {
      final PatientProfile profile =
          await sl<GetPatientProfile>()(const NoParams());
      final EmergencyContact contact = profile.emergencyContact;
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Calling ${contact.fullName} — ${contact.phoneNumber}',
              ),
            ),
          );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('No emergency contact on file.')),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (BuildContext context, HomeState state) {
            final HomeBloc bloc = context.read<HomeBloc>();

            if (state.status.isLoading && state.nearby.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async => bloc.add(const HomeStarted()),
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.sm,
                      AppSpacing.gutter,
                      AppSpacing.md,
                    ),
                    child: GreetingHeader(
                      greeting: state.greeting,
                      name: state.patientName,
                      onEmergency: () => _handleEmergencyFlow(context),
                    ),
                  ),
                  const _SectionTitle('Nearby Health Facilities'),
                  const SizedBox(height: AppSpacing.sm),
                  NearbyFacilitiesStrip(
                    facilities: state.nearby,
                    onSelect: (Facility facility) =>
                        context.push(AppRoutes.facilityDetail(facility.id)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: AppSpacing.page,
                    child: AiBanner(onTap: _symptomFocus.requestFocus),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: AppSpacing.page,
                    child: SymptomSearchField(
                      controller: _symptomController,
                      focusNode: _symptomFocus,
                      isEnabled: state.canAnalyze,
                      onChanged: (String value) =>
                          bloc.add(HomeSymptomQueryChanged(value)),
                      onSubmit: () => _analyze(context, state.symptomQuery),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  QuickSymptomChips(
                    symptoms: state.quickSymptoms,
                    onSelect: (String symptom) {
                      _symptomController.text = symptom;
                      bloc.add(HomeQuickSymptomSelected(symptom));
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: AppSpacing.page,
                    child: AdditionalNotesField(controller: _notesController),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _SectionTitle('Recent Symptoms'),
                  const SizedBox(height: AppSpacing.sm),
                  for (final RecentSymptom symptom in state.recentSymptoms)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.gutter,
                        0,
                        AppSpacing.gutter,
                        AppSpacing.xs,
                      ),
                      child: RecentSymptomTile(symptom: symptom),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  if (state.tip != null)
                    Padding(
                      padding: AppSpacing.page,
                      child: HealthTipCard(tip: state.tip!),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.page,
      child: Text(title, style: AppTextStyles.h2.copyWith(fontSize: 21)),
    );
  }
}

enum _EmergencyCallChoice { contact, facility }

class _EmergencyDetectedDialog extends StatelessWidget {
  const _EmergencyDetectedDialog();

  @override
  Widget build(BuildContext context) {
    return _EmergencyDialogShell(
      actions: Row(
        children: <Widget>[
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: PrimaryButton(
              label: 'Continue',
              height: 46,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyCallChoiceDialog extends StatelessWidget {
  const _EmergencyCallChoiceDialog();

  @override
  Widget build(BuildContext context) {
    return _EmergencyDialogShell(
      actions: Column(
        children: <Widget>[
          SecondaryButton(
            label: 'Call Contact',
            height: 48,
            onPressed: () =>
                Navigator.of(context).pop(_EmergencyCallChoice.contact),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: 'Call Facility',
            height: 48,
            onPressed: () =>
                Navigator.of(context).pop(_EmergencyCallChoice.facility),
          ),
        ],
      ),
    );
  }
}

/// Shared header/icon/subtitle used by both emergency dialogs so they read
/// as one continuous flow rather than two unrelated pop-ups.
class _EmergencyDialogShell extends StatelessWidget {
  const _EmergencyDialogShell({required this.actions});

  final Widget actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppColors.danger,
              size: 34,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Emergency Button Triggered',
            textAlign: TextAlign.center,
            style: AppTextStyles.h2.copyWith(fontSize: 20),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Please stay calm, CareFlow will take care of you',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          actions,
        ],
      ),
    );
  }
}