import 'package:equatable/equatable.dart';

/// Contract every use case implements: one public `call`, one input, one
/// output. Blocs depend on these, never on repositories directly.
abstract interface class UseCase<R, P> {
  Future<R> call(P params);
}

/// Marker for use cases that take no arguments.
final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => <Object?>[];
}
