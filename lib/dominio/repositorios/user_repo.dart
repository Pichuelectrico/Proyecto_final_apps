import '../../modelos/friend.dart';
import '../../modelos/usuario.dart';

abstract class UserRepo {
  Future<Usuario?> fetchProfile(String userId);
  Future<List<Friend>> fetchFriends(String userId);
  Future<void> addFriend({
    required String ownerId,
    required String friendId,
    String? nombre,
    String? email,
    String? avatarUrl,
  });
}
