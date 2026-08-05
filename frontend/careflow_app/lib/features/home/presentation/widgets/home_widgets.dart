import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/careflow_logo.dart';
import '../../../../core/widgets/hospital_glyph.dart';
import '../../../facilities/domain/entities/facility.dart';
import '../../../symptoms/domain/entities/symptom_analysis.dart';
import '../../domain/entities/health_tip.dart';

/// Avatar, greeting and the emergency trigger.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.greeting,
    required this.name,
    required this.onEmergency,
  });

  final String greeting;
  final String name;
  final VoidCallback onEmergency;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: AppColors.primary, size: 30),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                greeting,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h2.copyWith(fontSize: 23),
              ),
              Text(
                'How are you feeling today?',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        _EmergencyIconButton(onTap: onEmergency),
      ],
    );
  }
}

class _EmergencyIconButton extends StatelessWidget {
  const _EmergencyIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.danger,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.emergency_outlined, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

/// Horizontally scrolling row of nearby facility cards.
class NearbyFacilitiesStrip extends StatelessWidget {
  const NearbyFacilitiesStrip({
    super.key,
    required this.facilities,
    required this.onSelect,
  });

  final List<Facility> facilities;
  final ValueChanged<Facility> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 178,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        itemCount: facilities.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final Facility facility = facilities[index];
          return _FacilityTile(
            facility: facility,
            onTap: () => onSelect(facility),
          );
        },
      ),
    );
  }
}

class _FacilityTile extends StatelessWidget {
  const _FacilityTile({required this.facility, required this.onTap});

  final Facility facility;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          width: 148,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const HospitalGlyph(size: 84),
              const SizedBox(height: AppSpacing.xs),
              Text(
                facility.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The pale blue "CareFlow AI" promo card.
class AiBanner extends StatelessWidget {
  const AiBanner({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySurface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'CareFlow AI',
                      style: AppTextStyles.display.copyWith(
                        fontSize: 27,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "Tell me what's wrong and I'll find the best care nearby.",
                      style: AppTextStyles.body.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const CareFlowLogo(size: 120),
            ],
          ),
        ),
      ),
    );
  }
}

/// Search field with the blue "analyse" action button on the right.
class SymptomSearchField extends StatelessWidget {
  const SymptomSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmit,
    required this.isEnabled,
    this.focusNode,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final bool isEnabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search, color: AppColors.textMuted, size: 26),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: (_) {
                if (isEnabled) onSubmit();
              },
              textInputAction: TextInputAction.search,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Describe your symptoms...',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Material(
            color: isEnabled ? AppColors.primarySoft : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: InkWell(
              onTap: isEnabled ? onSubmit : null,
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: SizedBox(
                width: 52,
                height: 48,
                child: Icon(
                  Icons.auto_awesome,
                  size: 24,
                  color: isEnabled ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One-tap symptom suggestions under the search field.
class QuickSymptomChips extends StatelessWidget {
  const QuickSymptomChips({
    super.key,
    required this.symptoms,
    required this.onSelect,
  });

  final List<String> symptoms;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        itemCount: symptoms.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (BuildContext context, int index) {
          final String symptom = symptoms[index];
          return Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: InkWell(
              onTap: () => onSelect(symptom),
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  symptom,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Free-text space for anything the patient wants to add that doesn't fit
/// the structured symptom search — context, timeline, how they're feeling.
/// Folded into the symptoms list on analyze; not yet persisted separately.
class AdditionalNotesField extends StatelessWidget {
  const AdditionalNotesField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Additional Notes',
          style: AppTextStyles.h2.copyWith(fontSize: 18),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            minLines: 3,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.sm),
              hintText:
                  'Anything else you want to mention — when it started, '
                  'how it feels, what makes it better or worse...',
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A previously logged symptom with its relative timestamp.
class RecentSymptomTile extends StatelessWidget {
  const RecentSymptomTile({super.key, required this.symptom, this.onTap});

  final RecentSymptom symptom;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.primarySoft),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.access_time,
                size: 22,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  symptom.label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                symptom.whenLabel,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Green card at the foot of the home screen.
class HealthTipCard extends StatelessWidget {
  const HealthTipCard({super.key, required this.tip});

  final HealthTip tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successSurfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.eco, color: AppColors.success, size: 22),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      tip.title,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.success,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  tip.body,
                  style: AppTextStyles.body.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const _WaterGlass(size: 76),
        ],
      ),
    );
  }
}

class _WaterGlass extends StatelessWidget {
  const _WaterGlass({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: const _WaterGlassPainter()),
  );
}

class _WaterGlassPainter extends CustomPainter {
  const _WaterGlassPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide;

    final Path glass = Path()
      ..moveTo(0.24 * s, 0.16 * s)
      ..lineTo(0.76 * s, 0.16 * s)
      ..lineTo(0.68 * s, 0.90 * s)
      ..lineTo(0.32 * s, 0.90 * s)
      ..close();

    final Path water = Path()
      ..moveTo(0.265 * s, 0.30 * s)
      ..lineTo(0.735 * s, 0.30 * s)
      ..lineTo(0.68 * s, 0.88 * s)
      ..lineTo(0.32 * s, 0.88 * s)
      ..close();

    canvas.drawPath(glass, Paint()..color = const Color(0xFFE8F4FB));
    canvas.drawPath(water, Paint()..color = const Color(0xFF7EC8F0));
    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.03 * s
        ..color = const Color(0xFF9CC7DE),
    );

    final Paint leaf = Paint()..color = const Color(0xFF5FBF6B);
    for (final double dx in <double>[0.10, 0.86]) {
      canvas.save();
      canvas.translate(dx * s, 0.86 * s);
      canvas.rotate(dx < 0.5 ? -0.5 : 0.5);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 0.22 * s, height: 0.10 * s),
        leaf,
      );
      canvas.restore();
    }

    canvas.drawLine(
      Offset(0.04 * s, 0.94 * s),
      Offset(0.96 * s, 0.94 * s),
      Paint()
        ..strokeWidth = 0.028 * s
        ..color = const Color(0xFF5FBF6B),
    );
  }

  @override
  bool shouldRepaint(_WaterGlassPainter oldDelegate) => false;
}