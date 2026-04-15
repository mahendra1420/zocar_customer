class VersionCheckResponse {
  final bool status;
  final String type;
  final String androidVersion;
  final String iosVersion;

  VersionCheckResponse({
    required this.status,
    required this.type,
    required this.androidVersion,
    required this.iosVersion,
  });

  factory VersionCheckResponse.fromJson(Map<String, dynamic> json) {
    return VersionCheckResponse(
      status: json['status']?.toString() == "true",
      type: json['type']?.toString() ?? "",
      androidVersion: json['android_version']?.toString() ?? "",
      iosVersion: json['ios_version']?.toString() ?? "",
    );
  }
}
