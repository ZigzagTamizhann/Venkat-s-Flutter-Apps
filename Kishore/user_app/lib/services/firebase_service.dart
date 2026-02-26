import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static FirebaseAuth get auth => _auth;

  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => currentUser?.uid;
  static bool get isLoggedIn => currentUser != null;
}