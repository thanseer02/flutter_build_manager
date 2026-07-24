import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_release_manager/commands/release_manager_runner.dart';
import 'package:flutter_release_manager/utils/logger.dart';
import 'package:flutter_release_manager/services/process_service.dart';

class MockLogger extends Mock implements ReleaseManagerLogger {}
class MockProcessService extends Mock implements ProcessService {}

void main() {
  group('ReleaseManagerRunner', () {
    late MockLogger mockLogger;
    late MockProcessService mockProcessService;
    late ReleaseManagerRunner runner;

    setUp(() {
      mockLogger = MockLogger();
      mockProcessService = MockProcessService();
      runner = ReleaseManagerRunner(
        logger: mockLogger,
        processService: mockProcessService,
      );
    });

    test('can be instantiated', () {
      expect(runner, isNotNull);
    });
  });
}
