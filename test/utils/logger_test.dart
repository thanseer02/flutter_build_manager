import 'package:flutter_release_manager/utils/logger.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  group('ReleaseManagerLogger', () {
    late MockLogger mockLogger;
    late ReleaseManagerLogger logger;

    setUp(() {
      mockLogger = MockLogger();
      logger = ReleaseManagerLogger(logger: mockLogger);
    });

    test('info calls logger.info', () {
      logger.info('message');
      verify(() => mockLogger.info('message')).called(1);
    });

    test('err calls logger.err', () {
      logger.err('error');
      verify(() => mockLogger.err('error')).called(1);
    });
  });
}
