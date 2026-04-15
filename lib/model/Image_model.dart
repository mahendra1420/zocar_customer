class ImageModel {
  String? success;
  String? error;
  String? message;
  List<ImageModelData>? data;

  ImageModel({this.success, this.error, this.message, this.data});

  ImageModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ImageModelData>[];
      json['data'].forEach((v) {
        data!.add(ImageModelData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['error'] = error;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ImageModelData {
  String? id;
  String? banner_type;
  String? url;
  String? image;

  ImageModelData({this.id, this.banner_type, this.url, this.image});

  ImageModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    banner_type = json['banner_type'].toString();
    url = json['url'].toString();
    image = json['image'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['banner_type'] = banner_type;
    data['url'] = url;
    data['image'] = image;
    return data;
  }
}

