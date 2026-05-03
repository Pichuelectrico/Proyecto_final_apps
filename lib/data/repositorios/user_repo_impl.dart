import 'package:cloud_firestore/cloud_firestore.dart';

import '../../dominio/repositorios/user_repo.dart';
import '../../modelos/friend.dart';
import '../../modelos/usuario.dart';
import '../firebase/firestore_servicio.dart';

class UserRepoImpl implements UserRepo {
  final FirestoreServicio servicio;

  UserRepoImpl(this.servicio);

  @override
  Future<Usuario?> fetchProfile(String userId) async {
    final doc = await servicio.usersRef.doc(userId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return Usuario(
      id: doc.id,
      email: data['email'] ?? '',
      nombre: data['nombre'],
      avatarUrl: data['avatarUrl'],
    );
  }

  @override
  Future<List<Friend>> fetchFriends(String userId) async {
    final snapshot = await servicio.friendsRef
        .where('ownerId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Friend(
        id: data['friendId'] ?? doc.id,
        nombre: data['nombre'] ?? 'Amigo',
        email: data['email'] ?? '',
        avatarUrl: data['avatarUrl'],
      );
    }).toList();
  }
}
