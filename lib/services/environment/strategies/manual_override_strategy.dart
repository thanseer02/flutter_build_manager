import 'package:args/args.dart';
import '../environment_detection_strategy.dart';

/// Strategy to detect the environment from a manual CLI override flag (e.g., --env=STAGING).
class ManualOverrideStrategy implements EnvironmentDetectionStrategy {
  @override
  String get name => 'Manual Override';

  @override
  Future<String?> detect(ArgResults? argResults) async {
    if (argResults == null) return null;
    
    // Check if the generic 'env' option was passed
    if (argResults.options.contains('env') && argResults.wasParsed('env')) {
      return argResults['env'] as String?;
    }
    
    return null;
  }
}
