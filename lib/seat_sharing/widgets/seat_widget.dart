import 'package:flutter/material.dart';

import '../models/seat.dart';

class SeatWidget extends StatelessWidget {
  final Seat seat;
  final VoidCallback? onTap;
  final bool isSelectable;

  const SeatWidget({
    super.key,
    required this.seat,
    this.onTap,
    this.isSelectable = true,
  });

  @override
  Widget build(BuildContext context) {
    Color seatColor;
    IconData seatIcon;

    if (seat.isDriver) {
      seatColor = Colors.blue;
      seatIcon = Icons.drive_eta;
    } else if (seat.isBooked) {
      seatColor = Colors.red;
      seatIcon = Icons.event_seat;
    } else if (seat.isSelected) {
      seatColor = Colors.orange;
      seatIcon = Icons.event_seat;
    } else {
      seatColor = Colors.green;
      seatIcon = Icons.event_seat_outlined;
    }

    return GestureDetector(
      onTap: isSelectable ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(seatIcon, color: Colors.white, size: 20),
            Text(
              seat.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
