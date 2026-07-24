import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_release_manager/commands/build_command.dart';
import 'package:flutter_release_manager/services/pipeline/release_pipeline_service.dart';

class MockReleasePipelineService extends Mock implements ReleasePipelineService {}

void main() {
  group('BuildCommand', () {
    late MockReleasePipelineService mockPipelineService;
    late BuildCommand command;

    setUp(() {
      mockPipelineService = MockReleasePipelineService();

      command = BuildCommand(
        pipelineService: mockPipelineService,
      );
    });

    test('name and description are correct', () {
      expect(command.name, equals('build'));
      expect(command.description, isNotEmpty);
    });
  });
}
