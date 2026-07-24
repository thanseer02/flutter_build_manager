import 'dart:io';
import '../artifact_locator_strategy.dart';

class SymbolsLocatorStrategy implements ArtifactLocatorStrategy {
  @override
  String get artifactType => 'symbols';

  @override
  Future<String?> locate({String? flavor, String? basePath}) async {
    final root = basePath ?? Directory.current.path;
    String relativePath;
    
    if (flavor != null && flavor.isNotEmpty) {
      relativePath = 'build/app/intermediates/merged_native_libs/${flavor.toLowerCase()}Release/out/lib';
    } else {
      relativePath = 'build/app/intermediates/merged_native_libs/release/out/lib';
    }

    final dir = Directory('$root/$relativePath');
    if (dir.existsSync()) {
      return dir.absolute.path;
    }
    return null;
  }
}
