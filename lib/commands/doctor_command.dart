import 'package:args/command_runner.dart';
import '../utils/logger.dart';
import '../services/process_service.dart';

/// The `doctor` command for flutter_release_manager.
class DoctorCommand extends Command<int> {
  final ReleaseManagerLogger _logger;
  final ProcessService _processService;

  DoctorCommand({
    required ReleaseManagerLogger logger,
    required ProcessService processService,
  })  : _logger = logger,
        _processService = processService;

  @override
  String get name => 'doctor';

  @override
  String get description => 'Checks the system for required dependencies (like flutter doctor).';

  @override
  Future<int> run() async {
    _logger.info('Running flutter_release_manager doctor...');
    
    try {
      _logger.info('Checking flutter version...');
      final flutterVersion = await _processService.run('flutter', ['--version']);
      _logger.info(flutterVersion);
      
      _logger.success('Doctor check passed.');
      return 0;
    } catch (e) {
      _logger.err('Doctor check failed: $e');
      return 1;
    }
  }
}
