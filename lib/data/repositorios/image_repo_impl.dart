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
    final snapshot = await firestore.imagesRef
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map(_mapDoc).toList();
  }

  @override
  Future<List<Imagen>> fetchOutgoingImages(String userId) async {
    final snapshot = await firestore.imagesRef
        .where('senderId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map(_mapDoc).toList();
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

  Future<void> cacheLatestImage(Imagen imagen, {String? senderName}) async {
    try {
      await imgur.cacheImageToWidget(
        imageUrl: imagen.imageUrl,
        caption: imagen.caption,
        senderId: imagen.senderId,
        senderName: senderName,
      );
    } catch (_) {}
  }

}
