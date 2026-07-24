/// The entry point for the CLI.
library flutter_release_manager;

import 'dart:io';
import 'package:flutter_release_manager/src/command_runner.dart';

/// Main entry point for the flutter_release_manager CLI.
Future<void> main(List<String> args) async {
  final runner = ReleaseCommandRunner();
  
  final exitCode = await runner.run(args);
  
  // Exit gracefully with the appropriate status code.
  exit(exitCode);
}
