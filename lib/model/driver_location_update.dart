class DriverLocationModel {
  final int? driverId;
  final double driverLongitude;
  final double driverLatitude;
  final double rotation;
  final bool active;

  DriverLocationModel({
    required this.driverId,
    required this.driverLongitude,
    required this.driverLatitude,
    required this.rotation,
    required this.active,
  });

  /// Factory constructor for JSON / Map parsing
  factory DriverLocationModel.fromJson(Map<String, dynamic> json) {
    return DriverLocationModel(
      driverId: _toInt(json['driver_id']),
      driverLongitude: _toDouble(json['driver_longitude']),
      driverLatitude: _toDouble(json['driver_latitude']),
      rotation: _toDouble(json['rotation']),
      active: json['active']?.toString() == "true",
    );
  }

  /// Convert model back to Map
  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'driver_longitude': driverLongitude,
      'driver_latitude': driverLatitude,
      'rotation': rotation,
      'active': active,
    };
  }

  /// Safe double parsing using tryParse
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Safe int parsing
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  String toString() {
    return 'DriverLocationModel('
        'driverId: $driverId, '
        'driverLongitude: $driverLongitude, '
        'driverLatitude: $driverLatitude, '
        'rotation: $rotation, '
        'active: $active'
        ')';
  }
}
