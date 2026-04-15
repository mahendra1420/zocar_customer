import '../utils/ride_status_enum.dart';

class SeatSharingRidesResponse {
  final bool status;
  final String message;
  final List<SeatSharingRideData> data;

  SeatSharingRidesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SeatSharingRidesResponse.fromJson(Map<String, dynamic> json) {
    return SeatSharingRidesResponse(
      status: json['status'] ?? json['success'] ?? false,
      message: json['message'] ?? 'Error occured..Try again later.!',
      data: (json['data'] as List<dynamic>?)?.map((e) => SeatSharingRideData.fromJson(e)).toList() ?? [],
    );
  }

// factory SeatSharingRidesResponse.fromJson(Map<String, dynamic> json) {
//   return SeatSharingRidesResponse(
//     status: json is List,
//     message: json is List ? 'Rides fetch successfully' : 'Error occured..Try again later.!',
//     data: (json as List<dynamic>?)
//         ?.map((e) => SeatSharingRideData.fromJson(e))
//         .toList() ??
//         [],
//   );
// }
}

class SeatSharingRideData {
  final int id;
  final int driverId;
  final String from;
  final String fromId;
  final String toId;
  final String to;
  final String stops;
  final String departureTime;
  final int rideStatus;
  final int status;
  final int isDelete;
  final String createdAt;
  final String updatedAt;
  final num total_seats;
  final num booked_seats;
  final num remaining_seats;
  final num price;
  final String rideStatusName;

  RideStatus get rideStatusEnum => rideStatus.rideStatusEnum(departureDateTime);

  DateTime get departureDateTime => DateTime.tryParse(departureTime) ?? DateTime.now();

  SeatSharingRideData({
    required this.id,
    required this.driverId,
    required this.from,
    required this.to,
    required this.stops,
    required this.departureTime,
    required this.rideStatus,
    required this.status,
    required this.isDelete,
    required this.createdAt,
    required this.updatedAt,
    required this.total_seats,
    required this.booked_seats,
    required this.remaining_seats,
    required this.price,
    required this.rideStatusName,
    required this.fromId,
    required this.toId,
  });

  factory SeatSharingRideData.fromJson(Map<String, dynamic> json) {
    return SeatSharingRideData(
      id: json['id'] ?? 0,
      driverId: json['driver_id'] ?? 0,
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      fromId: json['fromStopId']?.toString() ?? '',
      toId: json['toStopId']?.toString() ?? '',
      stops: json['stops'] ?? '',
      departureTime: json['departure_time'] ?? '',
      rideStatus: json['ride_status'] ?? 0,
      status: json['status'] ?? 0,
      isDelete: json['is_delete'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      rideStatusName: json['ride_status_name'] ?? '',
      total_seats: num.tryParse(json['total_seats'].toString()) ?? 0,
      booked_seats: num.tryParse(json['booked_seats'].toString()) ?? 0,
      remaining_seats: num.tryParse(json['remaining_seats'].toString()) ?? 0,
      price: num.tryParse(json['price'].toString()) ?? 0,
    );
  }
}
