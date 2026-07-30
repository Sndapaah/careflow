import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../bloc/emergency_bloc.dart';
import '../widgets/recommendation_card.dart';

/// Single best emergency-capable facility, with a one-tap call action.
class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmergencyBloc>(
      create: (_) => sl<EmergencyBloc>()..add(const EmergencyMatchRequested()),
      child: const _EmergencyView(),
    );
  }
}

class _EmergencyView extends StatelessWidget {
  const _EmergencyView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const AppTopBar(
              title: 'Emergency',
              titleColor: AppColors.danger,
              subtitle: 'Best match available',
            ),
            Expanded(
              child: BlocBuilder<EmergencyBloc, EmergencyState>(
                builder: (BuildContext context, EmergencyState state) {
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
                  if (!state.status.isSuccess || state.match == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.md,
                      AppSpacing.gutter,
                      AppSpacing.xl,
                    ),
                    child: RecommendationCard(
                      recommendation: state.match!,
                      tone: RecommendationTone.emergency,
                      onNavigate: () => context.go(
                        AppRoutes.mapFocused(state.match!.facility.id),
                      ),
                      onCall: () => _showCallSheet(
                        context,
                        state.match!.facility.name,
                        state.match!.facility.phoneNumber,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Placing the call needs a platform integration (url_launcher); until that
  /// is wired the UI confirms the number it would dial.
  void _showCallSheet(BuildContext context, String name, String number) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Calling $name — $number')));
  }
}
