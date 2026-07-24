import 'dart:io';
import 'package:yaml/yaml.dart';

import '../exceptions/release_manager_exception.dart';
import '../models/project_model.dart';

/// Service responsible for extracting general project information.
class ProjectService {
  /// Reads the pubspec.yaml file and extracts the project name.
  /// 
  /// Throws [ReleaseManagerException] if the file is missing, malformed,
  /// or if the `name` field is absent. This method will never crash
  /// with unhandled exceptions.
  Future<ProjectModel> getProjectInfo({String pubspecPath = 'pubspec.yaml'}) async {
    final file = File(pubspecPath);
    
    if (!file.existsSync()) {
      throw ReleaseManagerException(
        'pubspec.yaml not found at $pubspecPath.',
        details: 'Please ensure you are running this command from the root of a Flutter project.',
      );
    }

    try {
      final content = await file.readAsString();
      final yamlMap = loadYaml(content);

      if (yamlMap is! YamlMap) {
        throw const ReleaseManagerException('pubspec.yaml does not contain a valid YAML map.');
      }

      final projectName = yamlMap['name'];
      if (projectName == null || projectName is! String) {
        throw const ReleaseManagerException(
          'Project name is missing in pubspec.yaml.',
          details: 'Please ensure your pubspec.yaml has a "name" field.',
        );
      }

      return ProjectModel(name: projectName);
    } catch (e) {
      if (e is ReleaseManagerException) {
        rethrow;
      }
      throw ReleaseManagerException(
        'Failed to parse pubspec.yaml safely.',
        details: e.toString(),
      );
    }
  }
}
