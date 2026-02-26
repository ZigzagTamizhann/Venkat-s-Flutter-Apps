import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_app/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (!doc.exists) {
        // If user exists in Auth but not in Firestore, create a default admin record
        UserModel newUser = UserModel(
          userId: result.user!.uid,
          email: email,
          name: 'Admin',
          phone: '',
          role: 'admin',
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(newUser.userId).set(newUser.toMap());
        return newUser;
      }
      
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel user = UserModel(
        userId: result.user!.uid,
        email: email,
        name: name,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.userId).set(user.toMap());
      return user;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}
