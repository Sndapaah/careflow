import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_buttons.dart';

class LocationPermissionPage extends StatefulWidget {
  const LocationPermissionPage({super.key});

  @override
  State<LocationPermissionPage> createState() =>
      _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  bool _isRequesting = false;
  String? _error;

/*
  Future<void> _requestPermission() async {
    setState(() {
      _isRequesting = true;
      _error = null;
    });

    // 1. Is location even turned on for the device?
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isRequesting = false;
        _error = 'Turn on location services to find nearby facilities.';
      });
      return;
    }

    // 2. Check, then ask, for app-level permission.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _isRequesting = false;
        _error = permission == LocationPermission.deniedForever
            ? 'Location is permanently denied. Enable it in Settings.'
            : 'CareFlow needs your location to show nearby facilities.';
      });
      return;
    }

    // 3. Granted — go straight to the map with a fresh fix.
    if (mounted) context.go(AppRoutes.map);
  }
  */

Future<void> _requestPermission() async {
  setState(() {
    _isRequesting = true;
    _error = null;
  });

  try {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled()
        .timeout(const Duration(seconds: 5));
    if (!serviceEnabled) {
      setState(() => _error = 'Turn on location services to find nearby facilities.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission()
        .timeout(const Duration(seconds: 5));
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission()
          .timeout(const Duration(seconds: 15)); // OS dialog needs user interaction
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _error = permission == LocationPermission.deniedForever
            ? 'Location is permanently denied. Enable it in Settings.'
            : 'CareFlow needs your location to show nearby facilities.';
      });
      return;
    }

    if (mounted) context.go(AppRoutes.map);
  } on TimeoutException {
    setState(() => _error = 'That took too long. Please try again.');
  } catch (e) {
    setState(() => _error = 'Something went wrong: $e');
  } finally {
    if (mounted) setState(() => _isRequesting = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
    canPop: false,
    onPopInvokedWithResult: (bool didPop, Object? _) {
      if (!didPop) context.go(AppRoutes.home);
    },
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.location_on, size: 96, color: AppColors.primary),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Find care near you',
                style: AppTextStyles.display.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'CareFlow uses your location to show the 3 closest health '
                'facilities and live directions to them.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text(_error!, style: TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'Allow location access',
                isLoading: _isRequesting,
                onPressed: _isRequesting ? null : _requestPermission,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}