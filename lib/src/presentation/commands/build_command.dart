import 'package:args/command_runner.dart';

import '../../core/logging/logger.dart';
import '../../domain/repositories/process_repository.dart';

/// The `build` command for flutter_release_manager.
///
/// This command handles triggering Flutter builds for various platforms.
class BuildCommand extends Command<int> {
  final ReleaseManagerLogger _logger;
  final ProcessRepository _processRepository;

  /// Creates a [BuildCommand].
  BuildCommand({
    required ReleaseManagerLogger logger,
    required ProcessRepository processRepository,
  })  : _logger = logger,
        _processRepository = processRepository {
    argParser.addOption(
      'target',
      abbr: 't',
      help: 'The target platform to build for (e.g., macos, windows, linux, apk, ipa).',
      allowed: ['macos', 'windows', 'linux', 'apk', 'ipa'],
      mandatory: true,
    );
  }

  @override
  String get name => 'build';

  @override
  String get description => 'Builds the Flutter application for a specific target.';

  @override
  Future<int> run() async {
    final target = argResults?['target'] as String?;
    if (target == null) {
      _logger.err('Target is required.');
      return 1;
    }

    _logger.info('Starting build for target: $target');

    final progress = _logger.info; // Ideally mason_logger Progress could be used here

    try {
      // In a real application, we would have a BuildUseCase in the domain layer.
      // For now, we interact directly with the process repository.
      await _processRepository.run('flutter', ['build', target]);
      _logger.success('Build completed successfully for $target.');
      return 0;
    } catch (e) {
      _logger.err('Build failed: $e');
      return 1;
    }
  }
}
