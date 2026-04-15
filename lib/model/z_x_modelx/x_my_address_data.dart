// class MyAddressData {
//   String? success;
//   String? message;
//   List<Data>? data;
//
//   MyAddressData({this.success, this.message, this.data});
//
//   MyAddressData.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     message = json['message'];
//     if (json['data'] != null) {
//       data = <Data>[];
//       json['data'].forEach((v) {
//         data!.add(new Data.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['success'] = this.success;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Data {
//   int? id;
//   String? longitude;
//   String? latitude;
//   String? address;
//   String? addressType;
//   int? userAppId;
//
//   Data(
//       {this.id,
//         this.longitude,
//         this.latitude,
//         this.address,
//         this.addressType,
//         this.userAppId});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     longitude = json['longitude'];
//     latitude = json['latitude'];
//     address = json['address'];
//     addressType = json['address_type'];
//     userAppId = json['user_app_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['longitude'] = this.longitude;
//     data['latitude'] = this.latitude;
//     data['address'] = this.address;
//     data['address_type'] = this.addressType;
//     data['user_app_id'] = this.userAppId;
//     return data;
//   }
// }