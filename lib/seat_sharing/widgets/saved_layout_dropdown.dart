import 'package:flutter/material.dart';

import '../models/saved_layouts.dart';

class SavedLayoutDropdown extends StatelessWidget {
  final List<SavedLayout> savedLayouts;
  final SavedLayout? selectedLayout;
  final Function(SavedLayout?) onChanged;

  const SavedLayoutDropdown({
    super.key,
    required this.savedLayouts,
    required this.selectedLayout,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selectedLayout?.id,
      decoration: InputDecoration(border: const OutlineInputBorder(), hintText: "Select a layout", labelText: selectedLayout == null ? null : "Saved Layouts"),
      items: [
        ...savedLayouts.map((layout) {
          return DropdownMenuItem(
            value: layout.id,
            child: Text("${layout.vehicleName} (${layout.vehicleNumber})"),
          );
        }),
        const DropdownMenuItem<int>(
          value: null,
          child: Text("➕ Custom Layout"),
        ),
      ],
      onChanged: (value) {
        if (value == null) {
          onChanged(null);
        } else {
          onChanged(savedLayouts.firstWhere((element) => element.id == value));
        }
      },
    );
  }
}
