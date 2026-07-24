import 'package:args/command_runner.dart';
import '../utils/logger.dart';

/// The `version` command for flutter_release_manager.
class VersionCommand extends Command<int> {
  final ReleaseManagerLogger _logger;

  VersionCommand({required ReleaseManagerLogger logger}) : _logger = logger;

  @override
  String get name => 'version';

  @override
  String get description => 'Prints the current version of flutter_release_manager.';

  @override
  Future<int> run() async {
    // We could read this from a generated version file in the future.
    _logger.info('flutter_release_manager version: 1.0.0');
    return 0;
  }
}
