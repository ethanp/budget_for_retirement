/// Holds optional metadata for a configuration value (e.g., last update date and source).
class ConfigMetadata {
  const ConfigMetadata({this.date, this.source});

  final String? date;
  final String? source;

  bool get hasData => date != null || source != null;

  factory ConfigMetadata.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ConfigMetadata();
    final lastUpdated = json['last_updated'];
    if (lastUpdated is! Map<String, dynamic>) return const ConfigMetadata();
    return ConfigMetadata(
      date: lastUpdated['date']?.toString(),
      source: lastUpdated['source']?.toString(),
    );
  }
}



