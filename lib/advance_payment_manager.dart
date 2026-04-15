// advance_payment_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

class AdvancePaymentManager {
  static const _keyRideId    = 'adv_pay_ride_id';
  static const _keyDriverId  = 'adv_pay_driver_id';
  static const _keyAmount    = 'adv_pay_amount';
  static const _keyDeadline  = 'adv_pay_deadline'; // epoch ms
  static const _keyTimerEnabled = 'adv_pay_timer_enabled';

  // Call this when notification arrives BEFORE showing the sheet
  static Future<void> save({
    required String rideId,
    required String driverId,
    required int amount,
    int timeoutSeconds = 120,
    bool timerEnabled = true,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyRideId,   rideId);
    await sp.setString(_keyDriverId, driverId);
    await sp.setInt(_keyAmount,      amount);
    await sp.setBool(_keyTimerEnabled, timerEnabled);
    if (timerEnabled) {
      final deadline = DateTime.now()
          .add(Duration(seconds: timeoutSeconds))
          .millisecondsSinceEpoch;
      await sp.setInt(_keyDeadline, deadline);
    } else {
      await sp.remove(_keyDeadline);
    }
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_keyRideId);
    await sp.remove(_keyDriverId);
    await sp.remove(_keyAmount);
    await sp.remove(_keyDeadline);
    await sp.remove(_keyTimerEnabled);
  }

  // Returns null if already expired or nothing pending
  static Future<PendingPayment?> getPending() async {
    final sp = await SharedPreferences.getInstance();
    await sp.reload(); // force fresh read after background
    final rideId   = sp.getString(_keyRideId);
    final driverId = sp.getString(_keyDriverId);
    final amount   = sp.getInt(_keyAmount);
    final deadline = sp.getInt(_keyDeadline);
    final timerEnabled = sp.getBool(_keyTimerEnabled) ?? true;

    if (rideId == null || amount == null) return null;

    if (!timerEnabled) {
      return PendingPayment(
        rideId: rideId,
        driverId: driverId ?? '',
        amount: amount,
        remaining: Duration.zero,
        timerEnabled: false,
      );
    }

    if (deadline == null) return null;

    final remaining = DateTime.fromMillisecondsSinceEpoch(deadline)
        .difference(DateTime.now());

    if (remaining.isNegative) {
      await clear(); // expired — clean up
      return null;
    }

    return PendingPayment(
      rideId:    rideId,
      driverId:  driverId ?? '',
      amount:    amount,
      remaining: remaining,
      timerEnabled: true,
    );
  }
}

// advance_payment_manager.dart

class PendingPayment {           // <-- was _PendingPayment
  final String rideId;
  final String driverId;
  final int amount;
  final Duration remaining;
  final bool timerEnabled;

  const PendingPayment({
    required this.rideId,
    required this.driverId,
    required this.amount,
    required this.remaining,
    required this.timerEnabled,
  });
}