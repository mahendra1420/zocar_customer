import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constant/show_toast_dialog.dart';
import '../../helpers/strings.dart';
import '../../utils/preferences.dart';

class TripDateTimeSelector extends StatefulWidget {
  final Function(DateTime dailyDateTime, bool isRoundTrip, DateTime startDateTime, DateTime? endDateTime)? onTripDetailsChanged;
  final bool isOutstation;
  final Future<void> Function()? onOkPressed;


  const TripDateTimeSelector({
    Key? key,
    this.onTripDetailsChanged,
    this.isOutstation = false,
    this.onOkPressed,

  }) : super(key: key);

  @override
  TripDateTimeSelectorState createState() => TripDateTimeSelectorState();
}

class TripDateTimeSelectorState extends State<TripDateTimeSelector> {
  bool isRoundTrip = false;
  DateTime startDateTime = DateTime.now().add(const Duration(hours: 1));
  DateTime? endDateTime;

  DateTime selectedDateTime = DateTime.now();

  Future<void> _pickDateTime() async {
    DateTime now = DateTime.now();

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(
        selectedDateTime.year,
        selectedDateTime.month,
        selectedDateTime.day,
      ),
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );

    if (time == null) return;

    DateTime combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // final rideSettings = Preferences.rideSettings;
    // final int delayMinutes = rideSettings?.scheduleRideStartDelay ?? 0;

    // final DateTime minAllowedDateTime = now.add( Duration(minutes: delayMinutes));
    //
    // if (combinedDateTime.isBefore(minAllowedDateTime)) {
    //   showToast("Please select a time at least $delayMinutes minutes from now");
    //   return;
    // }

    setState(() {
      selectedDateTime = combinedDateTime;
    });
    _notifyChanges();
    if (widget.onOkPressed != null) {
      await widget.onOkPressed!();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isOutstation) {
      endDateTime = startDateTime.add(const Duration(hours: 8));
    }
  }

  void _notifyChanges() {
    if (widget.onTripDetailsChanged != null) {
      widget.onTripDetailsChanged!(selectedDateTime, isRoundTrip, startDateTime, isRoundTrip ? endDateTime : null);
    }
  }

  Future<void> _pickStartDateTime() async {
    final DateTime now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: startDateTime,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(startDateTime),
    );

    if (time == null) return;

    final DateTime selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final DateTime nowDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );

    if (selectedDateTime.isBefore(nowDateTime)) {
      showToast(S.pleaseSelectFutureDateTime);
      return;
    }

    setState(() {
      startDateTime = selectedDateTime;

      if (isRoundTrip && endDateTime != null) {
        if (endDateTime!.isBefore(startDateTime) || endDateTime!.isAtSameMomentAs(startDateTime)) {
          endDateTime = startDateTime.add(const Duration(hours: 1));
        }
      }
    });

    _notifyChanges();

    // 🔥 CALL AFTER OK
    if (widget.onOkPressed != null) {
      await widget.onOkPressed!();
    }
  }

  Future<void> _pickEndDateTime() async {
    if (!isRoundTrip) return;

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: endDateTime ?? startDateTime.add(const Duration(hours: 1)),
      firstDate: DateTime(startDateTime.year, startDateTime.month, startDateTime.day),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(endDateTime ?? startDateTime.add(const Duration(hours: 1))),
    );

    if (time == null) return;

    final DateTime selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (selectedDateTime.isBefore(startDateTime) || selectedDateTime.isAtSameMomentAs(startDateTime)) {
      showToast(S.returnTimeMustBeAfterDeptTime);
      return;
    }

    setState(() {
      endDateTime = selectedDateTime;
    });

    _notifyChanges();
  }

  /// Call this from outside to open date-time picker
  Future<void> openDateTimePicker() async {
    if (widget.isOutstation) {
      await _pickStartDateTime();
    } else {
      await _pickDateTime();
    }
  }

  /// Optional: force round-trip selection externally
  void setRoundTrip(bool value) {
    setState(() {
      isRoundTrip = value;
      if (isRoundTrip && endDateTime == null) {
        endDateTime = startDateTime.add(const Duration(hours: 8));
      }
    });
    _notifyChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isOutstation) ...[
          SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Text(
                  S.chooseDateAndTime,
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _pickDateTime,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.blue.shade700),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      DateFormat('dd-MM-yyyy, hh:mm a').format(selectedDateTime),
                      style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
        ] else ...[
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isRoundTrip = false;
                      });
                      _notifyChanges();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isRoundTrip ? Colors.grey.shade200 : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(7),
                          bottomLeft: Radius.circular(7),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(
                              !isRoundTrip ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: !isRoundTrip ? Colors.blue : Colors.grey,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.oneWayTrip,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                S.dropCabOff,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Round Trip Option
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isRoundTrip = true;
                        if (endDateTime == null) {
                          endDateTime = startDateTime.add(const Duration(hours: 8));
                        }
                      });
                      _notifyChanges();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isRoundTrip ? Colors.grey.shade200 : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(
                              isRoundTrip ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isRoundTrip ? Colors.red : Colors.grey,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.roundTrip,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                S.keepCabTillReturn,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Start Date Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.tripStartsAt,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 3),
              InkWell(
                onTap: _pickStartDateTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(startDateTime),
                        style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // End Date Time (only for Round Trip)
          // if (isRoundTrip)
          AnimatedSize(
            duration: Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: isRoundTrip ? null : 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.tripEndsAt,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      InkWell(
                        onTap: _pickEndDateTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.blue.shade700, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(endDateTime ?? startDateTime.add(const Duration(hours: 8))),
                                style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]
      ],
    );
  }
}
// import 'dart:async';
//
// import 'package:zocar/constant/constant.dart';
// import 'package:zocar/constant/logdata.dart';
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/controller/home_controller.dart';
// import 'package:zocar/helpers/callbacks.dart';
// import 'package:zocar/helpers/strings.dart';
// import 'package:zocar/model/vehicle_category_model.dart';
// import 'package:zocar/themes/button_them.dart';
// import 'package:zocar/themes/constant_colors.dart';
// import 'package:zocar/themes/text_field_them.dart';
// import 'package:zocar/utils/Preferences.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geocoding/geocoding.dart' as get_cord_address;
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:location/location.dart';
// import 'package:lottie/lottie.dart' as lottie;
// import 'package:url_launcher/url_launcher.dart';
//
// import '../../helpers/devlog.dart';
//
// class DateTimePickerContainer extends StatefulWidget {
//   final bool isOutstation;
//
//   const DateTimePickerContainer({super.key,  this.isOutstation = false});
//
//
//
//   @override
//   _DateTimePickerContainerState createState() => _DateTimePickerContainerState();
// }
//
// class _DateTimePickerContainerState extends State<DateTimePickerContainer> {
//   DateTime selectedDateTime = DateTime.now();
//
//   Future<void> _pickDateTime() async {
//     DateTime now = DateTime.now();
//
//     DateTime? date = await showDatePicker(
//       context: context,
//       initialDate: DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day),
//       firstDate: now,
//       lastDate: DateTime(2100),
//     );
//
//     if (date == null) return;
//
//     if (date.isBefore(now) && !(date.day == now.day && date.month == now.month && date.year == now.year)) {
//       showToast('Please select a future date.');
//       return;
//     }
//
//     TimeOfDay? time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.fromDateTime(selectedDateTime),
//     );
//
//     if (time == null) return;
//
//     DateTime combinedDateTime = DateTime(
//       date.year,
//       date.month,
//       date.day,
//       time.hour,
//       time.minute,
//     );
//
//     if (date.day == now.day && date.month == now.month && date.year == now.year) {
//       if (combinedDateTime.isBefore(now)) {
//         showToast('Please select a time after the current time.');
//         return;
//       }
//     }
//
//     setState(() {
//       selectedDateTime = combinedDateTime;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: _pickDateTime,
//       child: Container(
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.calendar_month, color: Colors.blue),
//             SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 DateFormat('dd-MM-yyyy hh:mm a').format(selectedDateTime),
//                 style: TextStyle(fontSize: 14),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
