import 'package:args/args.dart';

/// Abstract base class for environment detection strategies.
abstract class EnvironmentDetectionStrategy {
  /// Returns a short name identifying the strategy (e.g., 'Manual Override').
  String get name;

  /// Attempts to detect the environment based on the strategy's rules.
  /// 
  /// Receives the parsed [argResults] which may contain command-line flags.
  /// Returns the environment string if detected, otherwise returns `null`.
  Future<String?> detect(ArgResults? argResults);
}
