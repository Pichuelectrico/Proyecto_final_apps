import '../../modelos/usuario.dart';

abstract class AuthRepo {
  Stream<Usuario?> authStateChanges();
  Future<Usuario> login({required String email, required String password});
  Future<Usuario> register(
      {required String email, required String password, String? nombre});
  Future<void> logout();
}
