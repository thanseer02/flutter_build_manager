import 'package:args/command_runner.dart';

import '../utils/logger.dart';
import '../services/process_service.dart';

/// The `build` command for flutter_release_manager.
///
/// This command handles triggering Flutter builds for various platforms.
class BuildCommand extends Command<int> {
  final ReleaseManagerLogger _logger;
  final ProcessService _processService;

  /// Creates a [BuildCommand].
  BuildCommand({
    required ReleaseManagerLogger logger,
    required ProcessService processService,
  })  : _logger = logger,
        _processService = processService {
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

    try {
      await _processService.run('flutter', ['build', target]);
      _logger.success('Build completed successfully for $target.');
      return 0;
    } catch (e) {
      _logger.err('Build failed: $e');
      return 1;
    }
  }
}
