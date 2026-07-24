import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter_build_manager/models/release_metadata_model.dart';
import 'package:flutter_build_manager/exceptions/release_manager_exception.dart';

/// Service responsible for generating and validating release metadata JSON.
class MetadataService {
  /// Generates the `release.json` file inside the target [releaseDirectory].
  /// 
  /// Returns the absolute path of the generated `release.json`.
  Future<String> generateMetadataFile(ReleaseMetadataModel metadata) async {
    _validateMetadata(metadata);

    final dir = Directory(metadata.releaseDirectory);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final file = File(p.join(dir.path, 'release.json'));
    
    // Format JSON with 2-space indentation
    final encoder = const JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(metadata.toJson());
    
    await file.writeAsString(jsonString);
    
    return file.absolute.path;
  }

  /// Validates that the provided metadata has no missing or highly unexpected values.
  void _validateMetadata(ReleaseMetadataModel metadata) {
    if (metadata.projectName.isEmpty) {
      throw const ReleaseManagerException('Invalid metadata: Project Name is empty.');
    }
    if (metadata.version.isEmpty) {
      throw const ReleaseManagerException('Invalid metadata: Version is empty.');
    }
    if (metadata.generatedFilename.isEmpty) {
      throw const ReleaseManagerException('Invalid metadata: Generated Filename is empty.');
    }
    if (metadata.artifactSize < 0) {
      throw const ReleaseManagerException('Invalid metadata: Artifact Size cannot be negative.');
    }
    if (metadata.releaseDirectory.isEmpty) {
      throw const ReleaseManagerException('Invalid metadata: Release Directory is empty.');
    }
  }
}
