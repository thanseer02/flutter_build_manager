import '../models/project_model.dart';
import '../models/version_model.dart';
import '../models/environment_model.dart';
import '../models/build_result_model.dart';

/// Holds the state of a release as it moves through the pipeline.
class ReleaseContext {
  final String target;
  final String? flavor;
  final String? envFlag;

  // Phase 1 populated
  ProjectModel? project;
  VersionModel? version;
  EnvironmentModel? environment;
  String? nextCounter;
  String? generatedFilename;

  // Phase 2 populated
  BuildResultModel? buildResult;

  // Phase 3 populated
  String? finalReleaseDirectory;
  String? finalArtifactPath;
  String? finalMetadataPath;
  String? finalChecksumPath;
  
  // Track files moved/created for rollback purposes
  final List<String> rollbackFiles = [];

  ReleaseContext({
    required this.target,
    this.flavor,
    this.envFlag,
  });
}
