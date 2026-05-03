import 'package:firebase_auth/firebase_auth.dart';

import '../../dominio/repositorios/auth_repo.dart';
import '../../modelos/usuario.dart';
import '../firebase/auth_servicio.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthServicio servicio;

  AuthRepoImpl(this.servicio);

  Usuario _mapUser(User user) {
    return Usuario(id: user.uid, email: user.email ?? '');
  }

  @override
  Stream<Usuario?> authStateChanges() {
    return servicio.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapUser(user);
    });
  }

  @override
  Future<Usuario> login({required String email, required String password}) async {
    final user = await servicio.login(email: email, password: password);
    return _mapUser(user);
  }

  @override
  Future<Usuario> register({required String email, required String password}) async {
    final user = await servicio.register(email: email, password: password);
    return _mapUser(user);
  }

  @override
  Future<void> logout() => servicio.logout();
}
