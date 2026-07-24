import 'dart:io';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_release_manager/services/build_service.dart';
import 'package:flutter_release_manager/services/process_service.dart';
import 'package:flutter_release_manager/services/flutter_sdk_service.dart';
import 'package:flutter_release_manager/models/flutter_sdk_info.dart';

class MockProcessService extends Mock implements ProcessService {}
class MockFlutterSdkService extends Mock implements FlutterSdkService {}

void main() {
  group('BuildService', () {
    late BuildService buildService;
    late MockProcessService mockProcessService;
    late MockFlutterSdkService mockFlutterSdkService;
    late String testDir;

    setUp(() {
      mockProcessService = MockProcessService();
      mockFlutterSdkService = MockFlutterSdkService();
      buildService = BuildService(
        processService: mockProcessService,
        flutterSdkService: mockFlutterSdkService,
      );
      
      final dir = Directory.systemTemp.createTempSync('build_service_test_');
      testDir = dir.path;
      
      // Navigate to temp dir so local file checks (pubspec/flutter_release.yaml) use this dir
      Directory.current = testDir;
    });

    tearDown(() {
      Directory.current = Directory.systemTemp;
      final dir = Directory(testDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    void setupValidEnvironment() {
      File('$testDir/pubspec.yaml').writeAsStringSync('name: test_app');
      File('$testDir/flutter_release.yaml').writeAsStringSync('release_manager:');
      
      when(() => mockFlutterSdkService.getSdkInfo())
          .thenAnswer((_) async => FlutterSdkInfo(
                executablePath: 'flutter',
                version: '3.30.0',
                channel: 'stable',
                dartVersion: '3.7.0',
                engineRevision: '12345',
                frameworkRevision: '12345',
              ));
    }

    test('fails if pubspec.yaml is missing', () async {
      final result = await buildService.executeBuild('apk');
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('pubspec.yaml not found'));
    });

    test('fails if flutter_release.yaml is missing', () async {
      File('$testDir/pubspec.yaml').writeAsStringSync('name: test_app');
      
      final result = await buildService.executeBuild('apk');
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('flutter_release.yaml not found'));
    });

    test('fails if Flutter validation fails', () async {
      File('$testDir/pubspec.yaml').writeAsStringSync('name: test_app');
      File('$testDir/flutter_release.yaml').writeAsStringSync('release_manager:');
      
      when(() => mockFlutterSdkService.getSdkInfo())
          .thenThrow(Exception('Command not found'));

      final result = await buildService.executeBuild('apk');
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Command not found'));
    });

    test('successfully builds apk and verifies artifact exists', () async {
      setupValidEnvironment();
      
      when(() => mockProcessService.run('flutter', ['build', 'apk']))
          .thenAnswer((_) async {
            return ProcessResult(0, 0, 'Build successful', '');
          });

      final result = await buildService.executeBuild('apk');
      
      expect(result.isSuccess, isTrue);
      expect(result.target, equals('apk'));
      verify(() => mockProcessService.run('flutter', ['build', 'apk'])).called(1);
    });

    test('successfully maps aab target to appbundle', () async {
      setupValidEnvironment();
      
      when(() => mockProcessService.run('flutter', ['build', 'appbundle']))
          .thenAnswer((_) async {
            return ProcessResult(0, 0, 'Build successful', '');
          });

      final result = await buildService.executeBuild('aab');
      
      expect(result.isSuccess, isTrue);
      verify(() => mockProcessService.run('flutter', ['build', 'appbundle'])).called(1);
    });

    test('handles build failures', () async {
      setupValidEnvironment();
      
      when(() => mockProcessService.run('flutter', ['build', 'ipa']))
          .thenAnswer((_) async => ProcessResult(0, 1, '', 'Compile error'));

      final result = await buildService.executeBuild('ipa');
      
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Compile error'));
    });
    
    test('passes flavor and env arguments correctly', () async {
      setupValidEnvironment();
      
      when(() => mockProcessService.run('flutter', ['build', 'apk', '--flavor', 'dev', '--dart-define=ENV=DEV']))
          .thenAnswer((_) async {
            return ProcessResult(0, 0, 'Build successful', '');
          });

      final result = await buildService.executeBuild('apk', flavor: 'dev', env: 'DEV');
      
      expect(result.isSuccess, isTrue);
      verify(() => mockProcessService.run('flutter', ['build', 'apk', '--flavor', 'dev', '--dart-define=ENV=DEV'])).called(1);
    });
  });
}
