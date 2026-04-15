import 'package:zocar/seat_sharing/models/stop_point.dart';

class RouteStop {
  String id;
  String name;
  double latitude;
  double longitude;
  int order;
  int? seatSharingRequestId;
  String stopId;
  List<StopPoint> stopPoints;

  RouteStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.order,
    this.seatSharingRequestId,
    required this.stopId,
    this.stopPoints = const [],
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) => RouteStop(
        id: json['id']?.toString() ?? "",
        name: json['name'] ?? "",
        latitude: double.tryParse(json['latitude'].toString()) ?? 0,
        longitude: double.tryParse(json['longitude'].toString()) ?? 0,
        order: int.tryParse(json['order'].toString()) ?? 0,
        seatSharingRequestId: json['seat_sharing_request_id'],
        stopId: json['stop_id'].toString(),
        stopPoints: (json['seat_sharing_request_stops_points'] as List<dynamic>?)?.map((e) => StopPoint.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'order': order,
        'seat_sharing_request_id': seatSharingRequestId,
        'stop_id': stopId,
        'stop_points': stopPoints.map((e) => e.toJson()).toList(),
      };
}
