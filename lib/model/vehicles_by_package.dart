class VehiclesByPackage {
  String? success;
  List<VehiclesData>? data;

  VehiclesByPackage({this.success, this.data});

  VehiclesByPackage.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <VehiclesData>[];
      json['data'].forEach((v) {
        data!.add(new VehiclesData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VehiclesData {
  String? id;
  String? libelle;
  String? prix;
  String? image;
  String? selectedImage;
  String? status;
  String? creer;
  String? modifier;
  String? updatedAt;
  String? description;
  int? price;
  Null deletedAt;
  String? distance;

  VehiclesData(
      {this.id,
        this.libelle,
        this.prix,
        this.image,
        this.selectedImage,
        this.status,
        this.creer,
        this.modifier,
        this.updatedAt,
        this.description,
        this.deletedAt,
        this.distance});

  VehiclesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    libelle = json['libelle'];
    prix = json['prix'];
    image = json['image'];
    selectedImage = json['selected_image'];
    status = json['status'];
    creer = json['creer'];
    modifier = json['modifier'];
    updatedAt = json['updated_at'];
    price = json['price'];
    description = json['description'];
    deletedAt = json['deleted_at'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['libelle'] = this.libelle;
    data['prix'] = this.prix;
    data['image'] = this.image;
    data['selected_image'] = this.selectedImage;
    data['status'] = this.status;
    data['creer'] = this.creer;
    data['modifier'] = this.modifier;
    data['updated_at'] = this.updatedAt;
    data['description'] = this.description;
    data['price'] = this.price;
    data['deleted_at'] = this.deletedAt;
    data['distance'] = this.distance;
    return data;
  }
}