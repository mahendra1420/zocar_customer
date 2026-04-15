import 'package:zocar/seat_sharing/models/driver_details.dart';
import 'package:zocar/seat_sharing/models/route_pricing.dart';
import 'package:zocar/seat_sharing/models/route_stop.dart';
import 'package:zocar/seat_sharing/models/seat.dart';

import '../utils/ride_status_enum.dart';

class RideDetailsResponse {
  final bool status;
  final String message;
  final RideDetailsData data;

  RideDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RideDetailsResponse.fromJson(Map<String, dynamic> json) {
    return RideDetailsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: RideDetailsData.fromJson(json['data'] ?? {}),
    );
  }
}

class RideDetailsData {
  final int id;
  final int driverId;
  final String from;
  final String to;
  final String stopNames;
  final String departureTime;
  int rideStatus;
  final int status;
  final int isDelete;
  final String createdAt;
  final String updatedAt;
  final String rideStatusName;
  final String vehicleName;
  final String vehicleNumber;
  final List<Seat> seats;
  final List<RouteStop> stops;
  final List<RoutePricing> pricing;
  final DriverDetail driverDetail;

  RideStatus get rideStatusEnum => rideStatus.rideStatusEnum(departureDateTime);

  DateTime get departureDateTime => DateTime.tryParse(departureTime) ?? DateTime.now();

  RideDetailsData({
    required this.id,
    required this.driverId,
    required this.from,
    required this.to,
    required this.stopNames,
    required this.vehicleName,
    required this.vehicleNumber,
    required this.departureTime,
    required this.rideStatus,
    required this.status,
    required this.isDelete,
    required this.createdAt,
    required this.updatedAt,
    required this.rideStatusName,
    required this.seats,
    required this.stops,
    required this.pricing,
    required this.driverDetail,
  });

  factory RideDetailsData.fromJson(Map<String, dynamic> json) {
    return RideDetailsData(
      id: json['id'] ?? 0,
      driverId: json['driver_id'] ?? 0,
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      stopNames: json['stops']?.toString() ?? '',
      departureTime: json['departure_time']?.toString() ?? '',
      vehicleName: json['vehicle_name']?.toString() ?? '',
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      rideStatus: json['ride_status'] ?? 0,
      status: json['status'] ?? 0,
      isDelete: json['is_delete'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      rideStatusName: json['ride_status_name']?.toString() ?? '',
      seats: (json['seat_sharing_vehicle_layout'] as List?)?.map((e) => Seat.fromJson(e)).toList() ?? [],
      stops: (json['seat_sharing_request_stops'] as List?)?.map((e) => RouteStop.fromJson(e)).toList() ?? [],
      pricing: (json['seat_sharing_request_price'] as List?)?.map((e) => RoutePricing.fromJson(e)).toList() ?? [],
      driverDetail: DriverDetail.fromJson(json['driver'] ?? {}),
    );
  }
}
