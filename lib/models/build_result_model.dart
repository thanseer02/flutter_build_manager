/// Represents the result of a Flutter build execution.
class BuildResultModel {
  /// Whether the build was successful.
  final bool isSuccess;

  /// The target that was built (apk, aab, ipa).
  final String target;

  /// The original path where Flutter placed the generated artifact.
  /// This will be null if the build failed.
  final String? originalArtifactPath;

  /// Any error message generated during the build.
  final String? errorMessage;

  /// The time taken to execute the build.
  final Duration buildDuration;

  const BuildResultModel({
    required this.isSuccess,
    required this.target,
    required this.buildDuration,
    this.originalArtifactPath,
    this.errorMessage,
  });
}
