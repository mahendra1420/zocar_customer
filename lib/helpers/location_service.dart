import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zocar/helpers/to_address_ext.dart';

import 'devlog.dart';

class LocationModel {
  BitmapDescriptor get mapIcon => _mapIcon ?? BitmapDescriptor.defaultMarker;
  final BitmapDescriptor? _mapIcon;
  final String fullAddress;
  final String? placeName;
  final String? area;
  final String? landmark;
  final String? pincode;
  final String? city;
  final String? state;
  final String? country;
  final String? userName;
  final String? userMobile;
  final LatLng latLng;
  String? dropStatus;

  LocationModel({
    BitmapDescriptor? mapIcon,
    required this.fullAddress,
    this.placeName,
    this.area,
    this.landmark = "",
    this.pincode,
    this.city,
    this.state,
    this.country,
    this.userName,
    this.userMobile,
    required this.latLng,
    this.dropStatus,
  }) : _mapIcon = mapIcon ?? BitmapDescriptor.defaultMarker;

  LocationModel copyWith({
    String? name,
    String? address,
    String? area,
    String? landmark,
    String? pincode,
    String? city,
    String? state,
    String? country,
    LatLng? latLng,
    String? userName,
    String? userMobile,
    String? dropStatus,
    BitmapDescriptor? mapIcon,
  }) {
    return LocationModel(
      placeName: name ?? this.placeName,
      fullAddress: address ?? this.fullAddress,
      area: area ?? this.area,
      landmark: landmark ?? this.landmark,
      pincode: pincode ?? this.pincode,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latLng: latLng ?? this.latLng,
      userName: userName ?? this.userName,
      userMobile: userMobile ?? this.userMobile,
      dropStatus: dropStatus ?? this.dropStatus,
      mapIcon: mapIcon ?? this.mapIcon,
    );
  }
}

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  LocationService._internal();

  final StreamController<Position> _locationStreamController = StreamController<Position>.broadcast();

  Stream<Position> get locationStream => _locationStreamController.stream;
  Position? _currentPosition;

  Position? get currentPosition => _currentPosition;

  LatLng? get currentLatlng => (currentPosition == null) ? null : LatLng(currentPosition!.latitude, currentPosition!.longitude);

  bool _isListening = false;

  Future<bool> init(BuildContext context, {bool showDialogOnDeniedForever = true}) async {
    final permission = await handlePermission(context, showDialogOnDeniedForever);
    if (permission) {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _locationStreamController.add(_currentPosition!);
      _startListening();
    }
    return permission;
  }

  Future<LatLng?> getCurrentLatlng(BuildContext context, {bool showDialogOnDeniedForever = true}) async {
    final permission = await handlePermission(context, showDialogOnDeniedForever);
    if (permission) {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return (currentPosition == null) ? null : LatLng(currentPosition!.latitude, currentPosition!.longitude);
    }
    return null;
  }

  Future<bool> handlePermission(BuildContext context, bool showDialogOnDeniedForever) async {
    devlog("handlePermission 1");
    LocationPermission permission = await Geolocator.checkPermission();

    devlog("handlePermission 2");
    if (permission == LocationPermission.denied) {
      devlog("handlePermission 3");
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      devlog("handlePermission 4");
      if (showDialogOnDeniedForever) {
        devlog("handlePermission 5");
        _showPermissionDialog(context);
      }
      return false;
    }
    devlog("handlePermission 6");

    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  void _startListening() {
    if (_isListening) return;
    _isListening = true;

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _locationStreamController.add(position);
    });
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Location Permission Required"),
        content: const Text("Location permissions are permanently denied. Please enable them in settings."),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text("Settings"),
            onPressed: () {
              Geolocator.openAppSettings();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void dispose() {
    _locationStreamController.close();
  }

  static String formatAddress(String name, String? newname) {
    if (name.contains('+') || name.toLowerCase().contains('unnamed road') || name.trim() == "") {
      return (newname?.isNotEmpty ?? true) ? (newname ?? "") : name;
    }
    return name;
  }

  static Future<LocationModel?> fetchAddressDetail(LatLng position, {bool fetchAddress = true}) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];

      String name = place.name ?? "";
      name = formatAddress(name, place.street);
      name = formatAddress(name, place.subLocality);
      name = formatAddress(name, place.locality);
      name = formatAddress(name, place.administrativeArea);
      name = formatAddress(name, "No Address Found");

      String area = place.subLocality ?? "";
      area = formatAddress(area, place.street);
      area = formatAddress(area, name);

      final addressList = [name, place.subLocality, place.locality, place.administrativeArea, place.postalCode];
      final address = addressList.toAddress;
      final location = LocationModel(
        fullAddress: address,
        area: area,
        pincode: place.postalCode ?? "",
        city: place.locality ?? "",
        state: place.administrativeArea ?? "",
        country: place.country ?? "",
        latLng: position,
      );
      return location;
    } catch (e) {
      devlogError("No address information found for supplied coordinates : $position");
    }
    return null;
  }
}
