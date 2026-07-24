import 'package:args/command_runner.dart';
import 'package:flutter_release_manager/utils/logger.dart';
import 'package:flutter_release_manager/services/process_service.dart';

import 'package:flutter_release_manager/services/flutter_sdk_service.dart';

/// The `doctor` command for flutter_release_manager.
class DoctorCommand extends Command<int> {
  final ReleaseManagerLogger _logger;
  final ProcessService _processService;
  final FlutterSdkService _flutterSdkService;

  DoctorCommand({
    required ReleaseManagerLogger logger,
    required ProcessService processService,
    required FlutterSdkService flutterSdkService,
  })  : _logger = logger,
        _processService = processService,
        _flutterSdkService = flutterSdkService;

  @override
  String get name => 'doctor';

  @override
  String get description => 'Checks the system for required dependencies (like flutter doctor).';

  @override
  Future<int> run() async {
    _logger.info('Running flutter_release_manager doctor...');
    
    try {
      _logger.info('Checking flutter version...');
      final sdkInfo = await _flutterSdkService.getSdkInfo();
      final flutterVersion = await _processService.run(sdkInfo.executablePath, ['--version']);
      _logger.info(flutterVersion.stdout.toString());
      
      _logger.success('Doctor check passed.');
      return 0;
    } catch (e) {
      _logger.err('Doctor check failed: $e');
      return 1;
    }
  }
}
