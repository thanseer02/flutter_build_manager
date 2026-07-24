import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:yaml/yaml.dart';

import '../utils/logger.dart';
import '../exceptions/release_manager_exception.dart';

/// The `init` command for flutter_release_manager.
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

    // Generate default configuration
    final defaultConfig = '''
# flutter_release_manager configuration

project_name: "example_project"
versioning:
  strategy: "standard" # standard, semantic, date

platforms:
  ios:
    enabled: true
    export_options_plist: "ios/ExportOptions.plist"
  android:
    enabled: true
    build_type: "appbundle" # appbundle, apk
  macos:
    enabled: false
  windows:
    enabled: false
  linux:
    enabled: false

hooks:
  pre_build: []
  post_build: []
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
      
      if (!doc.containsKey('project_name')) {
        throw const ReleaseManagerException('Missing required field: project_name');
      }
      
      if (!doc.containsKey('platforms')) {
        throw const ReleaseManagerException('Missing required field: platforms');
      }
    } catch (e) {
      if (e is ReleaseManagerException) rethrow;
      throw ReleaseManagerException('Invalid YAML structure', details: e.toString());
    }
  }
}
