import 'package:args/command_runner.dart';
import '../utils/logger.dart';

/// The `preview` command for flutter_release_manager.
class PreviewCommand extends Command<int> {
  final ReleaseManagerLogger _logger;

  PreviewCommand({required ReleaseManagerLogger logger}) : _logger = logger;

  @override
  String get name => 'preview';

  @override
  String get description => 'Previews the release configuration without executing it.';

  @override
  Future<int> run() async {
    _logger.info('Previewing release configuration...');
    // TODO: Implement preview logic
    _logger.success('Preview complete.');
    return 0;
  }
}
