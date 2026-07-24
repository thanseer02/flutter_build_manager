import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../utils/logger.dart';
import '../services/process_service.dart';
import '../services/version_service.dart';

import 'build_command.dart';
import 'init_command.dart';
import 'preview_command.dart';
import 'config_command.dart';
import 'reset_command.dart';
import 'version_command.dart';
import 'clean_command.dart';
import 'doctor_command.dart';

/// The main CommandRunner for the flutter_release_manager CLI.
class ReleaseManagerRunner extends CommandRunner<int> {
  final ReleaseManagerLogger _logger;

  /// Creates a [ReleaseManagerRunner].
  ReleaseManagerRunner({
    required ReleaseManagerLogger logger,
    required ProcessService processService,
  })  : _logger = logger,
        super(
          'flutter_release',
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

    final versionService = VersionService(logger: logger);

    addCommand(InitCommand(logger: logger));
    addCommand(BuildCommand(logger: logger, processService: processService));
    addCommand(PreviewCommand(logger: logger));
    addCommand(ConfigCommand(logger: logger));
    addCommand(ResetCommand(logger: logger));
    addCommand(VersionCommand(logger: logger, versionService: versionService));
    addCommand(CleanCommand(logger: logger, processService: processService));
    addCommand(DoctorCommand(logger: logger, processService: processService));
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);

      if (argResults['verbose'] == true) {
        _logger.level = Level.verbose;
      }

      if (argResults['version'] == true) {
        _logger.info('flutter_release version: 1.0.0');
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
