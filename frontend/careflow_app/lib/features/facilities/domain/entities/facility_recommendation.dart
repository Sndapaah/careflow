import 'package:equatable/equatable.dart';

import 'facility.dart';

/// Where a recommendation sits in the ranked list. Drives the cyan tag.
enum MatchRank {
  top('Top Match'),
  alternative('Alt Match'),
  last('Last Match');

  const MatchRank(this.label);

  final String label;
}

/// How sure the engine is about a recommendation.
enum ConfidenceLevel {
  high('High'),
  medium('Medium'),
  low('Low');

  const ConfidenceLevel(this.label);

  final String label;
}

/// A facility paired with the reasoning that put it on the list.
class FacilityRecommendation extends Equatable {
  const FacilityRecommendation({
    required this.facility,
    required this.rank,
    required this.confidence,
    required this.confidenceScore,
    required this.reasons,
  });

  final Facility facility;
  final MatchRank rank;
  final ConfidenceLevel confidence;

  /// 0..100, shown as the ring on the map sheet.
  final int confidenceScore;

  /// Plain-language bullets under "Recommended because".
  final List<String> reasons;

  @override
  List<Object?> get props => <Object?>[
    facility,
    rank,
    confidence,
    confidenceScore,
    reasons,
  ];
}
