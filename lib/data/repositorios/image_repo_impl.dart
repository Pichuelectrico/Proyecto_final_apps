import 'package:cloud_firestore/cloud_firestore.dart';

import '../../dominio/repositorios/image_repo.dart';
import '../../modelos/imagen.dart';
import '../firebase/firestore_servicio.dart';
import '../imgur/imgur_servicio.dart';

class ImageRepoImpl implements ImageRepo {
  final FirestoreServicio firestore;
  final ImgurServicio imgur;

  ImageRepoImpl({required this.firestore, required this.imgur});

  Imagen _mapDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Imagen(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      caption: data['caption'],
      isApproved: data['isApproved'] ?? true,
    );
  }

  @override
  Future<List<Imagen>> fetchIncomingImages(String userId) async {
    try {
      // Nota: Para usar orderBy, necesitas crear un índice en Firebase Console
      // Collection: images, Fields: receiverId (Ascending), timestamp (Descending)
      final snapshot = await firestore.imagesRef
          .where('receiverId', isEqualTo: userId)
          .get();
      final images = snapshot.docs.map(_mapDoc).toList();
      // Ordenar localmente por timestamp
      images.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return images;
    } catch (e) {
      throw Exception('Error al cargar imágenes: $e');
    }
  }

  @override
  Future<List<Imagen>> fetchOutgoingImages(String userId) async {
    try {
      // Nota: Para usar orderBy, necesitas crear un índice en Firebase Console
      // Collection: images, Fields: senderId (Ascending), timestamp (Descending)
      final snapshot =
          await firestore.imagesRef.where('senderId', isEqualTo: userId).get();
      final images = snapshot.docs.map(_mapDoc).toList();
      // Ordenar localmente por timestamp
      images.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return images;
    } catch (e) {
      throw Exception('Error al cargar imágenes: $e');
    }
  }

  @override
  Future<Imagen> uploadImage({
    required String senderId,
    required String receiverId,
    required String localPath,
    String? caption,
  }) async {
    final imageUrl = await imgur.subirImagen(localPath);

    final docRef = firestore.imagesRef.doc();
    await docRef.set({
      'imageUrl': imageUrl,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': FieldValue.serverTimestamp(),
      'caption': caption,
      'isApproved': true,
    });

    return Imagen(
      id: docRef.id,
      imageUrl: imageUrl,
      senderId: senderId,
      receiverId: receiverId,
      timestamp: DateTime.now(),
      caption: caption,
      isApproved: true,
    );
  }
}
