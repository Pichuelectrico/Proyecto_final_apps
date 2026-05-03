class Friend {
  final String id;
  final String nombre;
  final String email;
  final String? avatarUrl;

  Friend({
    required this.id,
    required this.nombre,
    required this.email,
    this.avatarUrl,
  });
}
