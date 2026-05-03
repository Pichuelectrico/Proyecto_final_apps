String formatFriendName(String? name, String email) {
  if (name != null && name.trim().isNotEmpty) {
    return name.trim();
  }
  return email.split('@').first;
}
