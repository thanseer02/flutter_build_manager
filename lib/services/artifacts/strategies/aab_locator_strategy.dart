import 'dart:io';
import 'package:flutter_build_manager/services/artifacts/artifact_locator_strategy.dart';

class AabLocatorStrategy implements ArtifactLocatorStrategy {
  @override
  String get artifactType => 'aab';

  @override
  Future<String?> locate({String? flavor, String? basePath}) async {
    final root = basePath ?? Directory.current.path;
    String relativePath;
    
    if (flavor != null && flavor.isNotEmpty) {
      relativePath = 'build/app/outputs/bundle/${flavor.toLowerCase()}Release/app-${flavor.toLowerCase()}-release.aab';
    } else {
      relativePath = 'build/app/outputs/bundle/release/app-release.aab';
    }

    final file = File('$root/$relativePath');
    if (file.existsSync()) {
      return file.absolute.path;
    }
    return null;
  }
}
