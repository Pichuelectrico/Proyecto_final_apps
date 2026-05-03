import '../repositorios/auth_repo.dart';
import '../../modelos/usuario.dart';

class RegistrarUsuario {
  final AuthRepo repo;
  RegistrarUsuario(this.repo);

  Future<Usuario> ejecutar({required String email, required String password}) {
    return repo.register(email: email, password: password);
  }
}
