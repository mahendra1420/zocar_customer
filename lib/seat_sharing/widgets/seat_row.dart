import 'package:zocar/seat_sharing/widgets/seat_widget.dart';
import 'package:zocar/utils/preferences.dart';
import 'package:flutter/material.dart';

import '../models/seat.dart';

class SeatRow extends StatelessWidget {
  final List<Seat> rowSeats;
  final int rowIndex;
  final bool showAddRemoveButtons;
  final void Function()? onAddSeat;
  final void Function(Seat seat)? onRemoveSeat;
  final void Function(Seat seat)? onTap;

  const SeatRow({super.key, required this.rowSeats, required this.rowIndex, this.showAddRemoveButtons = false, this.onAddSeat, this.onRemoveSeat, this.onTap});

  int get userId => Preferences.getInt(Preferences.userId);


  @override
  Widget build(BuildContext context) {
    if (rowSeats.length >= 4) {
      final leftSeats = rowSeats.take(2).toList();
      final rightSeats = rowSeats.skip(2).toList();

      return Row(
        children: [
          if (showAddRemoveButtons) SizedBox(width: 30),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...leftSeats.map((seat) => _buildSeatWithControls(seat, rowIndex)),
                    const SizedBox(width: 20),
                    ...rightSeats.take(2).map((seat) => _buildSeatWithControls(seat, rowIndex)),
                  ],
                ),
                if (rightSeats.length > 2)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: rightSeats.skip(2).map((seat) => _buildSeatWithControls(seat, rowIndex)).toList(),
                  ),
              ],
            ),
          ),
          if (showAddRemoveButtons) IconButton(onPressed: onAddSeat, icon: Icon(Icons.add_circle, color: rowSeats.length >= 4 ? Colors.grey : Colors.blue))
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showAddRemoveButtons) SizedBox(width: 30),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: rowSeats.map((seat) => _buildSeatWithControls(seat, rowIndex)).toList(),
            ),
          ),
          if (showAddRemoveButtons) IconButton(onPressed: onAddSeat, icon: Icon(Icons.add_circle, color: rowSeats.length >= 4 ? Colors.grey : Colors.blue))
        ],
      );
    }
  }

  Widget _buildSeatWithControls(Seat seat, int rowIndex) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SeatWidget(
            seat: seat,
            onTap: onTap == null ? null : () => onTap!(seat),
          ),
        ),
        if (seat.bookedBy?.toString() == userId.toString())
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Icon(Icons.account_circle_rounded, color: Colors.red, size: 8),
            ),
          ),
        if (!seat.isDriver && showAddRemoveButtons)
          PositionedDirectional(
            top: -15,
            end: -15,
            child: IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red, size: 16),
              onPressed: onRemoveSeat != null ? () => onRemoveSeat!(seat) : null,
            ),
          ),
      ],
    );
  }
}
