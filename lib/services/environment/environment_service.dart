import 'package:args/args.dart';

import 'package:flutter_release_manager/exceptions/release_manager_exception.dart';
import 'package:flutter_release_manager/models/environment_model.dart';
import 'package:flutter_release_manager/utils/logger.dart';
import 'environment_detection_strategy.dart';

import 'strategies/dart_define_detection_strategy.dart';
import 'strategies/flavor_detection_strategy.dart';
import 'strategies/manual_override_strategy.dart';
import 'strategies/yaml_config_detection_strategy.dart';

/// Service responsible for automatically determining the application's environment.
class EnvironmentService {
  final ReleaseManagerLogger _logger;
  
  /// The ordered list of detection strategies.
  final List<EnvironmentDetectionStrategy> _strategies;

  /// Creates a new [EnvironmentService].
  ///
  /// If no [strategies] are provided, it defaults to the priority order:
  /// 1. Manual Override (--env)
  /// 2. Flutter Flavor (--flavor)
  /// 3. Dart Defines (--dart-define=ENV=...)
  /// 4. Yaml Config fallback
  EnvironmentService({
    required ReleaseManagerLogger logger,
    List<EnvironmentDetectionStrategy>? strategies,
  })  : _logger = logger,
        _strategies = strategies ?? [
          ManualOverrideStrategy(),
          FlavorDetectionStrategy(),
          DartDefineDetectionStrategy(),
          YamlConfigDetectionStrategy(),
        ];

  /// Iterates through the detection strategies in order.
  /// 
  /// Returns the first non-null environment detected.
  /// Throws a detailed [ReleaseManagerException] if all strategies fail.
  Future<EnvironmentModel> detectEnvironment(ArgResults? argResults) async {
    for (final strategy in _strategies) {
      final result = await strategy.detect(argResults);
      if (result != null && result.isNotEmpty) {
        _logger.detail('Environment detected via ${strategy.name}: $result');
        return EnvironmentModel(result);
      }
    }

    // If we reach here, all strategies failed.
    throw const ReleaseManagerException(
      'Could not automatically detect the build environment.',
      details: 'No environment could be resolved from flags or configurations.\n\n'
          'To fix this, please provide the environment manually using one of the following methods:\n'
          '  1. Pass the --env flag: flutter_release build --env=STAGING\n'
          '  2. Provide a flavor: --flavor=dev\n'
          '  3. Use dart defines: --dart-define=ENV=PROD\n'
          '  4. Specify a fallback in flutter_release.yaml under release_manager > environment > source.',
    );
  }
}
