import 'dart:io';
import 'package:test/test.dart';

import 'package:flutter_release_manager/services/artifacts/artifact_locator_service.dart';
import 'package:flutter_release_manager/services/artifacts/artifact_locator_strategy.dart';
import 'package:flutter_release_manager/exceptions/release_manager_exception.dart';

class MockCustomLocator implements ArtifactLocatorStrategy {
  @override
  String get artifactType => 'custom';

  @override
  Future<String?> locate({String? flavor, String? basePath}) async {
    final root = basePath ?? Directory.current.path;
    final file = File('$root/custom/file.txt');
    if (file.existsSync()) {
      return file.absolute.path;
    }
    return null;
  }
}

void main() {
  group('ArtifactLocatorService', () {
    late ArtifactLocatorService service;
    late String testDir;

    setUp(() {
      service = ArtifactLocatorService(customStrategies: [MockCustomLocator()]);
      
      final dir = Directory.systemTemp.createTempSync('artifact_locator_test_');
      testDir = dir.path;
    });

    tearDown(() {
      final dir = Directory(testDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('locates apk without flavor', () async {
      final file = File('$testDir/build/app/outputs/flutter-apk/app-release.apk');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('mock');

      final path = await service.locateArtifact('apk', basePath: testDir);
      expect(path, equals(file.absolute.path));
    });

    test('locates apk with flavor', () async {
      final file = File('$testDir/build/app/outputs/flutter-apk/app-dev-release.apk');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('mock');

      final path = await service.locateArtifact('apk', flavor: 'dev', basePath: testDir);
      expect(path, equals(file.absolute.path));
    });

    test('locates mapping.txt', () async {
      final file = File('$testDir/build/app/outputs/mapping/release/mapping.txt');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('mock');

      final path = await service.locateArtifact('mapping.txt', basePath: testDir);
      expect(path, equals(file.absolute.path));
    });

    test('locates custom artifact via injected strategy', () async {
      final file = File('$testDir/custom/file.txt');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('mock');

      final path = await service.locateArtifact('custom', basePath: testDir);
      expect(path, equals(file.absolute.path));
    });

    test('throws exception for unknown artifact type', () async {
      expect(
        () => service.locateArtifact('unknown_type', basePath: testDir),
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.message,
          'message',
          contains('not found for type: unknown_type'),
        )),
      );
    });

    test('throws exception when artifact does not exist', () async {
      expect(
        () => service.locateArtifact('apk', basePath: testDir), // file not created
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.message,
          'message',
          contains('Could not locate apk artifact'),
        )),
      );
    });
  });
}
