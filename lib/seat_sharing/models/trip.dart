
import 'package:zocar/seat_sharing/models/route_pricing.dart';
import 'package:zocar/seat_sharing/models/route_stop.dart';
import 'package:zocar/seat_sharing/models/seat.dart';

class Trip {
  String id;
  String driverId;
  List<Seat> seats;
  List<RouteStop> stops;
  List<RoutePricing> pricing;
  DateTime departureTime;
  String vehicleType;

  Trip({
    required this.id,
    required this.driverId,
    required this.seats,
    required this.stops,
    required this.pricing,
    required this.departureTime,
    required this.vehicleType,
  });
}