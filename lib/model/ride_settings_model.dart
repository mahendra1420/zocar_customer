
class RideSettings {
  int? driverDistanceAdvanceKm;
  int? requestCancelTime;
  int? scheduleRideStartDelay;
  double? rentalScheduleAdvancePercentage;
  double? simpleRideAdvancePercentage;
  int? rideCancelAfterAccept;

  RideSettings({
    this.driverDistanceAdvanceKm,
    this.requestCancelTime,
    this.scheduleRideStartDelay,
    this.rentalScheduleAdvancePercentage,
    this.simpleRideAdvancePercentage,
    this.rideCancelAfterAccept,
  });

  /// ---------- SAFE PARSERS ----------
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// ---------- FROM JSON ----------
  RideSettings.fromJson(Map<String, dynamic> json) {
    driverDistanceAdvanceKm = _toInt(json['driver_distance_advance_km']);
    requestCancelTime = _toInt(json['request_cancel_time']);
    scheduleRideStartDelay = _toInt(json['schedule_ride_start_delay']);
    rentalScheduleAdvancePercentage =
        _toDouble(json['rental_schedule_advance_percentage']);
    simpleRideAdvancePercentage =
        _toDouble(json['simple_ride_advance_percentage']);
    rideCancelAfterAccept =
        _toInt(json['ride_cancel_after_accept']);
  }

  /// ---------- TO JSON ----------
  Map<String, dynamic> toJson() {
    return {
      'driver_distance_advance_km': driverDistanceAdvanceKm,
      'request_cancel_time': requestCancelTime,
      'schedule_ride_start_delay': scheduleRideStartDelay,
      'rental_schedule_advance_percentage':
      rentalScheduleAdvancePercentage,
      'simple_ride_advance_percentage':
      simpleRideAdvancePercentage,
      'ride_cancel_after_accept': rideCancelAfterAccept,
    };
  }
}