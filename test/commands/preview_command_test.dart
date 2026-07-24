import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:args/command_runner.dart';
import 'package:args/args.dart';

import 'package:flutter_release_manager/commands/preview_command.dart';
import 'package:flutter_release_manager/utils/logger.dart';
import 'package:flutter_release_manager/services/project_service.dart';
import 'package:flutter_release_manager/services/version_service.dart';
import 'package:flutter_release_manager/services/environment/environment_service.dart';
import 'package:flutter_release_manager/services/build_counter_service.dart';
import 'package:flutter_release_manager/services/filename_template_service.dart';
import 'package:flutter_release_manager/models/project_model.dart';
import 'package:flutter_release_manager/models/version_model.dart';
import 'package:flutter_release_manager/models/environment_model.dart';

class MockLogger extends Mock implements ReleaseManagerLogger {}
class MockProjectService extends Mock implements ProjectService {}
class MockVersionService extends Mock implements VersionService {}
class MockEnvironmentService extends Mock implements EnvironmentService {}
class MockBuildCounterService extends Mock implements BuildCounterService {}
class MockFilenameTemplateService extends Mock implements FilenameTemplateService {}

void main() {
  group('PreviewCommand', () {
    late MockLogger mockLogger;
    late MockProjectService mockProjectService;
    late MockVersionService mockVersionService;
    late MockEnvironmentService mockEnvironmentService;
    late MockBuildCounterService mockBuildCounterService;
    late MockFilenameTemplateService mockFilenameTemplateService;
    late CommandRunner<int> runner;

    setUp(() {
      mockLogger = MockLogger();
      mockProjectService = MockProjectService();
      mockVersionService = MockVersionService();
      mockEnvironmentService = MockEnvironmentService();
      mockBuildCounterService = MockBuildCounterService();
      mockFilenameTemplateService = MockFilenameTemplateService();

      when(() => mockLogger.info(any())).thenReturn(null);
      when(() => mockLogger.err(any())).thenReturn(null);

      final command = PreviewCommand(
        logger: mockLogger,
        projectService: mockProjectService,
        versionService: mockVersionService,
        environmentService: mockEnvironmentService,
        buildCounterService: mockBuildCounterService,
        filenameTemplateService: mockFilenameTemplateService,
      );

      runner = CommandRunner<int>('test', 'test runner')..addCommand(command);
    });

    test('successfully outputs formatted preview data', () async {
      when(() => mockProjectService.getProjectInfo()).thenAnswer(
        (_) async => const ProjectModel(name: 'DriveReplay'),
      );
      when(() => mockVersionService.getVersionInfo()).thenAnswer(
        (_) async => const VersionModel(projectName: 'DriveReplay', version: '2.4.1', buildNumber: '35'),
      );
      when(() => mockEnvironmentService.detectEnvironment(any())).thenAnswer(
        (_) async => const EnvironmentModel('LIVE'),
      );
      when(() => mockBuildCounterService.peekNextBuildNumber('LIVE')).thenAnswer(
        (_) async => '014',
      );
      when(() => mockFilenameTemplateService.generateFilename(any(), any())).thenReturn(
        'DriveReplay_20260724_LIVE_014',
      );

      final result = await runner.run(['preview']);

      expect(result, equals(0));
      
      verify(() => mockLogger.info(any(that: contains('Project : DriveReplay')))).called(1);
      verify(() => mockLogger.info(any(that: contains('Version : 2.4.1')))).called(1);
      verify(() => mockLogger.info(any(that: contains('Environment : LIVE')))).called(1);
      verify(() => mockLogger.info(any(that: contains('Counter : 014')))).called(1);
      verify(() => mockLogger.info(any(that: contains('DriveReplay_20260724_LIVE_014.apk')))).called(1);
      
      // Ensure it peeks instead of increments
      verify(() => mockBuildCounterService.peekNextBuildNumber('LIVE')).called(1);
      verifyNever(() => mockBuildCounterService.getNextBuildNumber(any()));
    });
  });
}
