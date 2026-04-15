import 'package:zocar/model/tax_model.dart';

class RideModel {
  String? success;
  String? error;
  String? message;
  List<RideData>? data;
  Pagination? pagination;

  RideModel({this.success, this.error, this.message, this.data, this.pagination});

  RideModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <RideData>[];
      json['data'].forEach((v) {
        data!.add(RideData.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
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

class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class RideData {
  String? id;
  // String? noteId;
  String? idUserApp;
  String? vehicle_id;
  int? rental_package_id;
  String? departName;
  String? distanceUnit;
  String? destinationName;
  String? latitudeDepart;
  String? longitudeDepart;
  String? latitudeArrivee;
  String? longitudeArrivee;

  String? place;
  String? statut;
  String? idConducteur;
  String? creer;
  List<Stops>? stops;
  String? trajet;
  String? tripObjective;
  String? tripCategory;
  String? nom;
  String? prenom;
  String? otp;
  String? distance;
  String? phone;
  String? nomConducteur;
  String? prenomConducteur;
  String? driverPhone;
  String? photoPath;
  String? dateRetour;
  String? heureRetour;
  String? statutRound;
  String? montant;
  String? duree;
  String? paymentStatus;
  String? payment;
  String? paymentImage;
  String? idVehicule;
  String? brand;
  String? model;
  String? carMake;
  String? milage;
  String? km;
  String? color;
  String? numberplate;
  String? passenger;
  String? moyenne;
  String? moyenneDriver;
  String? vehicle_type;
  String? rideType;
  String? star;
  String? comment;
  PackageDetails? packageDetails;
  List<TaxModel>? taxModel;
  String? totalAmount;
  dynamic advancePayment;
  String? receivedComment;
  String? receivedRating;
  String? givenRating;
  String? givenComment;
  int? advancePaymentStatus;
  String? type;
  String? taxAmount;
  String? extraKmCharge;
  String? extraMinCharge;
  String? tollParkingCharge;
  String? adminCommission;
  String? farePrice;
  double? remainingPayment;




  String get vehicleTypeName =>
      vehicle_type ??
      (vehicle_id == "1"
          ? "sedan"
          : vehicle_id == "6"
              ? "Suv"
              : "-");

  bool get isCompleted => statut == "completed";
  bool get isShowContact => (statut == "on ride" || statut == "confirmed");
  bool get isConfirmedOrOnRide => (statut == "on ride" || statut == "confirmed");

  bool get isReviewAdded => num.tryParse(givenRating.toString()) != 0;

  bool get isPaymentDone => paymentStatus == "yes";

  bool get isNew => statut?.toLowerCase() == "new";

  bool get isCompletedButPaymentAndReviewPending => isCompleted && (!isReviewAdded || !isPaymentDone);

  bool get isCompletedAndAllDone => isCompleted && isReviewAdded && isPaymentDone;

  RideData(
      {this.id,
      // this.noteId,
      this.star,
      this.comment,
      this.idUserApp,
      this.vehicle_id,
      this.departName,
      this.distanceUnit,
      this.destinationName,
      this.latitudeDepart,
      this.longitudeDepart,
      this.latitudeArrivee,
      this.rental_package_id,
      this.longitudeArrivee,
      this.vehicle_type,
      // this.numberPoeple,
      this.place,
      this.statut,
      this.idConducteur,
      this.creer,
      this.trajet,
      this.tripObjective,
      this.tripCategory,
      this.nom,
      this.prenom,
      this.otp,
      this.distance,
      this.phone,
      this.nomConducteur,
      this.prenomConducteur,
      this.driverPhone,
      this.photoPath,
      this.dateRetour,
      this.heureRetour,
      this.statutRound,
      this.montant,
      this.duree,
      this.paymentStatus,
      this.payment,
      this.paymentImage,
      this.idVehicule,
      this.brand,
      this.model,
      this.carMake,
      this.milage,
      this.km,
      this.color,
      this.numberplate,
      this.passenger,
      this.stops,
      this.moyenne,
      this.taxModel,
      this.rideType,
      this.packageDetails,
      this.moyenneDriver,
      this.advancePayment,
        this.advancePaymentStatus,
      this.totalAmount,
        this.type,
        this.taxAmount,
        this.extraKmCharge,
        this.extraMinCharge,
        this.tollParkingCharge,
        this.adminCommission,
        this.farePrice,
        this.remainingPayment,




      });

  RideData.fromJson(Map<String, dynamic> json) {
    List<TaxModel>? taxList = [];
    if (json['tax'] != null) {
      taxList = <TaxModel>[];
      json['tax'].forEach((v) {
        taxList!.add(TaxModel.fromJson(v));
      });
    }
    id = json['id'].toString();
    // noteId = json['note_id']?.toString();
    star = json['niveau']?.toString();
    comment = json['comment']?.toString();
    idUserApp = json['id_user_app'].toString();
    departName = json['depart_name'].toString();
    distanceUnit = json['distance_unit'].toString();
    destinationName = json['destination_name'].toString();
    vehicle_id = json['vehicle_id'].toString();
    rental_package_id = int.tryParse(json['rental_package_id']?.toString() ?? '');
    latitudeDepart = json['latitude_depart'].toString();
    longitudeDepart = json['longitude_depart'].toString();
    latitudeArrivee = json['latitude_arrivee'].toString();
    longitudeArrivee = json['longitude_arrivee'].toString();
    vehicle_type = json['vehicle_type']?.toString();
    // numberPoeple = json['number_poeple'].toString();
    place = json['place'].toString();
    statut = json['statut'].toString();
    advancePayment = json['advance_payment'];
    advancePaymentStatus = json['advance_payment_status'];
    totalAmount = (json['total_amount']).toString();
    idConducteur = (json['id_conducteur'].toString());
    creer = json['creer'].toString();
    trajet = json['trajet'].toString();
    tripObjective = json['trip_objective'].toString();
    tripCategory = json['trip_category'].toString();
    nom = json['nom'].toString();
    prenom = json['prenom'].toString();
    farePrice = json['fare_price'];

    if (json['stops'] != null && json['stops'].isNotEmpty && json['stops'].toString() != "[]") {
      stops = <Stops>[];
      json['stops'].forEach((v) {
        stops!.add(Stops.fromJson(v));
      });
    } else {
      stops = [];
    }
    otp = json['otp'].toString();
    distance = json['distance'].toString();
    phone = json['phone'].toString();
    receivedComment = json['received_comment']?.toString() ?? '';
    receivedRating = json['received_rating']?.toString() ?? "0";
    givenRating = json['given_rating']?.toString() ?? "0";
    givenComment = json['given_comment']?.toString() ?? '';
    nomConducteur = json['nomConducteur'].toString();
    prenomConducteur = json['prenomConducteur'].toString();
    driverPhone = json['driverPhone'].toString();
    photoPath = json['photo_path']?.toString();
    dateRetour = json['date_retour'].toString();
    heureRetour = json['heure_retour'].toString();
    statutRound = json['statut_round'].toString();
    montant = json['montant'].toString();
    duree = json['duree'].toString();
    paymentStatus = json['statut_paiement'].toString();
    payment = json['payment'].toString();
    paymentImage = json['payment_image'].toString();
    idVehicule = json['idVehicule'].toString();
    brand = json['brand'].toString();
    model = json['model'].toString();
    carMake = json['car_make'].toString();
    milage = json['milage'].toString();
    km = json['km'].toString();
    color = json['color'].toString();
    numberplate = json['numberplate'].toString();
    passenger = json['passenger'].toString();
    driverPhone = json['driver_phone'].toString();
    moyenne = json['moyenne'].toString();
    moyenneDriver = json['moyenne_driver'].toString();
    taxModel = taxList;
    type = json['type'];
    taxAmount = json['tax_amount'];
    extraKmCharge = json['extra_km_charge'];
    extraMinCharge = json['extra_min_charge'];
    tollParkingCharge = json['toll_parking_charge'];
    adminCommission = json['admin_commission'];
    remainingPayment = (json['remaining_payment'] != null)
        ? double.tryParse(json['remaining_payment'].toString())
        : null;

    packageDetails = json['package_details'] != null
        ? PackageDetails.fromJson(json['package_details'])
        : null;
    rideType = json['ride_type'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    // data['note_id'] = noteId;
    data['niveau'] = star;
    data['comment'] = comment;
    data['id_user_app'] = idUserApp;
    data['depart_name'] = departName;
    data['distance_unit'] = distanceUnit;
    data['destination_name'] = destinationName;
    data['latitude_depart'] = latitudeDepart;
    data['longitude_depart'] = longitudeDepart;
    data['vehicle_id'] = vehicle_id;
    data['rental_package_id'] = rental_package_id;
    data['latitude_arrivee'] = latitudeArrivee;
    data['longitude_arrivee'] = longitudeArrivee;
    data['number_poeple'] = vehicleTypeName;
    data['place'] = place;
    // data['note_id'] = noteId;
    data['statut'] = statut;
    data['advance_payment'] = this.advancePayment;
    data['total_amount'] = this.totalAmount;
    data['id_conducteur'] = idConducteur;
    data['creer'] = creer;
    data['trajet'] = trajet;
    data['trip_objective'] = tripObjective;
    data['trip_category'] = tripCategory;
    data['nom'] = nom;
    data['prenom'] = prenom;
    data['otp'] = otp;
    data['distance'] = distance;
    data['phone'] = phone;
    data['nomConducteur'] = nomConducteur;
    data['prenomConducteur'] = prenomConducteur;
    data['driverPhone'] = driverPhone;
    data['photo_path'] = photoPath;
    data['date_retour'] = dateRetour;
    data['heure_retour'] = heureRetour;
    data['statut_round'] = statutRound;
    data['montant'] = montant;
    data['duree'] = duree;
    data['statut_paiement'] = paymentStatus;
    data['payment'] = payment;
    data['payment_image'] = paymentImage;
    data['idVehicule'] = idVehicule;
    data['brand'] = brand;
    data['model'] = model;
    data['car_make'] = carMake;
    data['milage'] = milage;
    data['km'] = km;
    data['color'] = color;
    data['numberplate'] = numberplate;
    data['passenger'] = passenger;
    data['driver_phone'] = driverPhone;
    data['moyenne'] = moyenne;
    data['moyenne_driver'] = moyenneDriver;
    data['tax_amount'] = this.taxAmount;
    data['extra_km_charge'] = this.extraKmCharge;
    data['extra_min_charge'] = this.extraMinCharge;
    data['toll_parking_charge'] = this.tollParkingCharge;
    data['type'] = this.type;
    if (this.packageDetails != null) {
      data['package_details'] = this.packageDetails!.toJson();
    }
    data['ride_type'] = rideType;
    if (stops!.isNotEmpty) {
      data['stops'] = stops!.map((v) => v.toJson()).toList();
    } else {
      data['stops'] = [];
    }
    data['tax'] = taxModel != null ? taxModel!.map((v) => v.toJson()).toList() : null;
    data['received_comment'] = receivedComment;
    data['received_rating'] = receivedRating;
    data['given_rating'] = givenRating;
    data['given_comment'] = givenComment;
    data['admin_commission'] = this.adminCommission;
    data['fare_price'] = this.farePrice;
    data['remaining_payment'] = this.remainingPayment;



    return data;
  }
}

class Stops {
  String? latitude;
  String? location;
  String? longitude;

  Stops({this.latitude, this.location, this.longitude});

  Stops.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'].toString();
    location = json['location'].toString();
    longitude = json['longitude'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['location'] = location;
    data['longitude'] = longitude;
    return data;
  }
}

class PackageDetails {
  int? id;
  int? hours;
  int? kilometers;
  String? status;
  String? updatedAt;
  String? createdAt;

  PackageDetails({this.id, this.hours, this.kilometers, this.status, this.updatedAt, this.createdAt});

  PackageDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hours = json['hours'];
    kilometers = json['kilometers'];
    status = json['status']?.toString();
    updatedAt = json['updated_at']?.toString();
    createdAt = json['created_at']?.toString();
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
