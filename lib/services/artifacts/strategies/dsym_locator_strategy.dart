import 'dart:io';
import 'package:flutter_build_manager/services/artifacts/artifact_locator_strategy.dart';

class DsymLocatorStrategy implements ArtifactLocatorStrategy {
  @override
  String get artifactType => 'dsym';

  @override
  Future<String?> locate({String? flavor, String? basePath}) async {
    final root = basePath ?? Directory.current.path;
    
    // dSYMs are usually zipped inside the build directory or found in the xcarchive.
    // For Flutter, a common place during a release build is:
    final relativePath = 'build/ios/archive/Runner.xcarchive/dSYMs/Runner.app.dSYM';

    final dir = Directory('$root/$relativePath');
    if (dir.existsSync()) {
      return dir.absolute.path;
    }
    return null;
  }
}
