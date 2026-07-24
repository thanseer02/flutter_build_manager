/// Represents the metadata associated with a generated release artifact.
class ReleaseMetadataModel {
  final String projectName;
  final String version;
  final String flutterBuildNumber;
  final String environment;
  final String counter;
  final String generatedFilename;
  final String artifactType;
  final int artifactSize;
  final String generatedTime;
  final String flutterVersion;
  final String dartVersion;
  final String operatingSystem;
  final String releaseDirectory;

  const ReleaseMetadataModel({
    required this.projectName,
    required this.version,
    required this.flutterBuildNumber,
    required this.environment,
    required this.counter,
    required this.generatedFilename,
    required this.artifactType,
    required this.artifactSize,
    required this.generatedTime,
    required this.flutterVersion,
    required this.dartVersion,
    required this.operatingSystem,
    required this.releaseDirectory,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'version': version,
      'flutterBuildNumber': flutterBuildNumber,
      'environment': environment,
      'counter': counter,
      'generatedFilename': generatedFilename,
      'artifactType': artifactType,
      'artifactSize': artifactSize,
      'generatedTime': generatedTime,
      'flutterVersion': flutterVersion,
      'dartVersion': dartVersion,
      'operatingSystem': operatingSystem,
      'releaseDirectory': releaseDirectory,
    };
  }
}
