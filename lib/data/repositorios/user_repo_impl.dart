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
    final snapshot =
        await servicio.friendsRef.where('ownerId', isEqualTo: userId).get();
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

  @override
  Future<Usuario?> findUserByEmail(String email) async {
    final snapshot = await servicio.usersRef
        .where('email', isEqualTo: email.toLowerCase().trim())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data();
    return Usuario(
      id: doc.id,
      email: data['email'] ?? '',
      nombre: data['nombre'],
      avatarUrl: data['avatarUrl'],
    );
  }

  @override
  Future<void> addFriendByEmail(String ownerId, String email) async {
    final friend = await findUserByEmail(email);

    if (friend == null) {
      throw Exception('Usuario no encontrado con ese correo');
    }

    if (friend.id == ownerId) {
      throw Exception('No puedes agregarte a ti mismo como amigo');
    }

    // Verificar si ya es amigo
    final existing = await servicio.friendsRef
        .where('ownerId', isEqualTo: ownerId)
        .where('friendId', isEqualTo: friend.id)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Este usuario ya es tu amigo');
    }

    // Obtener info del usuario actual
    final ownerDoc = await servicio.usersRef.doc(ownerId).get();
    final ownerData = ownerDoc.data();

    // Crear amistad bidireccional - Owner ve a Friend
    await servicio.friendsRef.add({
      'ownerId': ownerId,
      'friendId': friend.id,
      'nombre': friend.nombre ?? 'Amigo',
      'email': friend.email,
      'avatarUrl': friend.avatarUrl,
    });

    // Crear amistad bidireccional - Friend ve a Owner
    await servicio.friendsRef.add({
      'ownerId': friend.id,
      'friendId': ownerId,
      'nombre': ownerData?['nombre'] ?? 'Amigo',
      'email': ownerData?['email'] ?? '',
      'avatarUrl': ownerData?['avatarUrl'],
    });
  }
}
