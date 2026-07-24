
/// Represents the state of the build counters.
class BuildStateModel {
  /// The last date a build was generated, format: yyyyMMdd
  final String lastDate;

  /// Map of environment names to their current daily counter.
  final Map<String, int> counters;

  /// Creates a new [BuildStateModel].
  const BuildStateModel({
    required this.lastDate,
    required this.counters,
  });

  factory BuildStateModel.fromJson(Map<String, dynamic> json) {
    return BuildStateModel(
      lastDate: json['lastDate'] as String? ?? '',
      counters: (json['counters'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastDate': lastDate,
      'counters': counters,
    };
  }
}
