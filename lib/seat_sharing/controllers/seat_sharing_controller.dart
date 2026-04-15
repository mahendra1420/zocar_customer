import 'package:zocar/seat_sharing/models/my_rides_list.dart';
import 'package:get/get.dart';

import '../../constant/show_toast_dialog.dart';
import '../models/seat_sharing_rides.dart';
import '../repo/seat_sharing_repo.dart';

class SeatSharingController extends GetxController {
  final repo = SeatSharingRepo();

  SeatSharingRidesResponse? get seatSharingRidesResponse => _seatSharingRidesResponse;
  SeatSharingRidesResponse? _seatSharingRidesResponse;

  List<SeatSharingRideData> get ridesList => seatSharingRidesResponse?.data ?? [];

  String _from = '';
  String _to = '';
  DateTime _time = DateTime.now();

  getAllRides({required String from, required String to, required DateTime time}) async {
    _from = from;
    _to = to;
    _time = time;
    final res = await repo.seatSharingRides(from: from, to: to, time: time);
    if (res.status) {
      _seatSharingRidesResponse = res;
    } else {
      ShowToastDialog.showToast(res.message);
    }
    update();
  }

  getAllRidesAgain() async {
    await getAllRides(from: _from, to: _to, time: _time);
  }

  ///
  ///

  MyRidesListResponse? get myRidesListResponse => _myRidesListResponse;
  MyRidesListResponse? _myRidesListResponse;

  List<MyRideData> get myRidesList => myRidesListResponse?.data ?? [];

  Future<void> getMyRidesList() async {
    final res = await repo.myRidesList();
    if (res.status) {
      _myRidesListResponse = res;
    } else {
      ShowToastDialog.showToast("Something went wrong.!");
    }
    update();
  }
}
