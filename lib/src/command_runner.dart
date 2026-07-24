/// The core command runner for the CLI.
library flutter_release_manager.command_runner;

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'core/logger.dart';
import 'commands/build_command.dart';

/// The main command runner for flutter_release_manager.
class ReleaseCommandRunner extends CommandRunner<int> {
  final AppLogger _logger;

  /// Creates a new [ReleaseCommandRunner].
  ReleaseCommandRunner({AppLogger? logger})
      : _logger = logger ?? AppLogger(),
        super(
          'flutter_release_manager',
          'A production-ready open-source Dart CLI package that manages Flutter releases.',
        ) {
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Enable verbose logging.',
      negatable: false,
    );

    // Register commands
    addCommand(BuildCommand(logger: _logger));
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);
      
      // We don't have a direct way to change mason_logger log level via 
      // simple property after creation without recreating it or setting 
      // it up with a custom log level, but we would handle verbose logic here.
      if (argResults['verbose'] == true) {
        _logger.detail('Verbose logging enabled');
      }

      final exitCode = await runCommand(argResults);
      return exitCode ?? 0;
    } on FormatException catch (e) {
      _logger.err(e.message);
      _logger.info(usage);
      return 64; // EX_USAGE
    } on UsageException catch (e) {
      _logger.err(e.message);
      _logger.info(e.usage);
      return 64;
    } catch (e) {
      _logger.err('An unexpected error occurred: \$e');
      return 1;
    }
  }
}
