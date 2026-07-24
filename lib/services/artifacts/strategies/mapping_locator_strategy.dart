import 'dart:io';
import '../artifact_locator_strategy.dart';

class MappingLocatorStrategy implements ArtifactLocatorStrategy {
  @override
  String get artifactType => 'mapping.txt';

  @override
  Future<String?> locate({String? flavor, String? basePath}) async {
    final root = basePath ?? Directory.current.path;
    String relativePath;
    
    if (flavor != null && flavor.isNotEmpty) {
      relativePath = 'build/app/outputs/mapping/${flavor.toLowerCase()}Release/mapping.txt';
    } else {
      relativePath = 'build/app/outputs/mapping/release/mapping.txt';
    }

    final file = File('$root/$relativePath');
    if (file.existsSync()) {
      return file.absolute.path;
    }
    return null;
  }
}
