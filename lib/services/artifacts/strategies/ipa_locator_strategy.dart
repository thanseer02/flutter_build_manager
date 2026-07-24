import 'dart:io';
import 'package:flutter_build_manager/services/artifacts/artifact_locator_strategy.dart';

class IpaLocatorStrategy implements ArtifactLocatorStrategy {
  @override
  String get artifactType => 'ipa';

  @override
  Future<String?> locate({String? flavor, String? basePath}) async {
    final root = basePath ?? Directory.current.path;
    // IPAs are typically generated here regardless of flavor in standard setups
    final relativePath = 'build/ios/ipa/Runner.ipa';

    final file = File('$root/$relativePath');
    if (file.existsSync()) {
      return file.absolute.path;
    }
    return null;
  }
}
