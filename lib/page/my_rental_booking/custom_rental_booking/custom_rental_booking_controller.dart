import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../helpers/devlog.dart';
import '../../../service/api.dart';
import 'custom_rental_vehicle_model.dart';

class CustomRentalBookingController extends GetxController {
  // Form state
  final Rx<DateTime?> pickupDateTime = Rx(null);
  final Rx<DateTime?> dropDateTime = Rx(null);
  final RxDouble totalKm = 0.0.obs;

  // Derived
  final RxDouble totalHours = 0.0.obs;
  final RxList<CustomRentalVehicle> vehicles = <CustomRentalVehicle>[].obs;
  final RxBool isLoadingVehicles = false.obs;
  final Rx<CustomRentalVehicle?> selectedVehicle = Rx(null);

  final Map<String, CustomRentalVehicle> _catalogById = {};
  // Location
  String latitude = '';
  String longitude = '';
  String departureName = '';

  @override
  void onInit() {
    super.onInit();
    ever(pickupDateTime, (_) => _recalcHours());
    ever(dropDateTime, (_) => _recalcHours());
    ever(totalKm, (_) => fetchCalculatedPrices());
  }

  void _recalcHours() {
    final p = pickupDateTime.value;
    final d = dropDateTime.value;
    if (p == null || d == null) {
      totalHours.value = 0;
      fetchCalculatedPrices();
      return;
    }
    final diff = d.difference(p);
    totalHours.value =
        diff.isNegative ? 0 : double.parse((diff.inMinutes / 60).toStringAsFixed(1));
    fetchCalculatedPrices();
  }

  double priceFor(CustomRentalVehicle v) =>
      v.calculatePrice(km: totalKm.value, hours: totalHours.value);

  double get selectedPrice =>
      selectedVehicle.value == null ? 0 : priceFor(selectedVehicle.value!);

  double get advanceAmount => double.parse(selectedPrice.toStringAsFixed(2));

  Future<void> loadVehicleCatalog() async {
    isLoadingVehicles.value = true;
    try {
      final body = jsonEncode({'latitude': latitude, 'longitude': longitude});
      final response = await LoggingClient(http.Client()).post(
        Uri.parse(API.getCustomRentalVehicles),
        body: body,
        headers: API.header,
      );
      final responseBody = json.safeDecode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == 'success') {
        _catalogById.clear();
        for (final e in (responseBody['data'] as List)) {
          final v = CustomRentalVehicle.fromJson(e as Map<String, dynamic>);
          _catalogById[v.id] = v;
        }
      }
    } catch (e) {
      devlogError('loadVehicleCatalog error: $e');
    } finally {
      isLoadingVehicles.value = false;
    }
    await fetchCalculatedPrices();
  }

  Future<void> fetchCalculatedPrices() async {
    final p = pickupDateTime.value;
    final d = dropDateTime.value;
    final km = totalKm.value;

    if (p == null || d == null || km <= 0 || totalHours.value <= 0) {
      vehicles.clear();
      selectedVehicle.value = null;
      return;
    }

    isLoadingVehicles.value = true;
    try {
      final body = jsonEncode({
        'pickup_date': DateFormat('yyyy-MM-dd').format(p),
        'pickup_time': DateFormat('HH:mm').format(p),
        'drop_date': DateFormat('yyyy-MM-dd').format(d),
        'drop_time': DateFormat('HH:mm').format(d),
        'total_km': km.round(),
      });

      final response = await LoggingClient(http.Client()).post(
        Uri.parse(API.rentalCalculate),
        body: body,
        headers: API.header,
      );
      final responseBody = json.safeDecode(response.body);

      final success = responseBody['success'] == true ||
          responseBody['success']?.toString().toLowerCase() == 'success';

      if (response.statusCode == 200 && success && responseBody['data'] is List) {
        final prevId = selectedVehicle.value?.id;
        final list = (responseBody['data'] as List)
            .map((e) {
              final m = e as Map<String, dynamic>;
              final vid = m['vehicle_id']?.toString() ?? '';
              return CustomRentalVehicle.fromRentalCalculateJson(
                m,
                catalogMatch: _catalogById[vid],
              );
            })
            .toList();

        vehicles.assignAll(list);

        if (prevId != null) {
          CustomRentalVehicle? found;
          for (final v in vehicles) {
            if (v.id == prevId) {
              found = v;
              break;
            }
          }
          selectedVehicle.value = found;
        }
      } else {
        ShowToastDialog.showToast(
          responseBody['error']?.toString() ??
              responseBody['message']?.toString() ??
              'Could not load prices',
        );
        vehicles.clear();
        selectedVehicle.value = null;
      }
    } catch (e) {
      devlogError('fetchCalculatedPrices error: $e');
      vehicles.clear();
      selectedVehicle.value = null;
    } finally {
      isLoadingVehicles.value = false;
    }
  }
}
