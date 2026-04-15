import 'package:flutter/material.dart';

extension GetRideStatusEnum on int {
  RideStatus rideStatusEnum(DateTime departureTime) {
    final x = RideStatus.values.where((element) => element.code == this).firstOrNull ?? RideStatus.upcoming;
    if(x == RideStatus.upcoming && departureTime.difference(DateTime.now()).inSeconds < 1){
      return RideStatus.notStarted;
    } else {
      return x;
    }
  }
}

enum RideStatus {
  upcoming(0, "Upcoming", Colors.blue, Icons.schedule),
  notStarted(0, "Not Started", Colors.blue, Icons.schedule),
  started(1, "Started", Colors.indigo, Icons.play_arrow),
  cancelled(2, "Cancelled", Colors.red, Icons.cancel),
  completed(3, "Completed", Colors.green, Icons.check_circle),
  ;

  final int code;
  final String displayName;
  final MaterialColor color;
  final IconData icon;

  const RideStatus(this.code, this.displayName, this.color, this.icon);
}
