/// Pricing rates per vehicle category (fetched from server or configured locally)
class CustomRentalVehicle {
  final String id;
  final String name;
  final String description;
  final String image;
  final double ratePerKm;
  final double ratePerHour;
  final double? serverTotalPrice;
  final double? quoteTotalKm;
  final double? quoteTotalHours;
  String? selectedImagePath;


   CustomRentalVehicle({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.ratePerKm,
    required this.ratePerHour,
    this.serverTotalPrice,
    this.quoteTotalKm,
    this.quoteTotalHours,
    this.selectedImagePath
  });

  double calculatePrice({required double km, required double hours}) {
    if (serverTotalPrice != null) return serverTotalPrice!;
    return (ratePerKm * km) + (ratePerHour * hours);
  }

  factory CustomRentalVehicle.fromJson(Map<String, dynamic> json) {
    return CustomRentalVehicle(
      id: json['id'].toString(),
      name: json['libelle'].toString(),
      description: json['description'].toString(),
      image: json['image'].toString(),
      ratePerKm: double.tryParse(json['rate_per_km'].toString()) ?? 0,
      ratePerHour: double.tryParse(json['rate_per_hour'].toString()) ?? 0,
      serverTotalPrice: null,
      quoteTotalKm: null,
      quoteTotalHours: null,
      selectedImagePath:  json['selected_image_path'].toString(),
    );
  }

  /// Row from `POST /rental/calculate`; merge with catalog vehicle for image/description.
  factory CustomRentalVehicle.fromRentalCalculateJson(
    Map<String, dynamic> json, {
    CustomRentalVehicle? catalogMatch,
  }) {
    final vid = json['vehicle_id']?.toString() ?? '';
    final price = double.tryParse(json['price'].toString());
    final apiImage = json['image']?.toString();
    final apiSelectedImagePath = json['selected_image_path']?.toString();
    return CustomRentalVehicle(
      id: vid,
      name: json['vehicle_name']?.toString() ?? catalogMatch?.name ?? '',
      description: catalogMatch?.description ?? '',
      // Prefer images returned by `rental/calculate`, fall back to catalog.
      image: (apiImage != null && apiImage.isNotEmpty) ? apiImage : (catalogMatch?.image ?? ''),
      selectedImagePath: (apiSelectedImagePath != null && apiSelectedImagePath.isNotEmpty)
          ? apiSelectedImagePath
          : (catalogMatch?.selectedImagePath ?? ''),
      ratePerKm: catalogMatch?.ratePerKm ?? 0,
      ratePerHour: catalogMatch?.ratePerHour ?? 0,
      serverTotalPrice: price,
      quoteTotalKm: double.tryParse(json['total_km']?.toString() ?? ''),
      quoteTotalHours: double.tryParse(json['total_hours']?.toString() ?? ''),

    );
  }
}