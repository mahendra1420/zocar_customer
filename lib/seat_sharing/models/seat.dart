class Seat {
  String label;
  int row;
  int position;
  bool isDriver;
  bool isBooked;
  bool isSelected;
  String? bookedBy;
  num advancePayment;
  num? driverVehicleLayoutNameId;
  num? driverVehicleLayoutId;
  num? id;

  Seat({
    required this.label,
    required this.row,
    this.position = 0,
    this.isDriver = false,
    this.isBooked = false,
    this.bookedBy,
    this.isSelected = false,
    this.id,
    this.advancePayment = 0,
    this.driverVehicleLayoutNameId,
    this.driverVehicleLayoutId,
  });

  factory Seat.driver() => Seat(label: "D", row: 0, isDriver: true);

  factory Seat.fromJson(Map<String, dynamic> json) => Seat(
        label: json['label']?.toString() ?? "",
        row: json['row'] ?? 0,
        position: json['position'] ?? 0,
        isDriver: (json['is_driver'] ?? 0) == 1,
        isBooked: (json['is_booked'] ?? 0) == 1,
        bookedBy: json['booked_by']?.toString(),
        id: num.tryParse(json['id'].toString()),
        advancePayment: num.tryParse(json['advance_payment'].toString()) ?? 0,
        driverVehicleLayoutNameId: json['driver_vehicle_layout_name_id'] ?? 0,
        driverVehicleLayoutId: json['driver_vehicle_layout_id'] ?? 0,
      );

  Seat copyWith({
    String? label,
    int? row,
    int? position,
    bool? isDriver,
    bool? isBooked,
    String? bookedBy,
  }) {
    return Seat(
      label: label ?? this.label,
      row: row ?? this.row,
      position: position ?? this.position,
      isDriver: isDriver ?? this.isDriver,
      isBooked: isBooked ?? this.isBooked,
      bookedBy: bookedBy ?? this.bookedBy,
    );
  }

  Map<String, dynamic> toJson() => {
        'driver_vehicle_layout_id': id ?? driverVehicleLayoutNameId,
        'label': label,
        'row': row,
        'position': position,
        'is_driver': isDriver,
        'is_booked': isBooked,
        'booked_by': bookedBy,
      };

  Map<String, dynamic> bookSeatJson(
    int userId, {
    required String? user_price_id,
    required String? user_from_stop_id,
    required String? user_to_stop_id,
    required String? user_pickup_point_id,
    required String? user_drop_point_id,
  }) =>
      {
        'driver_vehicle_layout_id': driverVehicleLayoutId,
        'user_id': userId,
        'user_price_id': user_price_id,
        'user_from_stop_id': user_from_stop_id,
        'user_to_stop_id': user_to_stop_id,
        'driver_vehicle_layout_name_id': driverVehicleLayoutNameId,
        'user_pickup_point_id': user_pickup_point_id,
        'user_drop_point_id': user_drop_point_id,
      };

  static List<Seat> get defaultSeatsLayout => [
        Seat(label: "D", row: 0, position: 1, isDriver: true),
        Seat(label: "P1", row: 0, position: 0),
        Seat(label: "R1S1", row: 1, position: 0),
        Seat(label: "R1S2", row: 1, position: 1),
        Seat(label: "R1S3", row: 1, position: 2),
      ];
}
