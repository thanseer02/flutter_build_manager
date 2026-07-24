import 'package:intl/intl.dart';
import 'package:flutter_build_manager/exceptions/release_manager_exception.dart';

/// The variables that can be injected into a filename template.
class TemplateVariables {
  final String? project;
  final String? version;
  final String? flutterBuild;
  final String? counter;
  final String? env;
  final String? platform;
  final String? artifact;
  final String? branch;
  final String? commit;

  const TemplateVariables({
    this.project,
    this.version,
    this.flutterBuild,
    this.counter,
    this.env,
    this.platform,
    this.artifact,
    this.branch,
    this.commit,
  });
}

/// Service responsible for generating release filenames based on a template.
class FilenameTemplateService {
  static const List<String> _allowedPlaceholders = [
    'project', 'version', 'flutter_build', 'counter',
    'date', 'time', 'datetime', 'env', 'platform',
    'artifact', 'branch', 'commit', 'year', 'month', 'day'
  ];

  /// Generates a validated filename based on the [template] and [variables].
  /// 
  /// Throws [ReleaseManagerException] if unknown placeholders are used.
  /// Automatically sanitizes illegal filesystem characters.
  String generateFilename(String template, TemplateVariables variables) {
    _validateTemplate(template);

    final now = DateTime.now();
    
    // Map placeholders to their computed values
    final Map<String, String> replacements = {
      'project': variables.project ?? 'unknown',
      'version': variables.version ?? '0.0.0',
      'flutter_build': variables.flutterBuild ?? '0',
      'counter': variables.counter ?? '001',
      'env': variables.env ?? 'LOCAL',
      'platform': variables.platform ?? 'generic',
      'artifact': variables.artifact ?? 'bin',
      'branch': variables.branch ?? 'main',
      'commit': variables.commit ?? '0000000',
      'date': DateFormat('yyyyMMdd').format(now),
      'time': DateFormat('HHmmss').format(now),
      'datetime': DateFormat('yyyyMMdd_HHmmss').format(now),
      'year': DateFormat('yyyy').format(now),
      'month': DateFormat('MM').format(now),
      'day': DateFormat('dd').format(now),
    };

    String result = template;
    for (final entry in replacements.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }

    return _sanitizeFilename(result);
  }

  void _validateTemplate(String template) {
    // Regex to find all text inside curly braces: {placeholder}
    final RegExp placeholderRegex = RegExp(r'\{([^}]+)\}');
    final matches = placeholderRegex.allMatches(template);

    final invalidPlaceholders = <String>[];

    for (final match in matches) {
      final placeholder = match.group(1);
      if (placeholder != null && !_allowedPlaceholders.contains(placeholder)) {
        invalidPlaceholders.add(placeholder);
      }
    }

    if (invalidPlaceholders.isNotEmpty) {
      throw ReleaseManagerException(
        'Invalid filename template: Contains unknown placeholders.',
        details: 'The following placeholders are not supported: ${invalidPlaceholders.join(', ')}.\n'
            'Supported placeholders are: ${_allowedPlaceholders.join(', ')}',
      );
    }
  }

  String _sanitizeFilename(String filename) {
    // Replace illegal characters (\, /, :, *, ?, ", <, >, |) with a dash or underscore
    // Also remove leading/trailing spaces
    final RegExp illegalChars = RegExp(r'[\\/:*?"<>|]');
    return filename.replaceAll(illegalChars, '-').trim();
  }
}
