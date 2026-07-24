/// Represents the version information extracted from a project.
class VersionModel {
  /// The name of the project.
  final String projectName;

  /// The version string (e.g., '2.4.1').
  final String version;

  /// The build number (e.g., '35').
  final String buildNumber;

  /// Creates a new [VersionModel].
  const VersionModel({
    required this.projectName,
    required this.version,
    required this.buildNumber,
  });

  @override
  String toString() {
    return 'Project Name:\n$projectName\n\nVersion:\n$version\n\nFlutter Build Number:\n$buildNumber';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is VersionModel &&
      other.projectName == projectName &&
      other.version == version &&
      other.buildNumber == buildNumber;
  }

  @override
  int get hashCode => projectName.hashCode ^ version.hashCode ^ buildNumber.hashCode;
}
