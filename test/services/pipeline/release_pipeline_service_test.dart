import 'dart:io';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_build_manager/utils/logger.dart';
import 'package:flutter_build_manager/services/pipeline/release_pipeline_service.dart';
import 'package:flutter_build_manager/services/project_service.dart';
import 'package:flutter_build_manager/services/version_service.dart';
import 'package:flutter_build_manager/services/environment/environment_service.dart';
import 'package:flutter_build_manager/services/build_counter_service.dart';
import 'package:flutter_build_manager/services/filename_template_service.dart';
import 'package:flutter_build_manager/services/build_service.dart';
import 'package:flutter_build_manager/services/artifacts/artifact_locator_service.dart';
import 'package:flutter_build_manager/services/artifacts/artifact_rename_service.dart';
import 'package:flutter_build_manager/services/release_directory_service.dart';
import 'package:flutter_build_manager/services/metadata_service.dart';
import 'package:flutter_build_manager/services/checksum_service.dart';
import 'package:flutter_build_manager/services/logger_service.dart';

import 'package:flutter_build_manager/models/project_model.dart';
import 'package:flutter_build_manager/models/version_model.dart';
import 'package:flutter_build_manager/models/environment_model.dart';
import 'package:flutter_build_manager/models/build_result_model.dart';
import 'package:flutter_build_manager/models/release_metadata_model.dart';

class MockReleaseManagerLogger extends Mock implements ReleaseManagerLogger {}
class MockProjectService extends Mock implements ProjectService {}
class MockVersionService extends Mock implements VersionService {}
class MockEnvironmentService extends Mock implements EnvironmentService {}
class MockBuildCounterService extends Mock implements BuildCounterService {}
class MockFilenameTemplateService extends Mock implements FilenameTemplateService {}
class MockBuildService extends Mock implements BuildService {}
class MockArtifactLocatorService extends Mock implements ArtifactLocatorService {}
class MockArtifactRenameService extends Mock implements ArtifactRenameService {}
class MockReleaseDirectoryService extends Mock implements ReleaseDirectoryService {}
class MockMetadataService extends Mock implements MetadataService {}
class MockChecksumService extends Mock implements ChecksumService {}
class MockLoggerService extends Mock implements LoggerService {}

void main() {
  setUpAll(() {
    registerFallbackValue(ReleaseMetadataModel(
      projectName: 'A',
      version: '1',
      flutterBuildNumber: '1',
      environment: 'E',
      counter: '1',
      generatedFilename: 'A.apk',
      artifactType: 'apk',
      artifactSize: 1,
      generatedTime: 't',
      flutterVersion: 'f',
      dartVersion: 'd',
      operatingSystem: 'o',
      releaseDirectory: 'd',
    ));
    registerFallbackValue(TemplateVariables(
      project: 'A',
      version: '1',
      flutterBuild: '1',
      counter: '1',
      env: 'E',
    ));
  });

  group('ReleasePipelineService', () {
    late ReleasePipelineService pipeline;
    late MockReleaseManagerLogger mockUiLogger;
    late MockProjectService mockProjectService;
    late MockVersionService mockVersionService;
    late MockEnvironmentService mockEnvironmentService;
    late MockBuildCounterService mockBuildCounterService;
    late MockFilenameTemplateService mockFilenameTemplateService;
    late MockBuildService mockBuildService;
    late MockArtifactLocatorService mockArtifactLocatorService;
    late MockArtifactRenameService mockArtifactRenameService;
    late MockReleaseDirectoryService mockReleaseDirectoryService;
    late MockMetadataService mockMetadataService;
    late MockChecksumService mockChecksumService;
    late MockLoggerService mockFileLogger;

    late String testDir;

    setUp(() {
      final dir = Directory.systemTemp.createTempSync('pipeline_test_');
      testDir = dir.path;

      mockUiLogger = MockReleaseManagerLogger();
      mockProjectService = MockProjectService();
      mockVersionService = MockVersionService();
      mockEnvironmentService = MockEnvironmentService();
      mockBuildCounterService = MockBuildCounterService();
      mockFilenameTemplateService = MockFilenameTemplateService();
      mockBuildService = MockBuildService();
      mockArtifactLocatorService = MockArtifactLocatorService();
      mockArtifactRenameService = MockArtifactRenameService();
      mockReleaseDirectoryService = MockReleaseDirectoryService();
      mockMetadataService = MockMetadataService();
      mockChecksumService = MockChecksumService();
      mockFileLogger = MockLoggerService();

      pipeline = ReleasePipelineService(
        uiLogger: mockUiLogger,
        projectService: mockProjectService,
        versionService: mockVersionService,
        environmentService: mockEnvironmentService,
        buildCounterService: mockBuildCounterService,
        filenameTemplateService: mockFilenameTemplateService,
        buildService: mockBuildService,
        artifactLocatorService: mockArtifactLocatorService,
        artifactRenameService: mockArtifactRenameService,
        releaseDirectoryService: mockReleaseDirectoryService,
        metadataService: mockMetadataService,
        checksumService: mockChecksumService,
        fileLogger: mockFileLogger,
      );

      when(() => mockUiLogger.info(any())).thenReturn(null);
      when(() => mockUiLogger.err(any())).thenReturn(null);
      when(() => mockUiLogger.success(any())).thenReturn(null);
      when(() => mockFileLogger.info(any())).thenAnswer((_) async {});
      when(() => mockFileLogger.error(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace'))).thenAnswer((_) async {});
      when(() => mockFileLogger.warning(any())).thenAnswer((_) async {});

      // Setup standard happy path returns
      when(() => mockProjectService.getProjectInfo()).thenAnswer((_) async => const ProjectModel(name: 'TestApp'));
      when(() => mockVersionService.getVersionInfo()).thenAnswer((_) async => const VersionModel(projectName: 'TestApp', version: '1.0', buildNumber: '1'));
      when(() => mockEnvironmentService.detectEnvironment(any())).thenAnswer((_) async => const EnvironmentModel('LIVE'));
      when(() => mockBuildCounterService.peekNextBuildNumber(any())).thenAnswer((_) async => '001');
      when(() => mockBuildCounterService.getNextBuildNumber(any())).thenAnswer((_) async => '001');
      when(() => mockFilenameTemplateService.generateFilename(any(), any())).thenReturn('TestApp_LIVE_001');
      
      when(() => mockBuildService.executeBuild(any(), flavor: any(named: 'flavor'), env: any(named: 'env')))
          .thenAnswer((_) async => const BuildResultModel(isSuccess: true, target: 'apk', buildDuration: Duration(seconds: 1)));
          
      when(() => mockArtifactLocatorService.locateArtifact(any(), flavor: any(named: 'flavor')))
          .thenAnswer((_) async => '/tmp/build/app/outputs/flutter-apk/app-release.apk');
          
      when(() => mockReleaseDirectoryService.getReleaseDirectory(environment: any(named: 'environment')))
          .thenAnswer((_) async => testDir);
          
      final fakeApk = File(p.join(testDir, 'TestApp_LIVE_001.apk'))..createSync();
      when(() => mockArtifactRenameService.renameArtifact(any(), any())).thenAnswer((_) async => fakeApk.path);
      
      when(() => mockMetadataService.generateMetadataFile(any())).thenAnswer((_) async => p.join(testDir, 'release.json'));
      when(() => mockChecksumService.generateChecksum(any())).thenAnswer((_) async => p.join(testDir, 'TestApp_LIVE_001.apk.sha256'));
    });

    tearDown(() {
      final dir = Directory(testDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('executes successful pipeline run and increments counter', () async {
      await pipeline.runPipeline(target: 'apk');
      
      verify(() => mockProjectService.getProjectInfo()).called(1);
      verify(() => mockBuildService.executeBuild('apk', flavor: null, env: null)).called(1);
      verify(() => mockArtifactRenameService.renameArtifact(any(), any())).called(1);
      
      // Verify counter was incremented
      verify(() => mockBuildCounterService.getNextBuildNumber('LIVE')).called(1);
      
      verify(() => mockUiLogger.success(any(that: contains('Release completed successfully')))).called(1);
    });

    test('rolls back moved files and does not increment counter if build fails', () async {
      when(() => mockBuildService.executeBuild(any(), flavor: any(named: 'flavor'), env: any(named: 'env')))
          .thenAnswer((_) async => const BuildResultModel(isSuccess: false, target: 'apk', buildDuration: Duration.zero, errorMessage: 'Crash'));

      await pipeline.runPipeline(target: 'apk');
      
      // Counter should only be peeked, never incremented
      verify(() => mockBuildCounterService.peekNextBuildNumber('LIVE')).called(1);
      verifyNever(() => mockBuildCounterService.getNextBuildNumber(any()));
      
      // Files should never have been moved because build failed early
      verifyNever(() => mockArtifactRenameService.renameArtifact(any(), any()));
      verify(() => mockUiLogger.err(any(that: contains('Pipeline Failed')))).called(1);
    });

    test('rolls back moved files if checksum generation fails later in pipeline', () async {
      // Simulate failure at the very last step (checksum)
      when(() => mockChecksumService.generateChecksum(any())).thenThrow(Exception('Checksum failed'));
      
      final fakeApk = File(p.join(testDir, 'TestApp_LIVE_001.apk'));

      await pipeline.runPipeline(target: 'apk');
      
      // Counter should NOT be incremented because we threw before phase 4
      verifyNever(() => mockBuildCounterService.getNextBuildNumber(any()));
      
      // Rollback should have been triggered, which calls f.deleteSync() internally.
      // We can verify that the file was deleted:
      expect(fakeApk.existsSync(), isFalse);
      
      verify(() => mockUiLogger.err(any(that: contains('Rolling back partial file movements')))).called(1);
    });
  });
}
