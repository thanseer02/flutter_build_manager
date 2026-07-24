import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_release_manager/src/commands/build_command.dart';
import 'package:flutter_release_manager/src/core/logger.dart';
import 'package:mason_logger/mason_logger.dart';

class MockLogger extends Mock implements AppLogger {}
class MockProgress extends Mock implements Progress {}

void main() {
  group('BuildCommand', () {
    late MockLogger mockLogger;
    late MockProgress mockProgress;
    late BuildCommand command;

    setUp(() {
      mockLogger = MockLogger();
      mockProgress = MockProgress();
      
      when(() => mockLogger.info(any())).thenReturn(null);
      when(() => mockLogger.progress(any())).thenReturn(mockProgress);
      when(() => mockProgress.complete(any())).thenReturn(null);
      when(() => mockProgress.fail(any())).thenReturn(null);

      command = BuildCommand(logger: mockLogger);
    });

    test('name and description are correct', () {
      expect(command.name, equals('build'));
      expect(command.description, isNotEmpty);
    });
  });
}
