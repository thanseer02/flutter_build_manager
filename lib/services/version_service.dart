import 'dart:io';
import 'package:yaml/yaml.dart';

import 'package:flutter_release_manager/exceptions/release_manager_exception.dart';
import 'package:flutter_release_manager/models/version_model.dart';
import 'package:flutter_release_manager/utils/logger.dart';

/// Service responsible for automatically detecting project versioning details.
class VersionService {
  final ReleaseManagerLogger _logger;

  VersionService({required ReleaseManagerLogger logger}) : _logger = logger;

  /// Reads the pubspec.yaml file and extracts the version information.
  /// 
  /// Throws [ReleaseManagerException] if the file is missing or malformed,
  /// or if required fields like `name` or `version` are absent.
  Future<VersionModel> getVersionInfo({String pubspecPath = 'pubspec.yaml'}) async {
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

      final versionString = yamlMap['version'];
      if (versionString == null || versionString is! String) {
        throw const ReleaseManagerException(
          'Version is missing in pubspec.yaml.',
          details: 'Please ensure your pubspec.yaml has a "version" field (e.g., version: 1.0.0+1).',
        );
      }

      // Parse version and build number
      // Format is usually version+build (e.g., 2.4.1+35)
      String version = versionString;
      String buildNumber = '';

      if (versionString.contains('+')) {
        final parts = versionString.split('+');
        version = parts[0];
        if (parts.length > 1) {
          buildNumber = parts[1];
        }
      }

      _logger.info('Detected version: $version+$buildNumber for project: $projectName');

      return VersionModel(
        projectName: projectName,
        version: version,
        buildNumber: buildNumber,
      );
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
