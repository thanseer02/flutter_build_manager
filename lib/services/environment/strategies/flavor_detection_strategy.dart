import 'package:args/args.dart';
import 'package:flutter_release_manager/services/environment/environment_detection_strategy.dart';

/// Strategy to detect the environment from the flutter --flavor flag.
class FlavorDetectionStrategy implements EnvironmentDetectionStrategy {
  @override
  String get name => 'Flutter Flavor';

  @override
  Future<String?> detect(ArgResults? argResults) async {
    if (argResults == null) return null;
    
    if (argResults.options.contains('flavor') && argResults.wasParsed('flavor')) {
      return argResults['flavor'] as String?;
    }
    
    return null;
  }
}
