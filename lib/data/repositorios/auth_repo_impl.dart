import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../dominio/repositorios/auth_repo.dart';
import '../../modelos/usuario.dart';
import '../firebase/auth_servicio.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthServicio servicio;
  final FirebaseFirestore _firestore;

  AuthRepoImpl(this.servicio, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Usuario _mapUser(User user, {String? nombre}) {
    return Usuario(id: user.uid, email: user.email ?? '', nombre: nombre);
  }

  @override
  Stream<Usuario?> authStateChanges() {
    return servicio.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapUser(user);
    });
  }

  @override
  Future<Usuario> login(
      {required String email, required String password}) async {
    final user = await servicio.login(email: email, password: password);
    return _mapUser(user);
  }

  @override
  Future<Usuario> register(
      {required String email, required String password, String? nombre}) async {
    final user = await servicio.register(email: email, password: password);

    // Guardar usuario en Firestore con nombre
    await _firestore.collection('users').doc(user.uid).set({
      'email': email,
      'nombre': nombre ?? '',
      'avatarUrl': null,
    });

    return _mapUser(user, nombre: nombre);
  }

  @override
  Future<void> logout() => servicio.logout();
}
