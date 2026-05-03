import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firebase/firestore_servicio.dart';
import '../../data/imgur/imgur_servicio.dart';
import '../../data/repositorios/image_repo_impl.dart';
import '../../dominio/repositorios/image_repo.dart';
import '../../modelos/imagen.dart';

final firestoreServicioProvider = Provider<FirestoreServicio>((ref) {
  return FirestoreServicio();
});

final imgurServicioProvider = Provider<ImgurServicio>((ref) {
  return ImgurServicio();
});

final imageRepoProvider = Provider<ImageRepo>((ref) {
  return ImageRepoImpl(
    firestore: ref.read(firestoreServicioProvider),
    imgur: ref.read(imgurServicioProvider),
  );
});

final incomingImagesProvider = FutureProvider.family<List<Imagen>, String>((ref, userId) {
  return ref.read(imageRepoProvider).fetchIncomingImages(userId);
});

final outgoingImagesProvider = FutureProvider.family<List<Imagen>, String>((ref, userId) {
  return ref.read(imageRepoProvider).fetchOutgoingImages(userId);
});