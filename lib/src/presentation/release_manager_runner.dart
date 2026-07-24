import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../core/logging/logger.dart';
import '../domain/repositories/process_repository.dart';
import 'commands/build_command.dart';

/// The main CommandRunner for the flutter_release_manager CLI.
class ReleaseManagerRunner extends CommandRunner<int> {
  final ReleaseManagerLogger _logger;

  /// Creates a [ReleaseManagerRunner].
  ReleaseManagerRunner({
    required ReleaseManagerLogger logger,
    required ProcessRepository processRepository,
  })  : _logger = logger,
        super(
          'flutter_release_manager',
          'A production-ready open-source Dart CLI package that manages Flutter releases.',
        ) {
    argParser
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Print the current version.',
      )
      ..addFlag(
        'verbose',
        help: 'Enable verbose logging.',
        negatable: false,
      );

    addCommand(
      BuildCommand(
        logger: logger,
        processRepository: processRepository,
      ),
    );
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);

      if (argResults['verbose'] == true) {
        _logger.level = Level.verbose;
      }

      if (argResults['version'] == true) {
        _logger.info('flutter_release_manager version: 1.0.0');
        return 0;
      }

      return await runCommand(argResults) ?? 0;
    } on FormatException catch (e) {
      _logger.err(e.message);
      _logger.info('');
      _logger.info(usage);
      return 64; // EX_USAGE
    } on UsageException catch (e) {
      _logger.err(e.message);
      _logger.info('');
      _logger.info(e.usage);
      return 64; // EX_USAGE
    } catch (e) {
      _logger.err('An unexpected error occurred: $e');
      return 1;
    }
  }
}
