import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:intl/intl.dart';

/// Service responsible for constructing and creating the final release directory structure.
class ReleaseDirectoryService {
  final String _configPath;

  ReleaseDirectoryService({String configPath = 'flutter_release.yaml'})
      : _configPath = configPath;

  /// Determines the release directory path based on configuration and current environment.
  /// 
  /// By default, reads `output_directory` and `organize_by` from `flutter_release.yaml`.
  /// Creates the directory on disk if it does not exist.
  Future<String> getReleaseDirectory({required String environment, String? basePath}) async {
    final root = basePath ?? Directory.current.path;
    String baseOutputDir = 'release';
    
    bool orgYear = true;
    bool orgMonth = true;
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
            orgYear = org['year'] == true;
            orgMonth = org['month'] == true;
            orgEnv = org['environment'] == true;
          }
        }
      } catch (_) {
        // Fall back to defaults on parsing error
      }
    }

    final now = DateTime.now();
    final pathSegments = <String>[baseOutputDir];

    if (orgYear) {
      pathSegments.add(DateFormat('yyyy').format(now));
    }
    
    if (orgMonth) {
      pathSegments.add(DateFormat('MMMM').format(now));
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
