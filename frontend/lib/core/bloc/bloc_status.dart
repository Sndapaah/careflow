/// Uniform lifecycle marker shared by every bloc state in the app, so screens
/// can switch on one vocabulary instead of a bespoke enum per feature.
enum BlocStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == BlocStatus.initial;

  bool get isLoading => this == BlocStatus.loading;

  bool get isSuccess => this == BlocStatus.success;

  bool get isFailure => this == BlocStatus.failure;
}
