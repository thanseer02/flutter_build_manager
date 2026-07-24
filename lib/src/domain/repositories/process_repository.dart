/// Defines the contract for OS process execution.
///
/// This abstracts the raw `dart:io` Process to make the business logic
/// testable without executing real shell commands.
abstract class ProcessRepository {
  /// Runs an executable with the given [executable] name and [arguments].
  ///
  /// Optionally sets the [workingDirectory].
  /// Returns the standard output of the process if successful.
  /// Throws an exception if the process fails.
  Future<String> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  });
}
