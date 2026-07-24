import 'package:args/command_runner.dart';
import 'package:flutter_release_manager/utils/logger.dart';

/// The `reset` command for flutter_release_manager.
class ResetCommand extends Command<int> {
  final ReleaseManagerLogger _logger;

  ResetCommand({required ReleaseManagerLogger logger}) : _logger = logger;

  @override
  String get name => 'reset';

  @override
  String get description => 'Resets the release manager state or configuration.';

  @override
  Future<int> run() async {
    _logger.info('Resetting configuration...');
    // TODO: Implement reset logic
    _logger.success('Reset complete.');
    return 0;
  }
}
