import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../facilities/domain/entities/facility.dart';
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
  final FocusNode _symptomFocus = FocusNode();

  @override
  void dispose() {
    _symptomController.dispose();
    _symptomFocus.dispose();
    super.dispose();
  }

  void _analyze(BuildContext context, String query) {
    final List<String> symptoms = query
        .split(RegExp(r'[,\n]'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
    if (symptoms.isEmpty) return;
    context.push(AppRoutes.analysis, extra: symptoms);
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
                      unreadCount: state.unreadNotifications,
                      onNotifications: () => context.push(AppRoutes.emergency),
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
                      child: RecentSymptomTile(
                        symptom: symptom,
                        onTap: () => _analyze(context, symptom.label),
                      ),
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
