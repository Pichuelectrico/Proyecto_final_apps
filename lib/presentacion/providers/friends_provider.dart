import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firebase/firestore_servicio.dart';
import '../../data/repositorios/user_repo_impl.dart';
import '../../dominio/repositorios/user_repo.dart';
import '../../modelos/friend.dart';
import 'image_provider.dart';

final userRepoProvider = Provider<UserRepo>((ref) {
  return UserRepoImpl(ref.read(firestoreServicioProvider));
});

final friendsProvider = FutureProvider.family<List<Friend>, String>((ref, userId) {
  return ref.read(userRepoProvider).fetchFriends(userId);
});
