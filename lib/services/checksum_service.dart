import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

import 'package:flutter_release_manager/exceptions/release_manager_exception.dart';

/// Service responsible for generating SHA256 checksums for artifacts.
class ChecksumService {
  /// Generates a checksum file in the same directory as [artifactPath].
  /// 
  /// The checksum file will be named `<filename>.sha256`.
  /// Returns the absolute path to the generated checksum file.
  Future<String> generateChecksum(String artifactPath) async {
    final entityType = FileSystemEntity.typeSync(artifactPath);
    if (entityType == FileSystemEntityType.notFound) {
      throw ReleaseManagerException('Cannot generate checksum: Artifact not found at $artifactPath');
    }

    String hashValue;
    if (entityType == FileSystemEntityType.directory) {
      hashValue = await _hashDirectory(Directory(artifactPath));
    } else {
      hashValue = await _hashFile(File(artifactPath));
    }

    final filename = p.basename(artifactPath);
    final checksumFilePath = p.join(p.dirname(artifactPath), '$filename.sha256');
    final checksumFile = File(checksumFilePath);

    final generatedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final content = '''
$hashValue
$filename
$generatedTime
''';

    await checksumFile.writeAsString(content);

    return checksumFile.absolute.path;
  }

  Future<String> _hashFile(File file) async {
    try {
      final stream = file.openRead();
      final hash = await sha256.bind(stream).first;
      return hash.toString();
    } catch (e) {
      throw ReleaseManagerException('Failed to hash file: ${file.path}', details: e.toString());
    }
  }

  Future<String> _hashDirectory(Directory dir) async {
    try {
      final files = dir.listSync(recursive: true).whereType<File>().toList();
      // Sort to ensure consistent hashing
      files.sort((a, b) => a.path.compareTo(b.path));

      final output = AccumulatorSink<Digest>();
      final input = sha256.startChunkedConversion(output);

      for (final file in files) {
        final bytes = file.readAsBytesSync();
        input.add(bytes);
      }
      input.close();

      return output.events.single.toString();
    } catch (e) {
      throw ReleaseManagerException('Failed to hash directory: ${dir.path}', details: e.toString());
    }
  }
}
