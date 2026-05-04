import '../../modelos/friend.dart';
import '../../modelos/usuario.dart';

abstract class UserRepo {
  Future<Usuario?> fetchProfile(String userId);
  Future<List<Friend>> fetchFriends(String userId);
  Future<Usuario?> findUserByEmail(String email);
  Future<void> addFriendByEmail(String ownerId, String email);
}
