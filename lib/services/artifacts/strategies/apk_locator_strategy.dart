import 'dart:io';
import 'package:flutter_build_manager/services/artifacts/artifact_locator_strategy.dart';

class ApkLocatorStrategy implements ArtifactLocatorStrategy {
  @override
  String get artifactType => 'apk';

  @override
  Future<String?> locate({String? flavor, String? basePath}) async {
    final root = basePath ?? Directory.current.path;
    String relativePath;
    
    if (flavor != null && flavor.isNotEmpty) {
      relativePath = 'build/app/outputs/flutter-apk/app-${flavor.toLowerCase()}-release.apk';
    } else {
      relativePath = 'build/app/outputs/flutter-apk/app-release.apk';
    }

    final file = File('$root/$relativePath');
    if (file.existsSync()) {
      return file.absolute.path;
    }
    return null;
  }
}
