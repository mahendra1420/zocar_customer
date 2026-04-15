extension ConvertToAddressExt on List<String?> {
  String get toAddress {
    return map((e) => e ?? "").where((ee) => ee.trim() != "").toList().join(", ");
  }
}

extension ConvertToAddressWithRemoveFirstExt on String? {
  String get toAddressWithRemoveFirst {
    List<String> list = this?.split(",").map((e) => e.toString().trim()).toList() ?? [];
    if (list.isNotEmpty) list.removeAt(0);
    return list.toAddress;
  }

  String get toAddressWithFirst {
    return this?.split(",").map((e) => e.toString().trim()).toList().firstOrNull ?? "-";
  }
}

extension StringUtilExts on String? {
  String? get emptyToNull => (this?.trim() ?? "") == "" ? null : this;
  bool get isEmptyOrNull => ((this?.trim() ?? "") == "");

  bool get isPDF => emptyToNull == null ? false : (this?.endsWith(".pdf") ?? false);
}
