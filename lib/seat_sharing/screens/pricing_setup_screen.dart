//
//
// import 'package:cabme_driver/constant/show_toast_dialog.dart';
// import 'package:cabme_driver/helpers/devlog.dart';
// import 'package:cabme_driver/helpers/loader.dart';
// import 'package:cabme_driver/seat_sharing/models/saved_layouts.dart';
// import 'package:cabme_driver/seat_sharing/repo/seat_sharing_repo.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import '../../utils/Preferences.dart';
// import '../controllers/seat_sharing_controller.dart';
// import '../models/seat.dart';
// import '../models/route_stop.dart';
// import '../models/route_pricing.dart';
//
// class PricingSetupScreen extends StatefulWidget {
//   final bool isEdit;
//   final String? rideId;
//   final List<Seat> seats;
//   final List<RouteStop> stops;
//   final List<RoutePricing>? pricing;
//   final DateTime departureTime;
//   final String vehicleName;
//   final String vehicleNumber;
//   final SavedLayout? selectedLayout;
//
//   const PricingSetupScreen({
//     super.key,
//     this.isEdit = false,
//     this.rideId,
//     required this.seats,
//     required this.stops,
//     this.pricing,
//     required this.departureTime,
//     required this.vehicleName,
//     required this.vehicleNumber,
//     required this.selectedLayout,
//   });
//
//   @override
//   State<PricingSetupScreen> createState() => _PricingSetupScreenState();
// }
//
// class _PricingSetupScreenState extends State<PricingSetupScreen> {
//   final repo = SeatSharingRepo();
//   List<RoutePricing> pricing = [];
//   Map<String, TextEditingController> priceControllers = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _initializePricing();
//   }
//
//   void _initializePricing() {
//     if (widget.pricing != null) {
//       pricing = List.from(widget.pricing ?? []);
//       for (final p in pricing) {
//         final routeKey = '${p.fromStopId}_${p.toStopId}';
//         priceControllers[routeKey] = TextEditingController(text: p.price.toInt().toString());
//       }
//       devlog("pricing ; ${pricing.map((e) => e.price)}");
//     } else {
//       for (int i = 0; i < widget.stops.length; i++) {
//         for (int j = i + 1; j < widget.stops.length; j++) {
//           final fromStop = widget.stops[i];
//           final toStop = widget.stops[j];
//           final routeKey = '${fromStop.id}_${toStop.id}';
//
//           pricing.add(RoutePricing(
//             fromStopId: fromStop.id,
//             toStopId: toStop.id,
//             price: 0.0,
//           ));
//
//           priceControllers[routeKey] = TextEditingController();
//         }
//       }
//     }
//   }
//
//   bool _updatePricing() {
//     for (var route in pricing) {
//       final routeKey = '${route.fromStopId}_${route.toStopId}';
//       final controller = priceControllers[routeKey];
//       if (controller != null && controller.text.isNotEmpty) {
//         route.price = double.tryParse(controller.text) ?? 0.0;
//       } else {
//         ShowToastDialog.showToast("Enter price in all...", position: EasyLoadingToastPosition.center);
//         return false;
//       }
//     }
//     FocusManager.instance.primaryFocus?.unfocus();
//     return true;
//   }
//
//   String _getStopName(String stopId) {
//     return widget.stops.where((stop) => stop.stopId == stopId).firstOrNull?.name ?? stopId;
//   }
//
//   void _finalizeTripSetup() async {
//     final res = _updatePricing();
//     if (!res) return;
//
//     final driverId = Preferences.getInt(Preferences.userId);
//
//     if (widget.isEdit) {
//       final Map<String, dynamic> requestJson = {
//         "seat_sharing_vehicle_layout": widget.seats.map((e) => e.toJson()).toList(),
//         "seat_sharing_request_price": pricing.map((e) => e.toJson()).toList(),
//       };
//
//       devlog((requestJson).toString());
//
//       showLoader(context);
//       final response = await repo.updateSeatSharing(widget.rideId ?? "", requestJson);
//       hideLoader();
//
//       if (!response.$1) {
//         ShowToastDialog.showToast(response.$2);
//         return;
//       }
//     } else {
//       final Map<String, dynamic> requestJson = {
//         "driver_id": driverId,
//         "vehicle_name": widget.vehicleName,
//         "vehicle_number": widget.vehicleNumber,
//         "departure_time": widget.departureTime.toIso8601String(),
//         "layoutId": widget.selectedLayout?.id,
//         "seats": widget.seats.map((e) => e.toJson()).toList(),
//         "stops": widget.stops.map((e) => e.toJson()).toList(),
//         "pricing": pricing.map((e) => e.toJson()).toList(),
//       };
//
//       devlog((requestJson).toString());
//
//       showLoader(context);
//       final response = await repo.createSeatSharing(requestJson);
//       hideLoader();
//
//       if (!response.$1) {
//         ShowToastDialog.showToast(response.$2);
//         return;
//       }
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Trip ${widget.isEdit ? "Updated" : "Created"} Successfully!'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Total Seats: ${widget.seats.length}'),
//             Text('Total Stops: ${widget.stops.length}'),
//             Text('Total Routes: ${pricing.length}'),
//             const SizedBox(height: 10),
//             const Text('Trip is now ready for bookings!'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     ).then((_) {
//       final ctr = Get.find<SeatSharingController>();
//       ctr.getAllRides();
//       Navigator.popUntil(context, (route) => route.settings.name == "/mySeatSharingRides");
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pricing Setup'),
//         centerTitle: true,
//         scrolledUnderElevation: 0,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//             child: Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Trip Summary',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     Text('Seats: ${widget.seats.length}'),
//                     Text('Departure: ${widget.departureTime.day}/${widget.departureTime.month}/${widget.departureTime.year} '
//                         '${widget.departureTime.hour.toString().padLeft(2, '0')}:'
//                         '${widget.departureTime.minute.toString().padLeft(2, '0')}'),
//                     Text('Route: ${widget.stops.first.name} → ${widget.stops.last.name}'),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Set Prices for All Routes:',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16.0),
//               itemCount: pricing.length,
//               itemBuilder: (context, index) {
//                 final route = pricing[index];
//                 final fromStopName = _getStopName(route.fromStopId);
//                 final toStopName = _getStopName(route.toStopId);
//                 final routeKey = '${route.fromStopId}_${route.toStopId}';
//
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 3,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '$fromStopName → $toStopName',
//                                 style: const TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                 'Route ${index + 1}',
//                                 style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: TextField(
//                             controller: priceControllers[routeKey],
//                             decoration: const InputDecoration(
//                               labelText: 'Price (₹)',
//                               border: OutlineInputBorder(),
//                               prefixText: '₹ ',
//                             ),
//                             keyboardType: TextInputType.number,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _finalizeTripSetup,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: Text(
//                   widget.isEdit ? 'Update Trip' : 'Create Trip',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     for (var controller in priceControllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
// }
