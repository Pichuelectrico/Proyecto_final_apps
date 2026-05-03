class Imagen {
  final String id;
  final String imageUrl;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  final String? caption;
  final bool isApproved;

  Imagen({
    required this.id,
    required this.imageUrl,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.caption,
    this.isApproved = true,
  });
}
