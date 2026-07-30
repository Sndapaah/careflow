import 'package:equatable/equatable.dart';

/// The green "Today's Health Tip" card at the bottom of the home screen.
class HealthTip extends Equatable {
  const HealthTip({required this.title, required this.body});

  final String title;
  final String body;

  @override
  List<Object?> get props => <Object?>[title, body];
}
