import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter_build_manager/exceptions/release_manager_exception.dart';

/// Service responsible for renaming build artifacts without overwriting existing files.
class ArtifactRenameService {
  /// Renames the file or directory at [originalPath] to [targetPath].
  /// 
  /// If a file or directory already exists at [targetPath], it will append
  /// a counter (e.g., _2, _3) before the extension until an available name is found.
  /// 
  /// Returns the absolute path of the newly renamed artifact.
  Future<String> renameArtifact(String originalPath, String targetPath) async {
    final entityType = FileSystemEntity.typeSync(originalPath);
    if (entityType == FileSystemEntityType.notFound) {
      throw ReleaseManagerException('Cannot rename: Source artifact does not exist at $originalPath');
    }

    // Resolve the conflict-free target path
    final finalTargetPath = _getConflictFreePath(targetPath);
    
    // Ensure the target directory exists
    final targetDir = Directory(p.dirname(finalTargetPath));
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    try {
      if (entityType == FileSystemEntityType.directory) {
        final dir = Directory(originalPath);
        final newDir = await dir.rename(finalTargetPath);
        return newDir.absolute.path;
      } else {
        final file = File(originalPath);
        final newFile = await file.rename(finalTargetPath);
        return newFile.absolute.path;
      }
    } catch (e) {
      // Sometimes rename fails across different drives/mounts. Fallback to copy+delete.
      try {
        if (entityType == FileSystemEntityType.directory) {
          _copyDirectory(Directory(originalPath), Directory(finalTargetPath));
          Directory(originalPath).deleteSync(recursive: true);
        } else {
          File(originalPath).copySync(finalTargetPath);
          File(originalPath).deleteSync();
        }
        return finalTargetPath;
      } catch (innerE) {
        throw ReleaseManagerException('Failed to rename artifact safely.', details: innerE.toString());
      }
    }
  }

  /// Calculates a path that does not currently exist by appending _2, _3, etc.
  String _getConflictFreePath(String targetPath) {
    if (!FileSystemEntity.typeSync(targetPath).notExists) {
      final ext = p.extension(targetPath);
      final nameWithoutExt = p.withoutExtension(targetPath);
      
      int counter = 2;
      String newPath;
      do {
        newPath = '${nameWithoutExt}_$counter$ext';
        counter++;
      } while (!FileSystemEntity.typeSync(newPath).notExists);
      
      return newPath;
    }
    
    return targetPath;
  }

  /// Recursively copies a directory.
  void _copyDirectory(Directory source, Directory destination) {
    destination.createSync(recursive: true);
    for (var entity in source.listSync(recursive: false)) {
      if (entity is Directory) {
        var newDirectory = Directory(p.join(destination.absolute.path, p.basename(entity.path)));
        newDirectory.createSync();
        _copyDirectory(entity.absolute, newDirectory);
      } else if (entity is File) {
        entity.copySync(p.join(destination.path, p.basename(entity.path)));
      }
    }
  }
}

extension on FileSystemEntityType {
  bool get notExists => this == FileSystemEntityType.notFound;
}
