import '../repositorios/auth_repo.dart';
import '../../modelos/usuario.dart';

class IniciarSesion {
  final AuthRepo repo;
  IniciarSesion(this.repo);

  Future<Usuario> ejecutar({required String email, required String password}) {
    return repo.login(email: email, password: password);
  }
}
