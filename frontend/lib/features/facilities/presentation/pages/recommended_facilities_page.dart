import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/careflow_logo.dart';
import '../../domain/entities/facility_recommendation.dart';
import '../bloc/recommendations_bloc.dart';
import '../widgets/recommendation_card.dart';

/// The ranked list of facilities that match the current symptom context.
class RecommendedFacilitiesPage extends StatelessWidget {
  const RecommendedFacilitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecommendationsBloc>(
      create: (_) =>
          sl<RecommendationsBloc>()..add(const RecommendationsRequested()),
      child: const _RecommendedFacilitiesView(),
    );
  }
}

class _RecommendedFacilitiesView extends StatelessWidget {
  const _RecommendedFacilitiesView();

  Widget _buildBody(BuildContext context, RecommendationsState state) {
    if (state.status.isFailure) {
      return Center(
        child: Padding(
          padding: AppSpacing.page,
          child: Text(
            state.errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
        ),
      );
    }

    if (!state.status.isSuccess) {
      return const _FacilityLoadingView();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.md,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      itemCount: state.recommendations.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (BuildContext context, int index) {
        final FacilityRecommendation recommendation =
            state.recommendations[index];
        return RecommendationCard(
          recommendation: recommendation,
          onViewDetails: () => context.push(
            AppRoutes.facilityDetail(recommendation.facility.id),
          ),
          onNavigate: () =>
              context.go(AppRoutes.mapFocused(recommendation.facility.id)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<RecommendationsBloc, RecommendationsState>(
          builder: (BuildContext context, RecommendationsState state) {
            return Column(
              children: <Widget>[
                AppTopBar(
                  title: 'Recommended Facilities',
                  subtitle: state.status.isSuccess
                      ? state.matchCountLabel
                      : 'Finding the best care nearby',
                ),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FacilityLoadingView extends StatefulWidget {
  const _FacilityLoadingView();

  @override
  State<_FacilityLoadingView> createState() => _FacilityLoadingViewState();
}

class _FacilityLoadingViewState extends State<_FacilityLoadingView> {
  static const List<String> _messages = <String>[
    'Checking nearby facilities',
    'Comparing availability and distance',
    'Ranking the best matches for you',
  ];

  Timer? _timer;
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CareFlowHoverLogo(size: 104),
          const SizedBox(height: AppSpacing.lg),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _messages[_messageIndex],
              key: ValueKey<int>(_messageIndex),
              textAlign: TextAlign.center,
              style: AppTextStyles.h3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const SizedBox(
            width: 132,
            child: LinearProgressIndicator(minHeight: 3),
          ),
        ],
      ),
    );
  }
}
