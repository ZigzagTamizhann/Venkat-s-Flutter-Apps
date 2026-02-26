import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static User? get currentUser => auth.currentUser;
  static String? get currentUserId => currentUser?.uid;

  static Stream<User?> get authStateChanges => auth.authStateChanges();
}