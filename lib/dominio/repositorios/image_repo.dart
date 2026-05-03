import '../../modelos/imagen.dart';

abstract class ImageRepo {
  Future<List<Imagen>> fetchIncomingImages(String userId);
  Future<List<Imagen>> fetchOutgoingImages(String userId);
  Future<Imagen> uploadImage({
    required String senderId,
    required String receiverId,
    required String localPath,
    String? caption,
  });
}
