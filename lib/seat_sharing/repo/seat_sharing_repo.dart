import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zocar/seat_sharing/models/my_rides_list.dart';

import '../../helpers/devlog.dart';
import '../../service/api.dart';
import '../../utils/preferences.dart';
import '../models/ride_details.dart';
import '../models/seat.dart';
import '../models/seat_sharing_rides.dart';

class SeatSharingRepo {
  Future<(bool status, String message)> bookSeats({
    required String rideId,
    required List<Seat> seats,
    required String? user_price_id,
    required String? user_from_stop_id,
    required String? user_to_stop_id,
    required String? razorpay_transaction_id,
    required String? user_pickup_point_id,
    required String? user_drop_point_id,
    required num? advance_payment,
  }) async {
    try {
      final userId = Preferences.getInt(Preferences.userId);
      final body = {
        "razorpay_transaction_id": razorpay_transaction_id,
        "advance_payment": advance_payment,
        "seat_book": seats
            .map((e) => e.bookSeatJson(
                  userId,
                  user_price_id: user_price_id,
                  user_from_stop_id: user_from_stop_id,
                  user_to_stop_id: user_to_stop_id,
                  user_pickup_point_id: user_pickup_point_id,
                  user_drop_point_id: user_drop_point_id,
                ))
            .toList()
      };
      final response = await LoggingClient(http.Client()).post(Uri.parse("${API.bookSeats}/$rideId"), headers: API.header, body: jsonEncode(body));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.safeDecode(response.body);
        final bool status = responseBody['status'];
        final String message = responseBody['message'];
        return (status, message);
      }
    } catch (e) {
      devlogError("error dfjdsfaerskdfjdsklfj :$e");
    }
    return (false, "Something went wrong");
  }

  Future<SeatSharingRidesResponse> seatSharingRides({
    required String from,
    required String to,
    required DateTime time,
  }) async {
    try {
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.searchRideList),
          headers: API.header,
          body: jsonEncode({
            "from": from,
            "to": to,
            "departure_time": time.toIso8601String(),
          }));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.safeDecode(response.body);
        return SeatSharingRidesResponse.fromJson(responseBody);
      }
      return SeatSharingRidesResponse(status: false, message: "Something went wrong.!!", data: []);
    } catch (e) {
      return SeatSharingRidesResponse(status: false, message: "Something went wrong.!!", data: []);
    }
  }

  Future<MyRidesListResponse> myRidesList() async {
    try {
      final userId = Preferences.getInt(Preferences.userId);
      final response = await LoggingClient(http.Client()).get(Uri.parse("${API.myRidesList}/$userId"), headers: API.header);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.safeDecode(response.body);
        return MyRidesListResponse.fromJson(responseBody);
      }
      return MyRidesListResponse(status: false, message: "Something went wrong.!!", data: []);
    } catch (e) {
      return MyRidesListResponse(status: false, message: "Something went wrong.!!", data: []);
    }
  }

  Future<RideDetailsResponse> rideDetails(String rideId, {required String fromId, required String toId}) async {
    try {
      // final data = {
      //   "from_stop_id": fromId,
      //   "to_stop_id": toId,
      // };
      final response = await LoggingClient(http.Client()).get(Uri.parse("${API.seatSharingRideDetails}/$rideId?from_stop_id=$fromId&to_stop_id=$toId"), headers: API.header);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        return RideDetailsResponse.fromJson(responseBody);
      }
      return RideDetailsResponse(status: false, message: "Something went wrong.!!", data: RideDetailsData.fromJson({}));
    } catch (e) {
      return RideDetailsResponse(status: false, message: "Something went wrong.!!", data: RideDetailsData.fromJson({}));
    }
  }
}
