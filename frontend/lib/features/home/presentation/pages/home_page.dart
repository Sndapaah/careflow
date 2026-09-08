import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/cache/last_diagnosis_cache.dart';
import '../../../../core/navigation/tab_activation_bus.dart';
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
import '../../../../core/utils/phone_launcher.dart';
import 'package:flutter/services.dart';

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
  final ScrollController _scrollController = ScrollController();

  /// Drives the morphing top bar's fade. Kept as a [ValueNotifier] so scrolling
  /// only rebuilds the slim bar, not the whole feed.
  final ValueNotifier<double> _barProgress = ValueNotifier<double>(0);

  static const int _recentSymptomsPreviewCount = 3;

  /// Scroll offsets (px) between which the top bar fades from hidden to shown.
  /// [_morphStart] gives the hero greeting a little breathing room before the
  /// bar begins to appear; by [_morphEnd] the hero has scrolled away and the
  /// bar is fully solid.
  static const double _morphStart = 48;
  static const double _morphEnd = 128;

  bool _showAllRecentSymptoms = false;
  Timer? _tipRefreshTimer;
  StreamSubscription<int>? _tabActivationSubscription;
  StreamSubscription<void>? _diagnosisSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _scheduleTipRefresh();
    _tabActivationSubscription = TabActivationBus.stream.listen((int index) {
      if (index == 0 && mounted) {
        context.read<HomeBloc>().add(const HomeStarted());
      }
    });
    _diagnosisSubscription = sl<LastDiagnosisCache>().diagnosisCompleted.listen(
      (_) {
        if (mounted) context.read<HomeBloc>().add(const HomeStarted());
      },
    );
  }

  void _scheduleTipRefresh() {
    _tipRefreshTimer?.cancel();
    final DateTime now = DateTime.now();
    final DateTime nextRefresh = now.hour < 12
        ? DateTime(now.year, now.month, now.day, 12)
        : DateTime(now.year, now.month, now.day + 1);
    final Duration untilNextWindow = nextRefresh.difference(now);
    _tipRefreshTimer = Timer(untilNextWindow, () {
      if (!mounted) return;
      context.read<HomeBloc>().add(const HomeStarted());
      _scheduleTipRefresh();
    });
  }

  void _onScroll() {
    final double raw =
        (_scrollController.offset - _morphStart) / (_morphEnd - _morphStart);
    _barProgress.value = raw.clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _notesController.dispose();
    _symptomFocus.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _barProgress.dispose();
    _tipRefreshTimer?.cancel();
    _tabActivationSubscription?.cancel();
    _diagnosisSubscription?.cancel();
    super.dispose();
  }

  Future<void> _analyze(BuildContext context, String query) async {
    final List<String> symptoms = query
        .split(RegExp(r'[,\n]'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();

    if (symptoms.isEmpty) return;
    final SymptomCheckRequest? request =
        await showModalBottomSheet<SymptomCheckRequest>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) => _SymptomDetailsSheet(
            symptoms: symptoms,
            initialNotes: _notesController.text.trim(),
          ),
        );
    if (request != null && context.mounted) {
      await context.push(AppRoutes.analysis, extra: request);
    }
  }

  Future<void> _handleEmergencyFlow(BuildContext context) async {
    // Give immediate tactile confirmation before showing the safety dialog.
    await HapticFeedback.heavyImpact();
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

    if (context.mounted) await context.push(AppRoutes.emergency);
  }

  Future<void> _callEmergencyContact(BuildContext context) async {
    try {
      final PatientProfile profile = await sl<GetPatientProfile>()(
        const NoParams(),
      );
      await PhoneLauncher.call(profile.emergencyContact.phoneNumber);
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

            final bool hasMoreSymptoms =
                state.recentSymptoms.length > _recentSymptomsPreviewCount;
            final List<RecentSymptom> visibleSymptoms =
                _showAllRecentSymptoms || !hasMoreSymptoms
                ? state.recentSymptoms
                : state.recentSymptoms
                      .take(_recentSymptomsPreviewCount)
                      .toList();

            return Stack(
              children: <Widget>[
                RefreshIndicator(
                  onRefresh: () async => bloc.add(const HomeStarted()),
                  child: ListView(
                    controller: _scrollController,
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
                      if (state.nearby.isNotEmpty)
                        NearbyFacilitiesStrip(
                          facilities: state.nearby,
                          onSelect: (Facility facility) => context.push(
                            AppRoutes.facilityDetail(facility.id),
                          ),
                        )
                      else if (state.isLoadingNearby)
                        const SizedBox(
                          height: 178,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        const _NearbyEmpty(),
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
                        child: AdditionalNotesField(
                          controller: _notesController,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (state.tip != null)
                        Padding(
                          padding: AppSpacing.page,
                          child: HealthTipCard(tip: state.tip!),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      const _SectionTitle('Recent Symptoms'),
                      const SizedBox(height: AppSpacing.sm),
                      for (final RecentSymptom symptom in visibleSymptoms)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.gutter,
                            0,
                            AppSpacing.gutter,
                            AppSpacing.xs,
                          ),
                          child: RecentSymptomTile(symptom: symptom),
                        ),
                      if (hasMoreSymptoms)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.gutter,
                            AppSpacing.xs,
                            AppSpacing.gutter,
                            0,
                          ),
                          child: Center(
                            child: TextButton(
                              onPressed: () => setState(
                                () => _showAllRecentSymptoms =
                                    !_showAllRecentSymptoms,
                              ),
                              child: Text(
                                _showAllRecentSymptoms
                                    ? 'Show less'
                                    : 'See more',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ValueListenableBuilder<double>(
                    valueListenable: _barProgress,
                    builder: (BuildContext context, double progress, _) =>
                        MorphingTopBar(
                          progress: progress,
                          name: state.patientName,
                          onEmergency: () => _handleEmergencyFlow(context),
                        ),
                  ),
                ),
              ],
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

class _SymptomDetailsSheet extends StatefulWidget {
  const _SymptomDetailsSheet({
    required this.symptoms,
    required this.initialNotes,
  });

  final List<String> symptoms;
  final String initialNotes;

  @override
  State<_SymptomDetailsSheet> createState() => _SymptomDetailsSheetState();
}

class _SymptomDetailsSheetState extends State<_SymptomDetailsSheet> {
  String _severity = 'moderate';
  String _duration = '1-3 days';
  String _onset = 'gradual';
  late final TextEditingController _notesController = TextEditingController(
    text: widget.initialNotes,
  );
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.md,
          AppSpacing.gutter,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Symptom details', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.symptoms.join(', '),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _severity,
                decoration: const InputDecoration(labelText: 'Severity'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'mild', child: Text('Mild')),
                  DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                  DropdownMenuItem(value: 'severe', child: Text('Severe')),
                ],
                onChanged: (String? value) =>
                    setState(() => _severity = value ?? _severity),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _duration,
                decoration: const InputDecoration(labelText: 'Duration'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(
                    value: 'Less than 24 hours',
                    child: Text('Less than 24 hours'),
                  ),
                  DropdownMenuItem(value: '1-3 days', child: Text('1-3 days')),
                  DropdownMenuItem(value: '4-7 days', child: Text('4-7 days')),
                  DropdownMenuItem(
                    value: 'More than 1 week',
                    child: Text('More than 1 week'),
                  ),
                ],
                onChanged: (String? value) =>
                    setState(() => _duration = value ?? _duration),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _onset,
                decoration: const InputDecoration(labelText: 'Onset'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'sudden', child: Text('Sudden')),
                  DropdownMenuItem(value: 'gradual', child: Text('Gradual')),
                ],
                onChanged: (String? value) =>
                    setState(() => _onset = value ?? _onset),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (if relevant)',
                  hintText: 'For example, lower right abdomen',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _medicationsController,
                decoration: const InputDecoration(
                  labelText: 'Current medications',
                  hintText: 'Separate multiple medications with commas',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Additional information',
                  hintText: 'Onset, location, triggers, or related symptoms',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Analyze symptoms',
                onPressed: () {
                  final List<String> medications = _medicationsController.text
                      .split(',')
                      .map((String value) => value.trim())
                      .where((String value) => value.isNotEmpty)
                      .toList();
                  final String location = _locationController.text.trim();
                  final String notes = _notesController.text.trim();
                  final String contextDetails = <String>[
                    'Onset: $_onset',
                    if (location.isNotEmpty) 'Location: $location',
                    if (notes.isNotEmpty) notes,
                  ].join('. ');
                  Navigator.of(context).pop(
                    SymptomCheckRequest(
                      symptoms: widget.symptoms
                          .map(
                            (String name) => SymptomDetail(
                              name: name,
                              severity: _severity,
                              duration: _duration,
                              onset: _onset,
                              location: location,
                            ),
                          )
                          .toList(),
                      medications: medications,
                      additionalInformation: contextDetails,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when the nearby-facilities read finished but returned nothing (empty
/// collection, or the request failed). Keeps the layout stable and nudges the
/// user to retry instead of leaving a blank gap.
class _NearbyEmpty extends StatelessWidget {
  const _NearbyEmpty();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 178,
      child: Center(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.location_off_outlined,
                color: AppColors.textMuted,
                size: 32,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'No facilities found nearby right now.\nPull down to refresh.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
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
              // fontStyle: FontStyle.italic,
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
