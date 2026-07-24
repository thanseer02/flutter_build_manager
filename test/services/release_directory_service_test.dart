import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:flutter_release_manager/services/release_directory_service.dart';

void main() {
  group('ReleaseDirectoryService', () {
    late ReleaseDirectoryService service;
    late String testDir;

    setUp(() {
      service = ReleaseDirectoryService();
      final dir = Directory.systemTemp.createTempSync('release_dir_test_');
      testDir = dir.path;
    });

    tearDown(() {
      final dir = Directory(testDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('creates default directory structure when no config exists', () async {
      final path = await service.getReleaseDirectory(environment: 'LIVE', basePath: testDir);
      
      final now = DateTime.now();
      final dateStr = DateFormat('dd_MM_yyyy').format(now);
      
      final expectedPath = p.join(testDir, 'build', 'release', dateStr, 'LIVE');
      
      expect(path, equals(expectedPath));
      expect(Directory(path).existsSync(), isTrue);
    });

    test('uses custom output directory from config', () async {
      final configFile = File(p.join(testDir, 'flutter_release.yaml'));
      configFile.writeAsStringSync('''
release_manager:
  output_directory: custom_builds
''');

      final path = await service.getReleaseDirectory(environment: 'QA', basePath: testDir);
      
      expect(path, contains('custom_builds'));
      expect(Directory(path).existsSync(), isTrue);
    });

    test('disables year and month organization from config', () async {
      final configFile = File(p.join(testDir, 'flutter_release.yaml'));
      configFile.writeAsStringSync('''
release_manager:
  output_directory: my_releases
  organize_by:
    date: false
    environment: true
''');

      final path = await service.getReleaseDirectory(environment: 'STAGING', basePath: testDir);
      
      final expectedPath = p.join(testDir, 'my_releases', 'STAGING');
      
      expect(path, equals(expectedPath));
      expect(Directory(path).existsSync(), isTrue);
    });

    test('creates flat structure if all organization is false', () async {
      final configFile = File(p.join(testDir, 'flutter_release.yaml'));
      configFile.writeAsStringSync('''
release_manager:
  output_directory: flat_out
  organize_by:
    date: false
    environment: false
''');

      final path = await service.getReleaseDirectory(environment: 'DEV', basePath: testDir);
      
      final expectedPath = p.join(testDir, 'flat_out');
      
      expect(path, equals(expectedPath));
      expect(Directory(path).existsSync(), isTrue);
    });
  });
}
