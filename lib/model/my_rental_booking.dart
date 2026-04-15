class MyRentalBooking {
  String? success;
  String? message;
  List<PackageData>? data;

  MyRentalBooking({this.success, this.message, this.data});

  MyRentalBooking.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PackageData>[];
      json['data'].forEach((v) {
        data!.add(new PackageData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PackageData {
  int? id;
  int? hours;
  int? kilometers;
  String? status;
  String? updatedAt;
  String? createdAt;

  PackageData(
      {this.id,
        this.hours,
        this.kilometers,
        this.status,
        this.updatedAt,
        this.createdAt});

  PackageData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hours = json['hours'];
    kilometers = json['kilometers'];
    status = json['status'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['hours'] = this.hours;
    data['kilometers'] = this.kilometers;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    return data;
  }
}