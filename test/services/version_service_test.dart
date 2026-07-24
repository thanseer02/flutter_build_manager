import 'dart:io';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_release_manager/services/version_service.dart';
import 'package:flutter_release_manager/utils/logger.dart';
import 'package:flutter_release_manager/exceptions/release_manager_exception.dart';
import 'package:flutter_release_manager/models/version_model.dart';

class MockLogger extends Mock implements ReleaseManagerLogger {}

void main() {
  group('VersionService', () {
    late MockLogger mockLogger;
    late VersionService versionService;
    late String testDir;
    
    setUp(() {
      mockLogger = MockLogger();
      versionService = VersionService(logger: mockLogger);
      
      // Create a temporary directory for tests
      final dir = Directory.systemTemp.createTempSync('version_service_test_');
      testDir = dir.path;
    });
    
    tearDown(() {
      // Clean up temporary directory
      final dir = Directory(testDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('extracts project name, version, and build number correctly', () async {
      final pubspecPath = '$testDir/pubspec.yaml';
      File(pubspecPath).writeAsStringSync('''
name: DriveReplay
description: A new Flutter project.
version: 2.4.1+35
''');

      final result = await versionService.getVersionInfo(pubspecPath: pubspecPath);

      expect(
        result,
        equals(const VersionModel(
          projectName: 'DriveReplay',
          version: '2.4.1',
          buildNumber: '35',
        )),
      );
    });

    test('extracts correctly when build number is missing', () async {
      final pubspecPath = '$testDir/pubspec.yaml';
      File(pubspecPath).writeAsStringSync('''
name: DriveReplay
version: 2.4.1
''');

      final result = await versionService.getVersionInfo(pubspecPath: pubspecPath);

      expect(
        result,
        equals(const VersionModel(
          projectName: 'DriveReplay',
          version: '2.4.1',
          buildNumber: '',
        )),
      );
    });

    test('throws exception when pubspec.yaml is missing', () async {
      expect(
        () => versionService.getVersionInfo(pubspecPath: '$testDir/non_existent.yaml'),
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.message,
          'message',
          contains('pubspec.yaml not found'),
        )),
      );
    });

    test('throws exception when name is missing', () async {
      final pubspecPath = '$testDir/pubspec.yaml';
      File(pubspecPath).writeAsStringSync('''
version: 2.4.1+35
''');

      expect(
        () => versionService.getVersionInfo(pubspecPath: pubspecPath),
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.message,
          'message',
          contains('Project name is missing'),
        )),
      );
    });

    test('throws exception when version is missing', () async {
      final pubspecPath = '$testDir/pubspec.yaml';
      File(pubspecPath).writeAsStringSync('''
name: DriveReplay
''');

      expect(
        () => versionService.getVersionInfo(pubspecPath: pubspecPath),
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.message,
          'message',
          contains('Version is missing'),
        )),
      );
    });

    test('throws exception when yaml is malformed', () async {
      final pubspecPath = '$testDir/pubspec.yaml';
      File(pubspecPath).writeAsStringSync('''
name: DriveReplay
  version: 2.4.1+35
 - invalid: yaml: syntax: [
''');

      expect(
        () => versionService.getVersionInfo(pubspecPath: pubspecPath),
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.message,
          'message',
          contains('Failed to parse pubspec.yaml safely'),
        )),
      );
    });
  });
}
