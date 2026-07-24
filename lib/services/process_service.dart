import 'package:meta/meta.dart';
import 'dart:io';

import '../exceptions/release_manager_exception.dart';
import '../utils/logger.dart';

/// Defines the contract for OS process execution and provides
/// a concrete implementation using `dart:io`.
class ProcessService {
  /// The logger used to output debug information.
  final ReleaseManagerLogger _logger;

  /// Injected process runner function for testability.
  final Future<ProcessResult> Function(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool runInShell,
  }) _runProcess;

  /// Creates a [ProcessService].
  ///
  /// The [processRunner] is mainly used for dependency injection during tests.
  ProcessService({
    required ReleaseManagerLogger logger,
    @visibleForTesting
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
      bool runInShell,
    })? processRunner,
  })  : _logger = logger,
        _runProcess = processRunner ?? Process.run;

  /// Runs an executable with the given [executable] name and [arguments].
  ///
  /// Optionally sets the [workingDirectory].
  /// Returns the standard output of the process if successful.
  /// Throws an exception if the process fails.
  Future<String> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    _logger.detail('Running: $executable ${arguments.join(' ')}');
    
    try {
      final result = await _runProcess(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        runInShell: true,
      );

      if (result.exitCode != 0) {
        throw ReleaseManagerException(
          'Command failed: $executable ${arguments.join(' ')}',
          details: result.stderr.toString().trim(),
        );
      }

      return result.stdout.toString().trim();
    } on ProcessException catch (e) {
      throw ReleaseManagerException(
        'Process failed to start: $executable',
        details: e.message,
      );
    }
  }
}
