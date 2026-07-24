import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'package:flutter_build_manager/exceptions/release_manager_exception.dart';
import 'package:flutter_build_manager/models/flutter_sdk_info.dart';
import 'process_service.dart';

/// Service responsible for locating and validating the Flutter SDK.
class FlutterSdkService {
  final ProcessService _processService;

  FlutterSdkService({required ProcessService processService})
      : _processService = processService;

  /// Resolves the correct Flutter SDK and fetches its version info.
  Future<FlutterSdkInfo> getSdkInfo({String? basePath}) async {
    final root = basePath ?? Directory.current.path;

    String executablePath = '';
    bool isFvm = false;
    bool isProjectFvm = false;

    // 1. Check for Project FVM
    final fvmConfigPath = p.join(root, '.fvm', 'fvm_config.json');
    if (File(fvmConfigPath).existsSync()) {
      final fvmSdkPath = p.join(root, '.fvm', 'flutter_sdk', 'bin', _flutterBinName);
      if (!File(fvmSdkPath).existsSync()) {
        throw const ReleaseManagerException(
          'FVM is configured for this project, but the SDK is missing.',
          details: 'Run `fvm install` to download the required Flutter SDK for this project.',
        );
      }
      executablePath = fvmSdkPath;
      isFvm = true;
      isProjectFvm = true;
    } else {
      // 4. Custom executable path from flutter_build_manager.yaml (Checked before System)
      final configPath = p.join(root, 'flutter_build_manager.yaml');
      if (File(configPath).existsSync()) {
        try {
          final doc = loadYaml(File(configPath).readAsStringSync());
          if (doc is YamlMap && doc['release_manager'] is YamlMap) {
            final flutterPath = doc['release_manager']['flutter_path'];
            if (flutterPath != null && flutterPath.toString().isNotEmpty) {
              executablePath = flutterPath.toString();
            }
          }
        } catch (_) {
          // ignore
        }
      }

      if (executablePath.isEmpty) {
        // 2 & 3. Global FVM or System Flutter
        executablePath = 'flutter';
      }
    }

    return _validateAndFetchInfo(executablePath, isFvm: isFvm, isProjectFvm: isProjectFvm);
  }

  Future<FlutterSdkInfo> _validateAndFetchInfo(
    String executablePath, {
    required bool isFvm,
    required bool isProjectFvm,
  }) async {
    try {
      final result = await _processService.run(executablePath, ['--version', '--machine']);
      if (result.exitCode != 0) {
        throw ReleaseManagerException(
          'Flutter command failed.',
          details: 'Exit code ${result.exitCode}:\n${result.stderr}',
        );
      }

      final json = jsonDecode(result.stdout) as Map<String, dynamic>;
      
      final version = json['frameworkVersion']?.toString() ?? '0.0.0';
      final dartVersion = json['dartSdkVersion']?.toString() ?? '0.0.0';
      final channel = json['channel']?.toString() ?? 'unknown';
      final engineVersion = json['engineRevision']?.toString() ?? 'unknown';
      final frameworkRevision = json['frameworkRevision']?.toString() ?? 'unknown';

      _verifyCompatibility(version);

      return FlutterSdkInfo(
        executablePath: executablePath,
        version: version,
        dartVersion: dartVersion,
        engineVersion: engineVersion,
        frameworkRevision: frameworkRevision,
        channel: channel,
        isFvm: isFvm,
        isProjectFvm: isProjectFvm,
      );
    } catch (e) {
      if (e is ReleaseManagerException) rethrow;
      throw ReleaseManagerException(
        'Failed to parse Flutter SDK info.',
        details: 'Executable: $executablePath. Error: $e',
      );
    }
  }

  void _verifyCompatibility(String version) {
    try {
      final parts = version.split('.');
      final major = int.parse(parts[0]);
      final minor = int.parse(parts[1]);

      if (major < 3 || (major == 3 && minor < 30)) {
        throw ReleaseManagerException(
          'Incompatible Flutter version detected ($version).',
          details: 'flutter_build_manager requires Flutter 3.30.0 or newer.',
        );
      }
    } catch (e) {
      if (e is ReleaseManagerException) rethrow;
    }
  }

  String get _flutterBinName => Platform.isWindows ? 'flutter.bat' : 'flutter';
}
