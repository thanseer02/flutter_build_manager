import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_release_manager/services/metadata_service.dart';
import 'package:flutter_release_manager/models/release_metadata_model.dart';
import 'package:flutter_release_manager/exceptions/release_manager_exception.dart';

void main() {
  group('MetadataService', () {
    late MetadataService service;
    late String testDir;

    setUp(() {
      service = MetadataService();
      final dir = Directory.systemTemp.createTempSync('metadata_service_test_');
      testDir = dir.path;
    });

    tearDown(() {
      final dir = Directory(testDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    ReleaseMetadataModel createValidMetadata() {
      return ReleaseMetadataModel(
        projectName: 'TestApp',
        version: '1.0.0',
        flutterBuildNumber: '42',
        environment: 'LIVE',
        counter: '001',
        generatedFilename: 'TestApp_LIVE_001.apk',
        artifactType: 'apk',
        artifactSize: 1024500,
        generatedTime: '2026-07-24T12:00:00Z',
        flutterVersion: '3.30.0',
        dartVersion: '3.6.0',
        operatingSystem: 'macos',
        releaseDirectory: testDir,
      );
    }

    test('generates properly indented JSON file', () async {
      final metadata = createValidMetadata();
      final filePath = await service.generateMetadataFile(metadata);
      
      expect(filePath, equals(p.join(testDir, 'release.json')));
      
      final file = File(filePath);
      expect(file.existsSync(), isTrue);
      
      final content = file.readAsStringSync();
      
      // Check indentation format
      expect(content, startsWith('{\n  "projectName": "TestApp",'));
      
      // Ensure it parses correctly
      final jsonMap = json.decode(content);
      expect(jsonMap['projectName'], equals('TestApp'));
      expect(jsonMap['artifactSize'], equals(1024500));
    });

    test('throws exception if project name is empty', () async {
      final metadata = ReleaseMetadataModel(
        projectName: '', // Invalid
        version: '1.0.0',
        flutterBuildNumber: '42',
        environment: 'LIVE',
        counter: '001',
        generatedFilename: 'TestApp_LIVE_001.apk',
        artifactType: 'apk',
        artifactSize: 1024500,
        generatedTime: '2026-07-24T12:00:00Z',
        flutterVersion: '3.30.0',
        dartVersion: '3.6.0',
        operatingSystem: 'macos',
        releaseDirectory: testDir,
      );

      expect(
        () => service.generateMetadataFile(metadata),
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.message,
          'message',
          contains('Project Name is empty'),
        )),
      );
    });

    test('throws exception if artifact size is negative', () async {
      final metadata = ReleaseMetadataModel(
        projectName: 'App',
        version: '1.0.0',
        flutterBuildNumber: '42',
        environment: 'LIVE',
        counter: '001',
        generatedFilename: 'TestApp_LIVE_001.apk',
        artifactType: 'apk',
        artifactSize: -5, // Invalid
        generatedTime: '2026-07-24T12:00:00Z',
        flutterVersion: '3.30.0',
        dartVersion: '3.6.0',
        operatingSystem: 'macos',
        releaseDirectory: testDir,
      );

      expect(
        () => service.generateMetadataFile(metadata),
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.message,
          'message',
          contains('Artifact Size cannot be negative'),
        )),
      );
    });
  });
}
