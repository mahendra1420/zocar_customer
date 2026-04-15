enum StopPointType {
  pickup,
  drop,
  both,
}

class StopPoint {
  final String id;
  final String stopPointId;
  final String stopId;
  final String name;
  final double latitude;
  final double longitude;
  StopPointType type;

  StopPoint({
    this.id = '',
    required this.stopPointId,
    required this.stopId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'stop_points_id': stopPointId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'type': type.name,
    };
  }

  // Create from JSON
  factory StopPoint.fromJson(Map<String, dynamic> json) {
    return StopPoint(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      stopPointId: json['stop_points_id']?.toString() ?? json['stop_points_id']?.toString() ?? '',
      stopId: json['seat_sharing_request_stops_id']?.toString() ?? json['seat_sharing_request_stops_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      latitude: (num.tryParse(json['latitude'].toString() ) ?? 0.0).toDouble(),
      longitude: (num.tryParse(json['longitude'].toString()) ?? 0.0).toDouble(),
      type: StopPointType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => StopPointType.both,
      ),
    );
  }

  // Create a copy with updated values
  StopPoint copyWith({
    String? stopPointId,
    String? name,
    double? latitude,
    double? longitude,
    String? stopId,
    StopPointType? type,
  }) {
    return StopPoint(
      stopPointId: stopPointId ?? this.stopPointId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      stopId: stopId ?? this.stopId,
    );
  }

  @override
  String toString() {
    return 'StopPoint(stopPointId: $stopPointId, name: $name, lat: $latitude, lng: $longitude, type: ${type.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StopPoint &&
        other.stopPointId == stopPointId &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(stopPointId, name, latitude, longitude, type);
  }
}