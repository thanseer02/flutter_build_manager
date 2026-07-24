/// Interfaces and base classes for extendability.
library flutter_release_manager.plugins;

import '../core/logger.dart';

/// Base interface for a plugin/extension in flutter_release_manager.
/// This allows the CLI to support future plugins (e.g., custom deployers, 
/// notifications, fastlane integrations) without modifying the core structure.
abstract class ReleasePlugin {
  /// The unique identifier or name of the plugin.
  String get name;

  /// The description of what the plugin does.
  String get description;

  /// Initializes the plugin with any necessary configuration.
  /// [logger] is provided for outputting information to the user.
  Future<void> initialize(AppLogger logger);

  /// Executes the core logic of the plugin.
  Future<void> execute(AppLogger logger);
}
