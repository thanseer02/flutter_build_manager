import 'dart:io';
import 'package:test/test.dart';
import 'package:flutter_build_manager/services/project_service.dart';
import 'package:flutter_build_manager/exceptions/release_manager_exception.dart';
import 'package:flutter_build_manager/models/project_model.dart';

void main() {
  group('ProjectService', () {
    late ProjectService projectService;
    late String testDir;
    
    setUp(() {
      projectService = ProjectService();
      
      // Create a temporary directory for tests
      final dir = Directory.systemTemp.createTempSync('project_service_test_');
      testDir = dir.path;
    });
    
    tearDown(() {
      // Clean up temporary directory
      final dir = Directory(testDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('extracts project name correctly', () async {
      final pubspecPath = '$testDir/pubspec.yaml';
      File(pubspecPath).writeAsStringSync('''
name: drive_replay
description: A new Flutter project.
''');

      final result = await projectService.getProjectInfo(pubspecPath: pubspecPath);

      expect(
        result,
        equals(const ProjectModel(name: 'drive_replay')),
      );
      
      // Test the toString override
      expect(result.toString(), equals('drive_replay'));
    });

    test('throws exception when pubspec.yaml is missing', () async {
      expect(
        () => projectService.getProjectInfo(pubspecPath: '$testDir/non_existent.yaml'),
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
description: A new Flutter project.
''');

      expect(
        () => projectService.getProjectInfo(pubspecPath: pubspecPath),
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.message,
          'message',
          contains('Project name is missing'),
        )),
      );
    });

    test('throws exception when yaml is malformed', () async {
      final pubspecPath = '$testDir/pubspec.yaml';
      File(pubspecPath).writeAsStringSync('''
name: drive_replay
 - invalid: yaml: syntax: [
''');

      expect(
        () => projectService.getProjectInfo(pubspecPath: pubspecPath),
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.message,
          'message',
          contains('Failed to parse pubspec.yaml safely'),
        )),
      );
    });
  });
}
