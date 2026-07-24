import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';

import 'package:flutter_release_manager/services/checksum_service.dart';
import 'package:flutter_release_manager/exceptions/release_manager_exception.dart';

void main() {
  group('ChecksumService', () {
    late ChecksumService service;
    late String testDir;

    setUp(() {
      service = ChecksumService();
      final dir = Directory.systemTemp.createTempSync('checksum_service_test_');
      testDir = dir.path;
    });

    tearDown(() {
      final dir = Directory(testDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('generates correct checksum for a file', () async {
      final content = 'hello world';
      final file = File(p.join(testDir, 'DriveReplay_20260724_LIVE_001.apk'));
      file.writeAsStringSync(content);

      final expectedHash = sha256.convert(content.codeUnits).toString();

      final checksumPath = await service.generateChecksum(file.path);

      expect(checksumPath, endsWith('.sha256'));
      
      final checksumFile = File(checksumPath);
      expect(checksumFile.existsSync(), isTrue);

      final generatedContent = checksumFile.readAsStringSync();
      final lines = generatedContent.trim().split('\n');
      
      expect(lines.length, equals(3));
      expect(lines[0], equals(expectedHash));
      expect(lines[1], equals('DriveReplay_20260724_LIVE_001.apk'));
      // Line 3 is the timestamp, just ensure it exists
      expect(lines[2], isNotEmpty);
    });

    test('generates correct checksum for a directory', () async {
      final dirPath = p.join(testDir, 'Runner.dSYM');
      final dir = Directory(dirPath);
      dir.createSync();
      
      File(p.join(dirPath, 'file1.txt')).writeAsStringSync('a');
      File(p.join(dirPath, 'file2.txt')).writeAsStringSync('b');

      final checksumPath = await service.generateChecksum(dirPath);
      expect(checksumPath, endsWith('Runner.dSYM.sha256'));
      
      final checksumFile = File(checksumPath);
      expect(checksumFile.existsSync(), isTrue);

      final generatedContent = checksumFile.readAsStringSync();
      final lines = generatedContent.trim().split('\n');
      
      expect(lines[0], isNotEmpty); // Hash is generated
      expect(lines[1], equals('Runner.dSYM'));
    });

    test('throws exception when artifact is not found', () async {
      final path = p.join(testDir, 'missing.apk');
      
      expect(
        () => service.generateChecksum(path),
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.message,
          'message',
          contains('Artifact not found'),
        )),
      );
    });
  });
}
