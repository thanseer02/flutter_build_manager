import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:yaml/yaml.dart';

import 'package:flutter_build_manager/utils/logger.dart';
import 'package:flutter_build_manager/exceptions/release_manager_exception.dart';
import 'package:flutter_build_manager/services/project_service.dart';

/// The `init` command for flutter_build_manager.
/// Initializes the workspace with release configurations.
class InitCommand extends Command<int> {
  final ReleaseManagerLogger _logger;

  InitCommand({required ReleaseManagerLogger logger}) : _logger = logger;

  @override
  String get name => 'init';

  @override
  String get description => 'Initializes flutter_release configuration in the current project.';

  @override
  Future<int> run() async {
    _logger.info('Initializing flutter_release configuration...');

    final configFile = File('flutter_release.yaml');

    if (configFile.existsSync()) {
      _logger.warn('Configuration file already exists: flutter_release.yaml');
      final shouldOverwrite = _logger.confirm('Do you want to overwrite it?', defaultValue: false);
      
      if (!shouldOverwrite) {
        _logger.info('Initialization cancelled by user.');
        return 0;
      }
    }

    // Detect project name using ProjectService
    String projectName = 'unknown_project';
    try {
      final projectService = ProjectService();
      final projectInfo = await projectService.getProjectInfo();
      projectName = projectInfo.name;
    } on ReleaseManagerException catch (e) {
      _logger.warn('Could not detect project name automatically: ${e.message}');
      _logger.info('Falling back to "unknown_project"');
    }

    final defaultConfig = '''
release_manager:
  enabled: true
  output_directory: release
  template: "${projectName}_{date}_{env}_{build}"
  build_counter:
    mode: daily
  environment:
    source: auto
  rename:
    apk: true
    aab: true
    ipa: true
  organize_by:
    year: true
    month: true
    environment: true
  checksum:
    sha256: true
  metadata:
    enabled: true
''';

    try {
      // Write the file
      configFile.writeAsStringSync(defaultConfig);

      // Validate the newly created configuration to ensure it parses correctly
      _validateConfiguration(defaultConfig);

      _logger.success('Initialization complete. Created flutter_release.yaml');
      return 0;
    } on ReleaseManagerException catch (e) {
      _logger.err('Validation failed after creation: ${e.message}');
      return 1;
    } catch (e) {
      _logger.err('Failed to create configuration file: $e');
      return 1;
    }
  }

  void _validateConfiguration(String yamlContent) {
    try {
      final doc = loadYaml(yamlContent);
      if (doc is! YamlMap) {
        throw const ReleaseManagerException('Configuration must be a valid YAML map.');
      }
      
      if (!doc.containsKey('release_manager')) {
        throw const ReleaseManagerException('Missing required root key: release_manager');
      }

      final releaseManagerConfig = doc['release_manager'];
      if (releaseManagerConfig is! YamlMap) {
        throw const ReleaseManagerException('release_manager must be a map.');
      }
      
      if (!releaseManagerConfig.containsKey('enabled')) {
        throw const ReleaseManagerException('Missing required field: release_manager.enabled');
      }
    } catch (e) {
      if (e is ReleaseManagerException) rethrow;
      throw ReleaseManagerException('Invalid YAML structure', details: e.toString());
    }
  }
}
