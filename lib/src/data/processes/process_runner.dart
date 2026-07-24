import 'package:meta/meta.dart';
import 'dart:io';

import '../../core/exceptions/release_manager_exception.dart';
import '../../core/logging/logger.dart';
import '../../domain/repositories/process_repository.dart';

/// Concrete implementation of [ProcessRepository] using `dart:io`.
class ProcessRunner implements ProcessRepository {
  /// The logger used to output debug information.
  final ReleaseManagerLogger _logger;

  /// Injected process runner function for testability.
  final Future<ProcessResult> Function(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool runInShell,
  }) _runProcess;

  /// Creates a [ProcessRunner].
  ///
  /// The [processRunner] is mainly used for dependency injection during tests.
  ProcessRunner({
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

  @override
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
