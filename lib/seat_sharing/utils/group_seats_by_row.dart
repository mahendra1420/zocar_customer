import '../models/seat.dart';

List<List<Seat>> groupSeatsByRow(List<Seat> seats) {
  Map<int, List<Seat>> rowMap = {};

  for (var seat in seats) {
    rowMap.putIfAbsent(seat.row, () => []);
    rowMap[seat.row]!.add(seat);
  }

  // --- sorting of seats within each row by positions ---
  rowMap.forEach((key, value) {
    value.sort((a, b) => a.position.compareTo(b.position));
  });

  final sortedRows = rowMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

  return sortedRows.map((e) => e.value).toList();
}