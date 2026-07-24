import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_release_manager/commands/build_command.dart';
import 'package:flutter_release_manager/utils/logger.dart';
import 'package:flutter_release_manager/services/process_service.dart';

class MockLogger extends Mock implements ReleaseManagerLogger {}
class MockProcessService extends Mock implements ProcessService {}

void main() {
  group('BuildCommand', () {
    late MockLogger mockLogger;
    late MockProcessService mockProcessService;
    late BuildCommand command;

    setUp(() {
      mockLogger = MockLogger();
      mockProcessService = MockProcessService();
      
      when(() => mockLogger.info(any())).thenReturn(null);
      when(() => mockLogger.success(any())).thenReturn(null);
      when(() => mockLogger.err(any())).thenReturn(null);

      command = BuildCommand(
        logger: mockLogger,
        processService: mockProcessService,
      );
    });

    test('name and description are correct', () {
      expect(command.name, equals('build'));
      expect(command.description, isNotEmpty);
    });
  });
}
