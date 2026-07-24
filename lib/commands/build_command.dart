import 'package:args/command_runner.dart';
import 'package:flutter_build_manager/services/pipeline/release_pipeline_service.dart';

/// The `build` command for flutter_build_manager.
///
/// This command handles triggering Flutter builds for various platforms.
class BuildCommand extends Command<int> {
  final ReleasePipelineService _pipelineService;

  /// Creates a [BuildCommand].
  BuildCommand({
    required ReleasePipelineService pipelineService,
  }) : _pipelineService = pipelineService {
    argParser.addOption(
      'target',
      abbr: 't',
      help: 'The target platform to build for (e.g., apk, aab, ipa).',
      allowed: ['apk', 'aab', 'ipa'],
      mandatory: true,
    );
  }

  @override
  String get name => 'build';

  @override
  String get description => 'Builds the Flutter application and organizes the release artifacts.';

  @override
  Future<int> run() async {
    final target = argResults?['target'] as String?;
    if (target == null) {
      return 1;
    }
    
    // We get flavor and env from the global args
    final flavor = globalResults?['flavor'] as String?;
    final envArg = globalResults?['env'] as String?;

    try {
      await _pipelineService.runPipeline(
        target: target,
        argResults: globalResults,
        flavor: flavor,
        envArg: envArg,
      );
      return 0;
    } catch (e) {
      return 1;
    }
  }
}
