import 'package:args/command_runner.dart';
import 'package:flutter_release_manager/utils/logger.dart';
import 'package:flutter_release_manager/services/process_service.dart';

import 'package:flutter_release_manager/services/flutter_sdk_service.dart';

/// The `clean` command for flutter_release_manager.
class CleanCommand extends Command<int> {
  final ReleaseManagerLogger _logger;
  final ProcessService _processService;
  final FlutterSdkService _flutterSdkService;

  CleanCommand({
    required ReleaseManagerLogger logger,
    required ProcessService processService,
    required FlutterSdkService flutterSdkService,
  })  : _logger = logger,
        _processService = processService,
        _flutterSdkService = flutterSdkService;

  @override
  String get name => 'clean';

  @override
  String get description => 'Cleans the Flutter project build artifacts.';

  @override
  Future<int> run() async {
    _logger.info('Cleaning project...');
    try {
      final sdkInfo = await _flutterSdkService.getSdkInfo();
      final result = await _processService.run(sdkInfo.executablePath, ['clean']);
      if (result.exitCode != 0) {
        _logger.err('Failed to clean project: ${result.stderr}');
        return 1;
      }
      _logger.success('Project cleaned successfully.');
      return 0;
    } catch (e) {
      _logger.err('Failed to clean project: $e');
      return 1;
    }
  }
}
