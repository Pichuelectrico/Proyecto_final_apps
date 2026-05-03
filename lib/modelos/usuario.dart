class Usuario {
  final String id;
  final String email;
  final String? nombre;
  final String? avatarUrl;

  Usuario({
    required this.id,
    required this.email,
    this.nombre,
    this.avatarUrl,
  });
}
