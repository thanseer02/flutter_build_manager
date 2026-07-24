import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:yaml/yaml.dart';
import 'package:intl/intl.dart';

import 'package:flutter_build_manager/utils/logger.dart';
import 'package:flutter_build_manager/services/project_service.dart';
import 'package:flutter_build_manager/services/version_service.dart';
import 'package:flutter_build_manager/services/environment/environment_service.dart';
import 'package:flutter_build_manager/services/build_counter_service.dart';
import 'package:flutter_build_manager/services/filename_template_service.dart';
import 'package:flutter_build_manager/exceptions/release_manager_exception.dart';

/// The `preview` command for flutter_build_manager.
class PreviewCommand extends Command<int> {
  final ReleaseManagerLogger _logger;
  final ProjectService _projectService;
  final VersionService _versionService;
  final EnvironmentService _environmentService;
  final BuildCounterService _buildCounterService;
  final FilenameTemplateService _filenameTemplateService;

  PreviewCommand({
    required ReleaseManagerLogger logger,
    required ProjectService projectService,
    required VersionService versionService,
    required EnvironmentService environmentService,
    required BuildCounterService buildCounterService,
    required FilenameTemplateService filenameTemplateService,
  })  : _logger = logger,
        _projectService = projectService,
        _versionService = versionService,
        _environmentService = environmentService,
        _buildCounterService = buildCounterService,
        _filenameTemplateService = filenameTemplateService;

  @override
  String get name => 'preview';

  @override
  String get description => 'Previews the release configuration without executing it.';

  @override
  Future<int> run() async {
    try {
      final project = await _projectService.getProjectInfo();
      final version = await _versionService.getVersionInfo();
      final env = await _environmentService.detectEnvironment(argResults);
      final counter = await _buildCounterService.peekNextBuildNumber(env.name);

      String template = '{project}_{date}_{env}_{counter}';
      String outputDir = 'release';

      // Load config if exists
      final configFile = File('flutter_release.yaml');
      if (configFile.existsSync()) {
        try {
          final doc = loadYaml(configFile.readAsStringSync());
          if (doc is YamlMap && doc['release_manager'] is YamlMap) {
            final rm = doc['release_manager'];
            if (rm['template'] != null) template = rm['template'];
            if (rm['output_directory'] != null) outputDir = rm['output_directory'];
            
            // Generate organized path if needed
            if (rm['organize_by'] is YamlMap) {
              final org = rm['organize_by'];
              final now = DateTime.now();
              String orgPath = '';
              if (org['year'] == true) orgPath += '${DateFormat('yyyy').format(now)}/';
              if (org['month'] == true) orgPath += '${DateFormat('MMMM').format(now)}/';
              if (org['environment'] == true) orgPath += '${env.name}/';
              
              if (orgPath.isNotEmpty) {
                outputDir = '$outputDir/$orgPath';
              }
            }
          }
        } catch (_) {
          // ignore yaml parse errors for preview fallback
        }
      }

      final variables = TemplateVariables(
        project: project.name,
        version: version.version,
        flutterBuild: version.buildNumber,
        counter: counter,
        env: env.name,
      );

      final filename = _filenameTemplateService.generateFilename(template, variables);
      
      // Clean up output dir slashes for display
      outputDir = outputDir.replaceAll('//', '/');
      if (!outputDir.endsWith('/')) {
        outputDir += '/';
      }

      _logger.info('--------------------------------------\n');
      _logger.info('Project : ${project.name}\n');
      _logger.info('Version : ${version.version}\n');
      _logger.info('Environment : ${env.name}\n');
      _logger.info('Counter : $counter\n');
      _logger.info('Filename :\n$filename.apk\n'); // Assuming .apk for preview example
      _logger.info('Output :\n$outputDir\n');
      _logger.info('--------------------------------------');

      return 0;
    } on ReleaseManagerException catch (e) {
      _logger.err(e.message);
      if (e.details != null) _logger.info(e.details.toString());
      return 1;
    } catch (e) {
      _logger.err('An unexpected error occurred during preview: $e');
      return 1;
    }
  }
}
