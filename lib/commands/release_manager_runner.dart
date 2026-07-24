import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:flutter_release_manager/utils/logger.dart';
import 'package:flutter_release_manager/services/process_service.dart';
import 'package:flutter_release_manager/services/version_service.dart';
import 'package:flutter_release_manager/services/project_service.dart';
import 'package:flutter_release_manager/services/environment/environment_service.dart';
import 'package:flutter_release_manager/services/build_counter_service.dart';
import 'package:flutter_release_manager/services/filename_template_service.dart';
import 'package:flutter_release_manager/services/flutter_sdk_service.dart';
import 'package:flutter_release_manager/services/build_service.dart';
import 'package:flutter_release_manager/services/artifacts/artifact_locator_service.dart';
import 'package:flutter_release_manager/services/artifacts/artifact_rename_service.dart';
import 'package:flutter_release_manager/services/release_directory_service.dart';
import 'package:flutter_release_manager/services/metadata_service.dart';
import 'package:flutter_release_manager/services/checksum_service.dart';
import 'package:flutter_release_manager/services/logger_service.dart';
import 'package:flutter_release_manager/services/pipeline/release_pipeline_service.dart';

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
      )
      ..addOption(
        'env',
        help: 'Manually specify the environment (e.g., DEV, UAT, PROD).',
      )
      ..addOption(
        'flavor',
        help: 'Manually specify the Flutter flavor.',
      )
      ..addMultiOption(
        'dart-define',
        help: 'Pass dart defines (e.g., --dart-define=ENV=PROD).',
      );

    final projectService = ProjectService();
    final versionService = VersionService(logger: logger);
    final environmentService = EnvironmentService(logger: logger);
    final buildCounterService = BuildCounterService();
    final filenameTemplateService = FilenameTemplateService();
    
    // New services
    final flutterSdkService = FlutterSdkService(processService: processService);
    final buildService = BuildService(
      processService: processService,
      flutterSdkService: flutterSdkService,
    );
    final artifactLocatorService = ArtifactLocatorService();
    final artifactRenameService = ArtifactRenameService();
    final releaseDirectoryService = ReleaseDirectoryService();
    final metadataService = MetadataService();
    final checksumService = ChecksumService();
    final fileLogger = LoggerService();

    final pipelineService = ReleasePipelineService(
      uiLogger: logger,
      projectService: projectService,
      versionService: versionService,
      environmentService: environmentService,
      buildCounterService: buildCounterService,
      filenameTemplateService: filenameTemplateService,
      buildService: buildService,
      artifactLocatorService: artifactLocatorService,
      artifactRenameService: artifactRenameService,
      releaseDirectoryService: releaseDirectoryService,
      metadataService: metadataService,
      checksumService: checksumService,
      fileLogger: fileLogger,
    );

    addCommand(InitCommand(logger: logger));
    addCommand(BuildCommand(pipelineService: pipelineService));
    addCommand(PreviewCommand(
      logger: logger,
      projectService: projectService,
      versionService: versionService,
      environmentService: environmentService,
      buildCounterService: buildCounterService,
      filenameTemplateService: filenameTemplateService,
    ));
    addCommand(ConfigCommand(logger: logger));
    addCommand(ResetCommand(logger: logger));
    addCommand(VersionCommand(logger: logger, versionService: versionService));
    addCommand(CleanCommand(logger: logger, processService: processService, flutterSdkService: flutterSdkService));
    addCommand(DoctorCommand(logger: logger, processService: processService, flutterSdkService: flutterSdkService));
  }
}
