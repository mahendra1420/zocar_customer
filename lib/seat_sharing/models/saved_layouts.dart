
import 'package:zocar/seat_sharing/models/seat.dart';

class SavedLayoutResponse {
  final bool status;
  final List<SavedLayout> data;

  const SavedLayoutResponse({
    required this.status,
    required this.data,
  });

  factory SavedLayoutResponse.fromJson(Map<String, dynamic> json) {
    return SavedLayoutResponse(
      status: json['status'] ?? false,
      data: json['data'] == null ? [] : (json['data'] as List<dynamic>).map((e) => SavedLayout.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class SavedLayout {
  final int id;
  final int driverId;
  final String vehicleName;
  final String vehicleNumber;
  final int status;
  final int isDelete;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Seat> seats;

  const SavedLayout({
    required this.id,
    required this.driverId,
    required this.vehicleName,
    required this.vehicleNumber,
    required this.status,
    required this.isDelete,
    this.createdAt,
    this.updatedAt,
    required this.seats,
  });

  factory SavedLayout.fromJson(Map<String, dynamic> json) {
    return SavedLayout(
        id: json['id'] ?? -1,
        driverId: json['driver_id'] ?? -1,
        vehicleName: json['vehicle_name'] ?? "",
        vehicleNumber: json['vehicle_number'] ?? "",
        status: json['status'] ?? -1,
        isDelete: json['is_delete'] ?? -1,
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
        updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
        seats: json['driver_vehicle_layouts'] == null ? [] : (json['driver_vehicle_layouts'] as List).map((e) => Seat.fromJson(e)).toList());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'vehicle_name': vehicleName,
      'vehicle_number': vehicleNumber,
      'status': status,
      'is_delete': isDelete,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'driver_vehicle_layouts': seats.map((e) => e.toJson()).toList()
    };
  }
}
