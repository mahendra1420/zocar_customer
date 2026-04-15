// import 'package:cabme_driver/helpers/loader.dart';
// import 'package:cabme_driver/helpers/navigation.dart';
// import 'package:cabme_driver/helpers/widget_binding.dart';
// import 'package:cabme_driver/seat_sharing/models/route_pricing.dart';
// import 'package:cabme_driver/seat_sharing/models/saved_layouts.dart';
// import 'package:cabme_driver/seat_sharing/repo/seat_sharing_repo.dart';
// import 'package:cabme_driver/seat_sharing/screens/pricing_setup_screen.dart';
// import 'package:cabme_driver/seat_sharing/widgets/seat_row.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../controllers/seat_sharing_controller.dart';
// import '../models/ride_details.dart';
// import '../models/seat.dart';
// import '../utils/group_seats_by_row.dart';
// import '../widgets/saved_layout_dropdown.dart';
// import 'search_seat_sharing_ride_screen.dart';
//
// class SeatLayoutScreen extends StatefulWidget {
//   final RideDetailsData? rideDetailsData;
//
//   const SeatLayoutScreen({super.key, this.rideDetailsData});
//
//   @override
//   State<SeatLayoutScreen> createState() => _SeatLayoutScreenState();
// }
//
// class _SeatLayoutScreenState extends State<SeatLayoutScreen> {
//   final ctr = Get.find<SeatSharingController>();
//
//   final _formKey = GlobalKey<FormState>();
//   final repo = SeatSharingRepo();
//   List<Seat> seats = [];
//   String vehicleType = "5-Seater Car";
//   final vehicleNameCtr = TextEditingController();
//   final vehicleNumberCtr = TextEditingController();
//
//   SavedLayout? selectedLayout;
//
//   bool get isEdit => widget.rideDetailsData != null;
//
//   List<Seat> get editRideSeats => widget.rideDetailsData?.seats ?? [];
//
//   List<RoutePricing> get editRidePricing => widget.rideDetailsData?.pricing ?? [];
//
//   @override
//   void initState() {
//     super.initState();
//
//     widgetBinding((_) async {
//       await _initializeDefaultLayout();
//     });
//   }
//
//   Future<void> _initializeDefaultLayout() async {
//     if (isEdit) {
//       seats = editRideSeats;
//       vehicleNameCtr.text = widget.rideDetailsData?.vehicleName ?? "";
//       vehicleNumberCtr.text = widget.rideDetailsData?.vehicleNumber ?? "";
//       setState(() {});
//     } else {
//       final isShowLoader = ctr.savedLayoutResponse == null;
//       if (isShowLoader) {
//         showLoader(context);
//         await ctr.getSavedLayouts();
//         hideLoader();
//       } else {
//         ctr.getSavedLayouts();
//       }
//       _updateSeats();
//     }
//   }
//
//   void _updateSeats() {
//     if (ctr.ridesList.isNotEmpty) {
//       final first = ctr.savedLayouts.first;
//       _selectLayout(first);
//     } else {
//       seats = Seat.defaultSeatsLayout;
//     }
//     setState(() {});
//   }
//
//   void _selectLayout(SavedLayout layout) {
//     selectedLayout = layout;
//     vehicleNameCtr.text = layout.vehicleName;
//     vehicleNumberCtr.text = layout.vehicleNumber;
//     seats = layout.seats;
//   }
//
//   void _addSeat(int row) {
//     setState(() {
//       final rowSeats = seats.where((s) => s.row == row).toList();
//       if (rowSeats.length >= 4) return;
//       rowSeats.sort((a, b) => a.position.compareTo(b.position));
//
//       final hasDriver = rowSeats.any((s) => s.isDriver);
//
//       if (hasDriver) {
//         final driverSeat = rowSeats.lastWhere((s) => s.isDriver);
//         seats.remove(driverSeat);
//         //
//         final newLabel = _generateSeatLabel(row, rowSeats.length - 1);
//         seats.add(Seat(
//           label: newLabel,
//           row: row,
//           position: rowSeats.length - 1,
//         ));
//         //
//         seats.add(driverSeat.copyWith(position: rowSeats.length));
//       } else {
//         final newLabel = _generateSeatLabel(row, rowSeats.length);
//         seats.add(Seat(
//           label: newLabel,
//           row: row,
//           position: rowSeats.length,
//         ));
//       }
//
//       _updateVehicleType();
//     });
//   }
//
//   void _removeSeat(int row, int position) {
//     setState(() {
//       seats.removeWhere((s) => s.row == row && s.position == position);
//       _reorderSeatsInRow(row);
//       _updateVehicleType();
//     });
//   }
//
//   void _addNewRow() {
//     setState(() {
//       final maxRow = seats.isEmpty ? 0 : seats.map((s) => s.row).reduce((a, b) => a > b ? a : b);
//       final newRow = maxRow + 1;
//
//       seats.add(Seat(label: _generateSeatLabel(newRow, 0), row: newRow, position: 0));
//       seats.add(Seat(label: _generateSeatLabel(newRow, 1), row: newRow, position: 1));
//
//       _updateVehicleType();
//     });
//   }
//
//   String _generateSeatLabel(int row, int position) {
//     // if (row == 0 && position == 0) return "D";
//     if (row == 0) return "P${position + 1}";
//     return "R${row}S${position + 1}";
//   }
//
//   void _reorderSeatsInRow(int row) {
//     final rowSeats = seats.where((s) => s.row == row).toList();
//     rowSeats.sort((a, b) => a.position.compareTo(b.position));
//
//     for (int i = 0; i < rowSeats.length; i++) {
//       rowSeats[i].position = i;
//       if (!rowSeats[i].isDriver) {
//         rowSeats[i].label = _generateSeatLabel(row, i);
//       }
//     }
//   }
//
//   void _updateVehicleType() {
//     final totalSeats = seats.length;
//     final rowCount = seats.map((s) => s.row).toSet().length;
//     final firstRowOnlyDriver = seats.where((element) => element.row == 0).length == 1;
//
//     if (totalSeats == 1) {
//       vehicleType = "Single Seat (Invalid)";
//     } else if (rowCount >= 2 && totalSeats <= 2 && firstRowOnlyDriver) {
//       vehicleType = "Bike";
//     } else if (totalSeats <= 4 && rowCount == 2 && firstRowOnlyDriver) {
//       vehicleType = "Rickshaw";
//     } else if (totalSeats <= 5) {
//       vehicleType = "$totalSeats-Seater Car";
//     } else if (totalSeats <= 9) {
//       vehicleType = "$totalSeats-Seater Van";
//     } else {
//       vehicleType = "$totalSeats-Seater Bus";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final rows = groupSeatsByRow(seats);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(vehicleType),
//         centerTitle: true,
//         scrolledUnderElevation: 0,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   if (!isEdit) ...[
//                     SavedLayoutDropdown(
//                       savedLayouts: ctr.savedLayouts,
//                       selectedLayout: selectedLayout,
//                       onChanged: (value) {
//                         selectedLayout = value;
//                         if (value != null) {
//                           _selectLayout(value);
//                         } else {
//                           seats = Seat.defaultSeatsLayout;
//                         }
//                         setState(() {});
//                       },
//                     ),
//                     const SizedBox(height: 8),
//                   ],
//                   TextFormField(
//                     readOnly: isEdit || (selectedLayout != null),
//                     decoration: const InputDecoration(
//                       labelText: 'Vehicle Name',
//                       border: OutlineInputBorder(),
//                     ),
//                     controller: vehicleNameCtr,
//                     textCapitalization: TextCapitalization.words,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter Vehicle Name';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 8),
//                   TextFormField(
//                     controller: vehicleNumberCtr,
//                     textCapitalization: TextCapitalization.characters,
//                     readOnly: isEdit || (selectedLayout != null),
//                     decoration: const InputDecoration(
//                       labelText: 'Vehicle Number',
//                       hintText: "AB01CD0000",
//                       hintStyle: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter Vehicle Number';
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 12),
//                   const Text(
//                     "Seat Layout",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 35),
//
//                   /// --- SEATS LAYOUTS ---
//                   ///
//                   ...rows.asMap().entries.map((entry) {
//                     final rowIndex = entry.key;
//                     final rowSeats = entry.value;
//
//                     return SeatRow(
//                       rowSeats: rowSeats,
//                       rowIndex: rowIndex,
//                       showAddRemoveButtons: !isEdit && selectedLayout == null,
//                       onAddSeat: () => _addSeat(rowSeats.first.row),
//                       onRemoveSeat: (seat) => _removeSeat(seat.row, seat.position),
//                       onTap: (seat) {
//                         if (!seat.isDriver) {
//                           setState(() {
//                             seat.isBooked = !seat.isBooked;
//                           });
//                         }
//                       },
//                     );
//                   }).toList(),
//
//                   ///
//                   ///
//
//                   const SizedBox(height: 35),
//
//                   if (!isEdit && selectedLayout == null) ...[
//                     ElevatedButton.icon(
//                       onPressed: _addNewRow,
//                       icon: const Icon(Icons.add),
//                       label: const Text("Add New Row"),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//
//                   const Text(
//                     "Legend:",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildLegendItem(Colors.blue, "Driver"),
//                       _buildLegendItem(Colors.green, "Available"),
//                       _buildLegendItem(Colors.red, "Booked"),
//                     ],
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   Text(
//                     "Total Seats: ${seats.length}",
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                       label: Text(isEdit ? "Next" : "Route Setup"),
//                       icon: Icon(isEdit ? Icons.arrow_circle_right_outlined : Icons.route),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: seats.length <= 1 ? Colors.grey : Colors.blue,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       onPressed: seats.length <= 1
//                           ? null
//                           : () {
//                               if (_formKey.currentState!.validate()) {
//                                 FocusManager.instance.primaryFocus?.unfocus();
//                                 _formKey.currentState!.save();
//                                 if (isEdit) {
//                                   context.push(PricingSetupScreen(
//                                     isEdit: isEdit,
//                                     seats: seats,
//                                     stops: widget.rideDetailsData?.stops ?? [],
//                                     rideId: widget.rideDetailsData?.id.toString(),
//                                     pricing: widget.rideDetailsData?.pricing,
//                                     departureTime: widget.rideDetailsData?.departureDateTime ?? DateTime.now(),
//                                     vehicleName: widget.rideDetailsData?.vehicleName ?? "",
//                                     vehicleNumber: widget.rideDetailsData?.vehicleNumber ?? "",
//                                     selectedLayout: selectedLayout,
//                                   ));
//                                 } else {
//                                   context.push(RouteSetupScreen(
//                                     seats: seats,
//                                     vehicleName: vehicleNameCtr.text.trim(),
//                                     vehicleNumber: vehicleNumberCtr.text.trim(),
//                                     selectedLayout: selectedLayout,
//                                   ));
//                                 }
//                               }
//                             }),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLegendItem(Color color, String label) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 16,
//           height: 16,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//         const SizedBox(width: 4),
//         Text(label),
//       ],
//     );
//   }
// }
//
// // List<List<Seat>> _groupSeatsByRow() {
// //   Map<int, List<Seat>> rowMap = {};
// //
// //   for (var seat in seats) {
// //     rowMap.putIfAbsent(seat.row, () => []);
// //     rowMap[seat.row]!.add(seat);
// //   }
// //
// //   // --- sorting of seats within each row by positions ---
// //   rowMap.forEach((key, value) {
// //     value.sort((a, b) => a.position.compareTo(b.position));
// //   });
// //
// //   final sortedRows = rowMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
// //
// //   return sortedRows.map((e) => e.value).toList();
// // }
//
// // Widget _buildSeatRow(List<Seat> rowSeats, int rowIndex) {
// //   // --- for rows with more than 4 seat -- arrange in 2-2 format
// //   if (rowSeats.length >= 4) {
// //     final leftSeats = rowSeats.take(2).toList();
// //     final rightSeats = rowSeats.skip(2).toList();
// //
// //     return Row(
// //       children: [
// //         SizedBox(width: 30),
// //         Expanded(
// //           child: Column(
// //             children: [
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   ...leftSeats.map((seat) => _buildSeatWithControls(seat, rowIndex)),
// //                   const SizedBox(width: 20), // --- space that look like in bus
// //                   ...rightSeats.take(2).map((seat) => _buildSeatWithControls(seat, rowIndex)),
// //                 ],
// //               ),
// //               if (rightSeats.length > 2)
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: rightSeats.skip(2).map((seat) => _buildSeatWithControls(seat, rowIndex)).toList(),
// //                 ),
// //             ],
// //           ),
// //         ),
// //         if (selectedLayout == null)
// //           IconButton(onPressed: () => _addSeat(rowSeats.first.row), icon: Icon(Icons.add_circle, color: rowSeats.length >= 4 ? Colors.grey : Colors.blue))
// //       ],
// //     );
// //   } else {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         SizedBox(width: 30),
// //         Expanded(
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: rowSeats.map((seat) => _buildSeatWithControls(seat, rowIndex)).toList(),
// //           ),
// //         ),
// //         if (selectedLayout == null)
// //           IconButton(onPressed: () => _addSeat(rowSeats.first.row), icon: Icon(Icons.add_circle, color: rowSeats.length >= 4 ? Colors.grey : Colors.blue))
// //       ],
// //     );
// //   }
// // }
//
// // Widget _buildSeatWithControls(Seat seat, int rowIndex) {
// //   return Stack(
// //     children: [
// //       Padding(
// //         padding: const EdgeInsets.all(2.0),
// //         child: SeatWidget(
// //           seat: seat,
// //           onTap: () {
// //             if (!seat.isDriver) {
// //               setState(() {
// //                 seat.isBooked = !seat.isBooked;
// //               });
// //             }
// //           },
// //         ),
// //       ),
// //       if (!seat.isDriver && (selectedLayout == null))
// //         PositionedDirectional(
// //           top: -15,
// //           end: -15,
// //           child: IconButton(
// //             icon: const Icon(Icons.remove_circle, color: Colors.red, size: 16),
// //             onPressed: () => _removeSeat(seat.row, seat.position),
// //           ),
// //         ),
// //     ],
// //   );
// // }
