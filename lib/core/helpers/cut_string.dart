String cutNameToTwoWords(String name) {
  if (name.trim().isEmpty) return "";

  final parts = name.trim().split(RegExp(r"\s+"));
  if (parts.length <= 2) return parts.join(" ");

  return "${parts[0]} ${parts[1]}";
}
