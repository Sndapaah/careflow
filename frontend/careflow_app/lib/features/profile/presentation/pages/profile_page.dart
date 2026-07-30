import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../domain/entities/patient_profile.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => sl<ProfileBloc>()..add(const ProfileRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (ProfileState p, ProfileState c) =>
              p.isSignedOut != c.isSignedOut,
          listener: (BuildContext context, ProfileState state) {
            if (state.isSignedOut) context.go(AppRoutes.welcome);
          },
          builder: (BuildContext context, ProfileState state) {
            final PatientProfile? profile = state.profile;

            return Column(
              children: <Widget>[
                AppSectionHeader(
                  title: 'Profile',
                  subtitle: 'Your account & medical info',
                  trailing: _SignOutIconButton(
                    onTap: () => context.read<ProfileBloc>().add(
                      const ProfileSignOutRequested(),
                    ),
                  ),
                ),
                Expanded(
                  child: profile == null
                      ? const Center(child: CircularProgressIndicator())
                      : _ProfileBody(profile: profile),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});

  final PatientProfile profile;

  @override
  Widget build(BuildContext context) {
    final ProfileBloc bloc = context.read<ProfileBloc>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.md,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: <Widget>[
        _IdentityCard(profile: profile),
        const SizedBox(height: AppSpacing.lg),
        const _SectionLabel(
          label: 'Medical Information',
          icon: Icons.medical_services_outlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          shadows: null,
          border: Border.all(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: <Widget>[
              DetailRow(
                label: 'Date of birth',
                value: DateFormat('yyyy-MM-dd').format(profile.dateOfBirth),
              ),
              const Divider(height: 1),
              DetailRow(label: 'Gender', value: profile.gender.label),
              const Divider(height: 1),
              DetailRow(label: 'Blood type', value: profile.bloodType),
              const Divider(height: 1),
              DetailRow(label: 'Allergies', value: profile.allergiesLabel),
              const Divider(height: 1),
              DetailRow(label: 'Conditions', value: profile.conditionsLabel),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _SectionLabel(
          label: 'Emergency Contact',
          icon: Icons.contact_emergency_outlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          shadows: null,
          border: Border.all(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: <Widget>[
              DetailRow(
                label: 'Name',
                value: profile.emergencyContact.fullName,
              ),
              const Divider(height: 1),
              DetailRow(
                label: 'Phone',
                value: profile.emergencyContact.phoneNumber,
                leadingIcon: Icons.call_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _SectionLabel(label: 'Settings'),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          shadows: null,
          border: Border.all(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: <Widget>[
              _SettingsToggle(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Wait time updates & reminders',
                value: profile.notificationsEnabled,
                onChanged: (bool value) =>
                    bloc.add(ProfileNotificationsToggled(value)),
              ),
              const Divider(height: 1),
              _SettingsToggle(
                icon: Icons.emergency_share_rounded,
                title: 'Emergency Alerts',
                subtitle: 'Critical health warnings',
                value: profile.emergencyAlertsEnabled,
                onChanged: (bool value) =>
                    bloc.add(ProfileEmergencyAlertsToggled(value)),
              ),
              const Divider(height: 1),
              _SettingsLink(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () => ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Profile editing is coming next.'),
                    ),
                  ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SignOutButton(onTap: () => bloc.add(const ProfileSignOutRequested())),
      ],
    );
  }
}

/// The blue gradient card carrying the patient's identity.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile});

  final PatientProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[AppColors.primaryDark, Color(0xFF25C9F0)],
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  profile.initials,
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      profile.fullName,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      'Patient ID  •  ${profile.patientId}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Flexible(
                child: _ContactPill(
                  icon: Icons.mail_outline,
                  label: profile.email,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: _ContactPill(
                  icon: Icons.call_outlined,
                  label: profile.phoneNumber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactPill extends StatelessWidget {
  const _ContactPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17, color: Colors.white),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 24, color: AppColors.accent),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(
          label.toUpperCase(),
          style: AppTextStyles.h3.copyWith(fontSize: 16, letterSpacing: 0.4),
        ),
      ],
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          _SettingsIcon(icon: icon),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 17),
                ),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingsLink extends StatelessWidget {
  const _SettingsLink({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: <Widget>[
            _SettingsIcon(icon: icon),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(fontSize: 17),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.accent, size: 26),
          ],
        ),
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.accentSurface,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 21, color: AppColors.accent),
    );
  }
}

class _SignOutIconButton extends StatelessWidget {
  const _SignOutIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        child: const SizedBox(
          width: 46,
          height: 42,
          child: Icon(Icons.logout, color: AppColors.danger, size: 24),
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.logout, color: AppColors.danger, size: 22),
        label: Text(
          'Sign out',
          style: AppTextStyles.button.copyWith(color: AppColors.danger),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.danger),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
    );
  }
}
