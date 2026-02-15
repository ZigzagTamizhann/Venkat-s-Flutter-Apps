  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:user_app/firebase_options.dart';
  import 'package:user_app/screens/home_page.dart';
  import 'package:user_app/screens/login_page.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(UserApp());
  }

  class UserApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Food Ordering',
        theme: ThemeData(primarySwatch: Colors.orange),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return UserHomePage();
            }
            return const LoginPage();
          },
        ),
      );
    }
  }