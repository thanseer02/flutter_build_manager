/// The build command implementation.
library flutter_release_manager.commands.build;

import 'package:args/command_runner.dart';
import '../core/logger.dart';
import '../core/errors.dart';

/// A command to build a Flutter application for a specific platform.
class BuildCommand extends Command<int> {
  final AppLogger _logger;

  @override
  final String name = 'build';

  @override
  final String description = 'Builds the Flutter application for a specific target.';

  /// Creates a new [BuildCommand].
  BuildCommand({required AppLogger logger}) : _logger = logger {
    argParser.addOption(
      'target',
      abbr: 't',
      help: 'The target platform to build for.',
      allowed: ['apk', 'aab', 'ios', 'macos', 'windows', 'linux'],
      defaultsTo: 'apk',
    );
  }

  @override
  Future<int> run() async {
    final target = argResults?['target'] as String?;

    _logger.info('Starting build process for target: \$target');
    final progress = _logger.progress('Building \$target...');

    try {
      // Simulate build process
      await Future.delayed(const Duration(seconds: 2));

      if (target == 'ios') {
        // Just as an example of throwing our custom exception for a specific case
        // _logger.err('iOS build requires a mac environment.');
        // throw BuildException('Cannot build iOS on this environment without proper setup.');
      }

      progress.complete('Successfully built \$target');
      return 0; // Success code
    } on BuildException catch (e) {
      progress.fail('Build failed: \${e.message}');
      return 1; // Error code
    } catch (e) {
      progress.fail('An unexpected error occurred: \$e');
      return 1;
    }
  }
}
