import 'dart:io';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

import '../environment_detection_strategy.dart';

/// Strategy to detect the environment from the flutter_release.yaml configuration.
class YamlConfigDetectionStrategy implements EnvironmentDetectionStrategy {
  final String configPath;

  YamlConfigDetectionStrategy({this.configPath = 'flutter_release.yaml'});

  @override
  String get name => 'flutter_release.yaml';

  @override
  Future<String?> detect(ArgResults? argResults) async {
    final file = File(configPath);
    if (!file.existsSync()) return null;

    try {
      final content = await file.readAsString();
      final yamlMap = loadYaml(content);

      if (yamlMap is YamlMap) {
        final releaseManager = yamlMap['release_manager'];
        if (releaseManager is YamlMap) {
          final environmentBlock = releaseManager['environment'];
          if (environmentBlock is YamlMap) {
            final source = environmentBlock['source'];
            if (source != null && source != 'auto') {
              return source.toString();
            }
          }
        }
      }
    } catch (_) {
      // Fail silently for YAML fallback strategy. The master service handles errors.
    }
    
    return null;
  }
}
