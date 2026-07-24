import 'package:args/args.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_build_manager/services/environment/environment_service.dart';
import 'package:flutter_build_manager/services/environment/environment_detection_strategy.dart';
import 'package:flutter_build_manager/models/environment_model.dart';
import 'package:flutter_build_manager/exceptions/release_manager_exception.dart';
import 'package:flutter_build_manager/utils/logger.dart';

class MockLogger extends Mock implements ReleaseManagerLogger {}
class MockArgResults extends Mock implements ArgResults {}
class MockStrategy extends Mock implements EnvironmentDetectionStrategy {}

void main() {
  group('EnvironmentService', () {
    late MockLogger mockLogger;
    late MockArgResults mockArgResults;

    setUp(() {
      mockLogger = MockLogger();
      mockArgResults = MockArgResults();
      when(() => mockLogger.detail(any())).thenReturn(null);
    });

    test('returns environment from first successful strategy', () async {
      final strategy1 = MockStrategy();
      when(() => strategy1.name).thenReturn('S1');
      when(() => strategy1.detect(any())).thenAnswer((_) async => null);

      final strategy2 = MockStrategy();
      when(() => strategy2.name).thenReturn('S2');
      when(() => strategy2.detect(any())).thenAnswer((_) async => 'UAT');

      final strategy3 = MockStrategy(); // Should not be called
      when(() => strategy3.name).thenReturn('S3');
      when(() => strategy3.detect(any())).thenAnswer((_) async => 'PROD');

      final service = EnvironmentService(
        logger: mockLogger,
        strategies: [strategy1, strategy2, strategy3],
      );

      final result = await service.detectEnvironment(mockArgResults);

      expect(result, equals(const EnvironmentModel('UAT')));
      verify(() => strategy1.detect(mockArgResults)).called(1);
      verify(() => strategy2.detect(mockArgResults)).called(1);
      verifyNever(() => strategy3.detect(mockArgResults));
    });

    test('throws ReleaseManagerException when all strategies fail', () async {
      final strategy1 = MockStrategy();
      when(() => strategy1.detect(any())).thenAnswer((_) async => null);

      final service = EnvironmentService(
        logger: mockLogger,
        strategies: [strategy1],
      );

      expect(
        () => service.detectEnvironment(mockArgResults),
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.details,
          'details',
          contains('provide the environment manually'),
        )),
      );
    });
  });
}
