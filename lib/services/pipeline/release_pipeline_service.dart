import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

import '../../utils/logger.dart';
import '../../exceptions/release_manager_exception.dart';
import '../../models/release_metadata_model.dart';
import '../project_service.dart';
import '../version_service.dart';
import '../environment/environment_service.dart';
import '../build_counter_service.dart';
import '../filename_template_service.dart';
import '../build_service.dart';
import '../artifacts/artifact_locator_service.dart';
import '../artifacts/artifact_rename_service.dart';
import '../release_directory_service.dart';
import '../metadata_service.dart';
import '../checksum_service.dart';
import '../logger_service.dart';
import 'release_context.dart';

/// Orchestrates the entire release pipeline safely.
class ReleasePipelineService {
  final ReleaseManagerLogger _uiLogger;
  final ProjectService _projectService;
  final VersionService _versionService;
  final EnvironmentService _environmentService;
  final BuildCounterService _buildCounterService;
  final FilenameTemplateService _filenameTemplateService;
  final BuildService _buildService;
  final ArtifactLocatorService _artifactLocatorService;
  final ArtifactRenameService _artifactRenameService;
  final ReleaseDirectoryService _releaseDirectoryService;
  final MetadataService _metadataService;
  final ChecksumService _checksumService;
  final LoggerService _fileLogger;

  ReleasePipelineService({
    required ReleaseManagerLogger uiLogger,
    required ProjectService projectService,
    required VersionService versionService,
    required EnvironmentService environmentService,
    required BuildCounterService buildCounterService,
    required FilenameTemplateService filenameTemplateService,
    required BuildService buildService,
    required ArtifactLocatorService artifactLocatorService,
    required ArtifactRenameService artifactRenameService,
    required ReleaseDirectoryService releaseDirectoryService,
    required MetadataService metadataService,
    required ChecksumService checksumService,
    required LoggerService fileLogger,
  })  : _uiLogger = uiLogger,
        _projectService = projectService,
        _versionService = versionService,
        _environmentService = environmentService,
        _buildCounterService = buildCounterService,
        _filenameTemplateService = filenameTemplateService,
        _buildService = buildService,
        _artifactLocatorService = artifactLocatorService,
        _artifactRenameService = artifactRenameService,
        _releaseDirectoryService = releaseDirectoryService,
        _metadataService = metadataService,
        _checksumService = checksumService,
        _fileLogger = fileLogger;

  Future<void> runPipeline({
    required String target,
    ArgResults? argResults,
    String? flavor,
    String? envArg,
  }) async {
    final context = ReleaseContext(target: target, flavor: flavor, envFlag: envArg);
    final stopwatch = Stopwatch()..start();

    try {
      _uiLogger.info('🚀 Starting Flutter Release Pipeline...');
      await _fileLogger.info('Pipeline Started for target: $target');

      // Phase 1: Setup & Detection
      await _phase1Setup(context, argResults);

      // Phase 2: Execution
      await _phase2Build(context);

      // Phase 3: Post-Processing & File Management
      await _phase3PostProcess(context);

      // Phase 4: Finalization
      await _phase4Finalize(context, stopwatch.elapsed);

      _uiLogger.success('🎉 Release completed successfully!');
    } catch (e, st) {
      await _fileLogger.error('Pipeline failed.', error: e, stackTrace: st);
      _uiLogger.err('❌ Pipeline Failed:');
      if (e is ReleaseManagerException) {
        _uiLogger.err(e.message);
        if (e.details != null) {
          _uiLogger.info(e.details.toString());
        }
      } else {
        _uiLogger.err(e.toString());
      }
      
      await _rollback(context);
    }
  }

  Future<void> _phase1Setup(ReleaseContext context, ArgResults? argResults) async {
    _uiLogger.info('-> Validating project and loading configuration...');
    
    // 3. Read pubspec / 4. Detect name
    context.project = await _projectService.getProjectInfo();
    
    // 5. Detect version
    context.version = await _versionService.getVersionInfo();
    
    // 6. Detect environment
    context.environment = await _environmentService.detectEnvironment(argResults);
    
    // 7. Generate build counter (Peek only! Don't commit yet)
    context.nextCounter = await _buildCounterService.peekNextBuildNumber(context.environment!.name);

    // 8. Generate filename
    final templateVars = TemplateVariables(
      project: context.project!.name,
      version: context.version!.version,
      flutterBuild: context.version!.buildNumber,
      counter: context.nextCounter!,
      env: context.environment!.name,
    );
    
    // Note: We need to pull template from config, but FilenameTemplateService can do it or we assume default if we don't have it here. 
    // Wait, FilenameTemplateService doesn't read the config directly in generateFilename. 
    // We should probably read it or use a default. For now, let's use a safe default template.
    // In a full implementation, we'd read `flutter_release.yaml`.
    String template = '{project}_{date}_{env}_{counter}';
    final configFile = File('flutter_release.yaml');
    if (configFile.existsSync()) {
      // Very basic read just for template, in real code use config service
      final content = configFile.readAsStringSync();
      if (content.contains('template:')) {
        final match = RegExp(r'template:\s*"?([^"\n]+)"?').firstMatch(content);
        if (match != null) {
          template = match.group(1)!;
        }
      }
    }
    
    context.generatedFilename = _filenameTemplateService.generateFilename(template, templateVars);

    // 9. Preview
    _uiLogger.info('   Project: ${context.project!.name} (${context.version!.version}+${context.version!.buildNumber})');
    _uiLogger.info('   Environment: ${context.environment!.name}');
    _uiLogger.info('   Filename: ${context.generatedFilename}');
  }

  Future<void> _phase2Build(ReleaseContext context) async {
    _uiLogger.info('-> Executing Flutter build (${context.target})...');
    
    // 10. Execute Flutter build
    final result = await _buildService.executeBuild(
      context.target,
      flavor: context.flavor,
      env: context.envFlag,
    );
    
    if (!result.isSuccess) {
      throw ReleaseManagerException('Build failed.', details: result.errorMessage);
    }
    
    context.buildResult = result;
    _uiLogger.info('   Build successful in ${result.buildDuration.inSeconds} seconds.');
  }

  Future<void> _phase3PostProcess(ReleaseContext context) async {
    _uiLogger.info('-> Locating and organizing artifacts...');
    
    // 11. Locate generated artifacts
    final originalArtifactPath = await _artifactLocatorService.locateArtifact(
      context.target,
      flavor: context.flavor,
    );

    // 13. Create release directory
    context.finalReleaseDirectory = await _releaseDirectoryService.getReleaseDirectory(
      environment: context.environment!.name,
    );

    // 12 & 14. Rename and Move artifacts transactionally
    final ext = p.extension(originalArtifactPath);
    final targetArtifactPath = p.join(context.finalReleaseDirectory!, '${context.generatedFilename}$ext');
    
    context.finalArtifactPath = await _artifactRenameService.renameArtifact(
      originalArtifactPath,
      targetArtifactPath,
    );
    
    // Track file for rollback
    context.rollbackFiles.add(context.finalArtifactPath!);

    // 15. Generate metadata
    final metadata = ReleaseMetadataModel(
      projectName: context.project!.name,
      version: context.version!.version,
      flutterBuildNumber: context.version!.buildNumber,
      environment: context.environment!.name,
      counter: context.nextCounter!,
      generatedFilename: p.basename(context.finalArtifactPath!),
      artifactType: context.target,
      artifactSize: File(context.finalArtifactPath!).lengthSync(),
      generatedTime: DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(DateTime.now().toUtc()),
      flutterVersion: 'Detected via build', // Real implementation could parse `flutter --version`
      dartVersion: Platform.version.split(' ').first,
      operatingSystem: Platform.operatingSystem,
      releaseDirectory: context.finalReleaseDirectory!,
    );
    
    context.finalMetadataPath = await _metadataService.generateMetadataFile(metadata);
    context.rollbackFiles.add(context.finalMetadataPath!);

    // 16. Generate SHA256 checksum
    context.finalChecksumPath = await _checksumService.generateChecksum(context.finalArtifactPath!);
    context.rollbackFiles.add(context.finalChecksumPath!);
  }

  Future<void> _phase4Finalize(ReleaseContext context, Duration totalTime) async {
    _uiLogger.info('-> Finalizing release...');
    
    // 17. Update build counter (Commit!)
    await _buildCounterService.getNextBuildNumber(context.environment!.name);

    // 18. Write logs
    await _fileLogger.info(
      'Build Success: ${context.project!.name} | Env: ${context.environment!.name} | File: ${context.finalArtifactPath} | Time: ${totalTime.inSeconds}s',
    );

    // 19. Summary
    _uiLogger.info('--------------------------------------');
    _uiLogger.info('Artifact   : ${context.finalArtifactPath}');
    _uiLogger.info('Metadata   : ${context.finalMetadataPath}');
    _uiLogger.info('Checksum   : ${context.finalChecksumPath}');
    _uiLogger.info('Total Time : ${totalTime.inSeconds}s');
    _uiLogger.info('--------------------------------------');
  }

  Future<void> _rollback(ReleaseContext context) async {
    if (context.rollbackFiles.isEmpty) return;
    
    _uiLogger.err('Rolling back partial file movements...');
    await _fileLogger.warning('Initiating rollback for ${context.rollbackFiles.length} files.');
    
    for (final file in context.rollbackFiles) {
      try {
        final f = File(file);
        if (f.existsSync()) {
          f.deleteSync();
          _uiLogger.info('   Rolled back: $file');
        }
      } catch (e) {
        _uiLogger.err('   Failed to rollback: $file');
      }
    }
    
    _uiLogger.info('Rollback complete. Build counter was not incremented.');
  }
}
