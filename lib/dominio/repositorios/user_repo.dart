import '../../modelos/friend.dart';
import '../../modelos/usuario.dart';

abstract class UserRepo {
  Future<Usuario?> fetchProfile(String userId);
  Future<List<Friend>> fetchFriends(String userId);
}
