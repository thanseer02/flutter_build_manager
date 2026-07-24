import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:intl/intl.dart';

/// Service responsible for constructing and creating the final release directory structure.
class ReleaseDirectoryService {
  final String _configPath;

  ReleaseDirectoryService({String configPath = 'flutter_build_manager.yaml'})
      : _configPath = configPath;

  /// Determines the release directory path based on configuration and current environment.
  /// 
  /// By default, reads `output_directory` and `organize_by` from `flutter_build_manager.yaml`.
  /// Creates the directory on disk if it does not exist.
  Future<String> getReleaseDirectory({required String environment, String? basePath}) async {
    final root = basePath ?? Directory.current.path;
    String baseOutputDir = p.join('build', 'release');
    
    bool orgDate = true;
    bool orgEnv = true;

    final file = File(p.join(root, _configPath));
    if (file.existsSync()) {
      try {
        final content = await file.readAsString();
        final doc = loadYaml(content);
        if (doc is YamlMap && doc['release_manager'] is YamlMap) {
          final rm = doc['release_manager'];
          
          if (rm['output_directory'] != null) {
            baseOutputDir = rm['output_directory'].toString();
          }

          if (rm['organize_by'] is YamlMap) {
            final org = rm['organize_by'];
            orgDate = org['date'] ?? true;
            orgEnv = org['environment'] ?? true;
          }
        }
      } catch (_) {
        // Fall back to defaults on parsing error
      }
    }

    final now = DateTime.now();
    final pathSegments = <String>[baseOutputDir];

    if (orgDate) {
      pathSegments.add(DateFormat('dd_MM_yyyy').format(now));
    }
    
    if (orgEnv) {
      pathSegments.add(environment);
    }

    final fullPath = p.joinAll([root, ...pathSegments]);
    
    final dir = Directory(fullPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    return dir.absolute.path;
  }
}
