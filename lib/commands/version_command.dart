import 'package:args/command_runner.dart';
import '../utils/logger.dart';
import '../services/version_service.dart';
import '../exceptions/release_manager_exception.dart';

/// The `version` command for flutter_release_manager.
class VersionCommand extends Command<int> {
  final ReleaseManagerLogger _logger;
  final VersionService _versionService;

  VersionCommand({
    required ReleaseManagerLogger logger,
    required VersionService versionService,
  })  : _logger = logger,
        _versionService = versionService;

  @override
  String get name => 'version';

  @override
  String get description => 'Prints the current version of the Flutter project.';

  @override
  Future<int> run() async {
    try {
      final versionInfo = await _versionService.getVersionInfo();
      // Using print instead of logger.info if we want the exact formatting,
      // but logger.info is fine as it usually prints to stdout.
      _logger.info(versionInfo.toString());
      return 0;
    } on ReleaseManagerException catch (e) {
      _logger.err(e.message);
      if (e.details != null) {
        _logger.info(e.details.toString());
      }
      return 1;
    } catch (e) {
      _logger.err('An unexpected error occurred while detecting version: $e');
      return 1;
    }
  }
}
