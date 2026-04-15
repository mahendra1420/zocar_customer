class DriverDetail {
  final String id;
  final String phone;
  final String nom;
  final String prenom;
  final String email;
  final String photoPath;
  final String driverName;
  final String photoUrl;

  DriverDetail({
    required this.id,
    required this.phone,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.photoPath,
    required this.driverName,
    required this.photoUrl,
  });

  factory DriverDetail.fromJson(Map<String, dynamic> json) {
    return DriverDetail(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      photoPath: json['photo_path'] ?? '',
      driverName: json['driver_name'] ?? '',
      photoUrl: json['photo_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'photo_path': photoPath,
      'driver_name': driverName,
      'photo_url': photoUrl,
    };
  }
}
