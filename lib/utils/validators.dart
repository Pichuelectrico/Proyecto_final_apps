bool isValidEmail(String value) {
  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  return regex.hasMatch(value);
}

bool isValidPassword(String value) {
  return value.length >= 6;
}
