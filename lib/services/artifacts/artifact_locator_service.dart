import 'package:flutter_release_manager/exceptions/release_manager_exception.dart';
import 'artifact_locator_strategy.dart';
import 'strategies/aab_locator_strategy.dart';
import 'strategies/apk_locator_strategy.dart';
import 'strategies/dsym_locator_strategy.dart';
import 'strategies/ipa_locator_strategy.dart';
import 'strategies/mapping_locator_strategy.dart';
import 'strategies/symbols_locator_strategy.dart';

/// Service responsible for locating generated build artifacts.
class ArtifactLocatorService {
  late final Map<String, ArtifactLocatorStrategy> _strategies;

  /// Creates a new [ArtifactLocatorService].
  ArtifactLocatorService({List<ArtifactLocatorStrategy>? customStrategies}) {
    final defaultStrategies = [
      ApkLocatorStrategy(),
      AabLocatorStrategy(),
      IpaLocatorStrategy(),
      MappingLocatorStrategy(),
      DsymLocatorStrategy(),
      SymbolsLocatorStrategy(),
    ];

    _strategies = {
      for (final strategy in [...defaultStrategies, ...?customStrategies])
        strategy.artifactType.toLowerCase(): strategy
    };
  }

  /// Attempts to locate an artifact of the given [type].
  /// 
  /// Throws a [ReleaseManagerException] with helpful hints if the artifact
  /// cannot be found.
  Future<String> locateArtifact(String type, {String? flavor, String? basePath}) async {
    final typeKey = type.toLowerCase();
    final strategy = _strategies[typeKey];

    if (strategy == null) {
      throw ReleaseManagerException(
        'Artifact locator not found for type: $type',
        details: 'Supported types are: ${_strategies.keys.join(', ')}.\n'
            'To support a new type, implement ArtifactLocatorStrategy and register it.',
      );
    }

    final path = await strategy.locate(flavor: flavor, basePath: basePath);

    if (path == null) {
      throw ReleaseManagerException(
        'Could not locate $type artifact.',
        details: 'The $type artifact was not found in its standard output directory.\n'
            '- Did the build fail silently?\n'
            '- Are you using a non-standard build directory?\n'
            '- If building with flavors, ensure the flavor name ($flavor) is correct.',
      );
    }

    return path;
  }
}
