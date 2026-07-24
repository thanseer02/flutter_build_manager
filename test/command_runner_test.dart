import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_release_manager/src/command_runner.dart';
import 'package:flutter_release_manager/src/core/logger.dart';

class MockLogger extends Mock implements AppLogger {}

void main() {
  group('ReleaseCommandRunner', () {
    late MockLogger mockLogger;
    late ReleaseCommandRunner runner;

    setUp(() {
      mockLogger = MockLogger();
      runner = ReleaseCommandRunner(logger: mockLogger);
    });

    test('can be instantiated', () {
      expect(runner, isNotNull);
    });

    test('run with no arguments returns usage exit code', () async {
      final exitCode = await runner.run([]);
      expect(exitCode, equals(0)); // Depending on behavior, args might default to printing usage and returning 0
    });

    test('run with --help flag prints usage', () async {
      when(() => mockLogger.info(any())).thenReturn(null);
      
      final exitCode = await runner.run(['--help']);
      
      verify(() => mockLogger.info(any())).called(greaterThan(0)); // Usually prints usage to stdout
      expect(exitCode, equals(0));
    });
  });
}
