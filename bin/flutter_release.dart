import 'dart:io';

import 'package:flutter_release_manager/utils/logger.dart';
import 'package:flutter_release_manager/services/process_service.dart';
import 'package:flutter_release_manager/commands/release_manager_runner.dart';

/// Main entry point for the flutter_release_manager CLI.
Future<void> main(List<String> arguments) async {
  final logger = ReleaseManagerLogger();
  final processService = ProcessService(logger: logger);

  final runner = ReleaseManagerRunner(
    logger: logger,
    processService: processService,
  );

  final exitCode = await runner.run(arguments);
  exit(exitCode ?? 0);
}
