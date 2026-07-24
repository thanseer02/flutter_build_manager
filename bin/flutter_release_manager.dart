import 'dart:io';

import 'package:flutter_release_manager/src/core/logging/logger.dart';
import 'package:flutter_release_manager/src/data/processes/process_runner.dart';
import 'package:flutter_release_manager/src/presentation/release_manager_runner.dart';

/// Main entry point for the flutter_release_manager CLI.
Future<void> main(List<String> arguments) async {
  final logger = ReleaseManagerLogger();
  final processRepository = ProcessRunner(logger: logger);

  final runner = ReleaseManagerRunner(
    logger: logger,
    processRepository: processRepository,
  );

  final exitCode = await runner.run(arguments);
  exit(exitCode);
}
