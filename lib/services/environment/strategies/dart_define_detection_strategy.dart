import 'package:args/args.dart';
import '../environment_detection_strategy.dart';

/// Strategy to detect the environment from --dart-define=ENV=...
class DartDefineDetectionStrategy implements EnvironmentDetectionStrategy {
  @override
  String get name => 'Dart Define';

  @override
  Future<String?> detect(ArgResults? argResults) async {
    if (argResults == null) return null;
    
    if (argResults.options.contains('dart-define') && argResults.wasParsed('dart-define')) {
      final defines = argResults['dart-define'];
      
      // dart-define can be passed multiple times, creating a List<String>
      if (defines is List<String>) {
        for (final define in defines) {
          if (define.startsWith('ENV=')) {
            return define.substring(4); // Remove 'ENV='
          }
        }
      } else if (defines is String) {
        if (defines.startsWith('ENV=')) {
          return defines.substring(4);
        }
      }
    }
    
    return null;
  }
}
