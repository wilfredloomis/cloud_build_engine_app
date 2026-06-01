class ArtifactResponse {
  final int artifactId;
  final String name;

  ArtifactResponse({
    required this.artifactId,
    required this.name,
  });

  factory ArtifactResponse.fromJson(Map<String, dynamic> json) {
    return ArtifactResponse(
      artifactId: json['artifact_id'] as int,
      name: json['name'] as String,
    );
  }
}
