import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_build_manager/services/artifacts/artifact_rename_service.dart';
import 'package:flutter_build_manager/exceptions/release_manager_exception.dart';

void main() {
  group('ArtifactRenameService', () {
    late ArtifactRenameService service;
    late String testDir;

    setUp(() {
      service = ArtifactRenameService();
      final dir = Directory.systemTemp.createTempSync('artifact_rename_test_');
      testDir = dir.path;
    });

    tearDown(() {
      final dir = Directory(testDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('renames a file correctly', () async {
      final sourceFile = File(p.join(testDir, 'source.apk'));
      sourceFile.writeAsStringSync('mock apk content');

      final targetPath = p.join(testDir, 'release', 'target.apk');
      
      final finalPath = await service.renameArtifact(sourceFile.path, targetPath);
      
      expect(finalPath, equals(targetPath));
      expect(File(finalPath).existsSync(), isTrue);
      expect(File(sourceFile.path).existsSync(), isFalse);
    });

    test('appends _2 if target file already exists', () async {
      final sourceFile = File(p.join(testDir, 'source.apk'));
      sourceFile.writeAsStringSync('new content');

      final targetPath = p.join(testDir, 'release', 'target.apk');
      
      // Create the file so it already exists
      final existingFile = File(targetPath);
      existingFile.parent.createSync(recursive: true);
      existingFile.writeAsStringSync('old content');
      
      final finalPath = await service.renameArtifact(sourceFile.path, targetPath);
      
      expect(finalPath, equals(p.join(testDir, 'release', 'target_2.apk')));
      expect(File(finalPath).existsSync(), isTrue);
      expect(File(finalPath).readAsStringSync(), equals('new content'));
      
      // Original target should be untouched
      expect(existingFile.existsSync(), isTrue);
      expect(existingFile.readAsStringSync(), equals('old content'));
    });

    test('appends _3 if _2 already exists', () async {
      final sourceFile = File(p.join(testDir, 'source.apk'));
      sourceFile.writeAsStringSync('new content');

      final targetPath = p.join(testDir, 'release', 'target.apk');
      
      File(targetPath).parent.createSync(recursive: true);
      File(targetPath).writeAsStringSync('old');
      File(p.join(testDir, 'release', 'target_2.apk')).writeAsStringSync('old 2');
      
      final finalPath = await service.renameArtifact(sourceFile.path, targetPath);
      
      expect(finalPath, equals(p.join(testDir, 'release', 'target_3.apk')));
      expect(File(finalPath).existsSync(), isTrue);
    });

    test('renames directories correctly (like dSYMs)', () async {
      final sourceDir = Directory(p.join(testDir, 'Runner.app.dSYM'));
      sourceDir.createSync();
      File(p.join(sourceDir.path, 'content.txt')).writeAsStringSync('symbol data');

      final targetPath = p.join(testDir, 'release', 'DriveReplay.dSYM');
      
      final finalPath = await service.renameArtifact(sourceDir.path, targetPath);
      
      expect(finalPath, equals(targetPath));
      expect(Directory(finalPath).existsSync(), isTrue);
      expect(File(p.join(finalPath, 'content.txt')).existsSync(), isTrue);
      expect(sourceDir.existsSync(), isFalse);
    });

    test('throws exception if source file does not exist', () async {
      final targetPath = p.join(testDir, 'target.apk');
      
      expect(
        () => service.renameArtifact(p.join(testDir, 'missing.apk'), targetPath),
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.message,
          'message',
          contains('Source artifact does not exist'),
        )),
      );
    });
  });
}
