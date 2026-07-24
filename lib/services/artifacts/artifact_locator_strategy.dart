/// Abstract interface for an artifact locator strategy.
abstract class ArtifactLocatorStrategy {
  /// The type of artifact this strategy locates (e.g., 'apk', 'mapping.txt').
  String get artifactType;

  /// Attempts to locate the artifact and returns its absolute path.
  /// Returns null if the artifact cannot be found.
  Future<String?> locate({String? flavor, String? basePath});
}
