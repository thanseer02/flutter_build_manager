import 'package:args/command_runner.dart';
import '../utils/logger.dart';

/// The `config` command for flutter_release_manager.
class ConfigCommand extends Command<int> {
  final ReleaseManagerLogger _logger;

  ConfigCommand({required ReleaseManagerLogger logger}) : _logger = logger;

  @override
  String get name => 'config';

  @override
  String get description => 'Manages the flutter_release_manager configuration.';

  @override
  Future<int> run() async {
    _logger.info('Reading configuration...');
    // TODO: Implement config reading/writing logic
    return 0;
  }
}
