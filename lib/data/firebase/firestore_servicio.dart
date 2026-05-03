import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServicio {
  final FirebaseFirestore _db;

  FirestoreServicio({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get usersRef =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get friendsRef =>
      _db.collection('friends');

  CollectionReference<Map<String, dynamic>> get imagesRef =>
      _db.collection('images');
}
