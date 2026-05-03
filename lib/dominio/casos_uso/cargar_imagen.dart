import '../repositorios/image_repo.dart';
import '../../modelos/imagen.dart';

class CargarImagen {
  final ImageRepo repo;
  CargarImagen(this.repo);

  Future<Imagen> ejecutar({
    required String senderId,
    required String receiverId,
    required String localPath,
    String? caption,
  }) {
    return repo.uploadImage(
      senderId: senderId,
      receiverId: receiverId,
      localPath: localPath,
      caption: caption,
    );
  }
}
