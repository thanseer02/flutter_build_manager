/// Encapsulates information about the resolved Flutter SDK.
class FlutterSdkInfo {
  final String executablePath;
  final String version;
  final String dartVersion;
  final String engineVersion;
  final String frameworkRevision;
  final String channel;
  final bool isFvm;
  final bool isProjectFvm;

  const FlutterSdkInfo({
    required this.executablePath,
    required this.version,
    required this.dartVersion,
    required this.engineVersion,
    required this.frameworkRevision,
    required this.channel,
    required this.isFvm,
    required this.isProjectFvm,
  });
}
