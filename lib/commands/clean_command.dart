import 'package:args/command_runner.dart';
import 'package:flutter_release_manager/utils/logger.dart';
import 'package:flutter_release_manager/services/process_service.dart';

/// The `clean` command for flutter_release_manager.
class CleanCommand extends Command<int> {
  final ReleaseManagerLogger _logger;
  final ProcessService _processService;

  CleanCommand({
    required ReleaseManagerLogger logger,
    required ProcessService processService,
  })  : _logger = logger,
        _processService = processService;

  @override
  String get name => 'clean';

  @override
  String get description => 'Cleans the Flutter project build artifacts.';

  @override
  Future<int> run() async {
    _logger.info('Cleaning project...');
    try {
      await _processService.run('flutter', ['clean']);
      _logger.success('Project cleaned successfully.');
      return 0;
    } catch (e) {
      _logger.err('Failed to clean project: $e');
      return 1;
    }
  }
}
