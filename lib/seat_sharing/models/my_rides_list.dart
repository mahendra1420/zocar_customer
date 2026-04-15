import '../utils/ride_status_enum.dart';

class MyRidesListResponse {
  final bool status;
  final String message;
  final List<MyRideData> data;

  MyRidesListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MyRidesListResponse.fromJson(Map<String, dynamic> json) {
    return MyRidesListResponse(
      status: json['status'].toString() == 'true',
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? []).map((item) => MyRideData.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class MyRideData {
  final int id;
  final String fromId;
  final String toId;
  final int seatSharingRequestId;
  final int driverVehicleLayoutNameId;
  final int driverVehicleLayoutId;
  final bool isDriver;
  final bool isBooked;
  final int bookedBy;
  final int userPriceId;
  final int userFromStopId;
  final int userToStopId;
  final String rideCreatedAt;
  final String departureTime;
  final int rideStatus;
  final String layoutLabel;
  final int layoutRow;
  final int layoutPosition;
  final String fromStopName;
  final String toStopName;
  final String price;
  final String totalPrice;

  RideStatus get rideStatusEnum => rideStatus.rideStatusEnum(departureDateTime);

  DateTime get departureDateTime => DateTime.tryParse(departureTime) ?? DateTime.now();

  MyRideData({
    required this.id,
    required this.seatSharingRequestId,
    required this.driverVehicleLayoutNameId,
    required this.driverVehicleLayoutId,
    required this.isDriver,
    required this.isBooked,
    required this.bookedBy,
    required this.userPriceId,
    required this.userFromStopId,
    required this.userToStopId,
    required this.rideCreatedAt,
    required this.departureTime,
    required this.rideStatus,
    required this.layoutLabel,
    required this.layoutRow,
    required this.layoutPosition,
    required this.fromStopName,
    required this.toStopName,
    required this.price,
    required this.totalPrice,
    required this.fromId,
    required this.toId,
  });

  factory MyRideData.fromJson(Map<String, dynamic> json) {
    return MyRideData(
      id: int.tryParse(json['id'].toString()) ?? 0,
      seatSharingRequestId: int.tryParse(json['seat_sharing_request_id'].toString()) ?? 0,
      driverVehicleLayoutNameId: int.tryParse(json['driver_vehicle_layout_name_id'].toString()) ?? 0,
      driverVehicleLayoutId: int.tryParse(json['driver_vehicle_layout_id'].toString()) ?? 0,
      isDriver: json['is_driver'].toString() == '1',
      isBooked: json['is_booked'].toString() == '1',
      bookedBy: int.tryParse(json['booked_by'].toString()) ?? 0,
      userPriceId: int.tryParse(json['user_price_id'].toString()) ?? 0,
      userFromStopId: int.tryParse(json['user_from_stop_id'].toString()) ?? 0,
      userToStopId: int.tryParse(json['user_to_stop_id'].toString()) ?? 0,
      rideCreatedAt: json['ride_created_at']?.toString() ?? '',
      departureTime: json['departure_time']?.toString() ?? '',
      rideStatus: int.tryParse(json['ride_status'].toString()) ?? 0,
      layoutLabel: json['layout_label']?.toString() ?? '',
      layoutRow: int.tryParse(json['layout_row'].toString()) ?? 0,
      layoutPosition: int.tryParse(json['layout_position'].toString()) ?? 0,
      fromStopName: json['from_stop_name']?.toString() ?? '-',
      toStopName: json['to_stop_name']?.toString() ?? '-',
      price: json['price']?.toString() ?? '0',
      totalPrice: json['total_price']?.toString() ?? '0',
      fromId: json['from_stop_id']?.toString() ?? '',
      toId: json['to_stop_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seat_sharing_request_id': seatSharingRequestId,
      'driver_vehicle_layout_name_id': driverVehicleLayoutNameId,
      'driver_vehicle_layout_id': driverVehicleLayoutId,
      'is_driver': isDriver ? 1 : 0,
      'is_booked': isBooked ? 1 : 0,
      'booked_by': bookedBy,
      'user_price_id': userPriceId,
      'user_from_stop_id': userFromStopId,
      'user_to_stop_id': userToStopId,
      'ride_created_at': rideCreatedAt,
      'ride_status': rideStatus,
      'layout_label': layoutLabel,
      'layout_row': layoutRow,
      'layout_position': layoutPosition,
      'from_stop_name': fromStopName,
      'to_stop_name': toStopName,
      'price': price,
      'fromStopId': fromId,
      'toStopId': toId,
    };
  }
}
