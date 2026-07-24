/// Custom exceptions for flutter_release_manager.
library flutter_release_manager.core.errors;

/// Base exception for all CLI-related errors.
abstract class CliException implements Exception {
  /// The error message.
  final String message;
  
  /// Creates a new [CliException] with the given [message].
  const CliException(this.message);

  @override
  String toString() => message;
}

/// Thrown when a required configuration or dependency is missing.
class ConfigurationException extends CliException {
  /// Creates a new [ConfigurationException].
  const ConfigurationException(super.message);
}

/// Thrown when a build process fails.
class BuildException extends CliException {
  /// Creates a new [BuildException].
  const BuildException(super.message);
}
