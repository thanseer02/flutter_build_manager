import 'package:args/args.dart';
import '../logging/logger.dart';

/// Abstract base class for defining extensibility points (Plugins).
///
/// Any future extensions to the flutter_release_manager should implement
/// this interface and register themselves with the CLI.
abstract class ReleasePlugin {
  /// The unique name of the plugin.
  String get name;

  /// A brief description of what the plugin does.
  String get description;

  /// Initialize the plugin with any necessary setup before execution.
  /// 
  /// The [logger] is provided so the plugin can output information uniformly.
  Future<void> initialize(ReleaseManagerLogger logger);

  /// Registers any custom command-line arguments needed by this plugin.
  void registerArguments(ArgParser argParser);

  /// Executes the core logic of the plugin using the parsed [results].
  Future<void> execute(ArgResults results);
}
