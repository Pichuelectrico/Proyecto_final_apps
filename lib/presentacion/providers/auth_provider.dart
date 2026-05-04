import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firebase/auth_servicio.dart';
import '../../data/repositorios/auth_repo_impl.dart';
import '../../dominio/repositorios/auth_repo.dart';
import '../../modelos/usuario.dart';

final authServicioProvider = Provider<AuthServicio>((ref) {
  return AuthServicio();
});

final authRepoProvider = Provider<AuthRepo>((ref) {
  return AuthRepoImpl(ref.read(authServicioProvider));
});

final authStateProvider = StreamProvider<Usuario?>((ref) {
  return ref.read(authRepoProvider).authStateChanges();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref.read(authRepoProvider));
});

class AuthController extends StateNotifier<bool> {
  final AuthRepo repo;

  AuthController(this.repo) : super(false);

  Future<void> login({required String email, required String password}) async {
    state = true;
    try {
      await repo.login(email: email, password: password);
    } finally {
      state = false;
    }
  }

  Future<void> register(
      {required String email, required String password, String? name}) async {
    state = true;
    try {
      await repo.register(email: email, password: password, nombre: name);
    } finally {
      state = false;
    }
  }

  Future<void> logout() async {
    state = true;
    try {
      await repo.logout();
    } finally {
      state = false;
    }
  }
}
