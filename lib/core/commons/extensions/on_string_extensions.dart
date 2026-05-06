extension NullableStringExtensions on String? {
  bool get isNotEmptyOrNull {
    return (this ?? "").isNotEmpty;
  }
}