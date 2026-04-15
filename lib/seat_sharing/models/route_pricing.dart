class RoutePricing {
  String fromStopId;
  String toStopId;
  double price;
  int? id;
  int? seatSharingRequestId;

  RoutePricing({
    this.id,
    this.seatSharingRequestId,
    required this.fromStopId,
    required this.toStopId,
    required this.price,
  });

  factory RoutePricing.fromJson(Map<String, dynamic> json) => RoutePricing(
        id: json['id'],
        seatSharingRequestId: json['seat_sharing_request_id'],
        fromStopId: json['fromStopId'] ?? "",
        toStopId: json['toStopId'] ?? "",
        price: double.tryParse(json['price'].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'seat_sharing_request_id': seatSharingRequestId,
        'fromStopId': fromStopId,
        'toStopId': toStopId,
        'price': price,
      };
}
