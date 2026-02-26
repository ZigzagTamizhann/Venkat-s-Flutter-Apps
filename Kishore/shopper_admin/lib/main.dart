import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/firebase_service.dart';
// import 'firebase_options.dart'; // Comment this out if file is missing

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // If running on Android with google-services.json, you don't need options.
    // Note: This will NOT work on Windows.
    await Firebase.initializeApp();
    runApp(const MyApp());
  } catch (e) {
    // This prevents the app from closing immediately and shows the error
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("Error: $e"))),
      ),
    ));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopkeeper Admin',
      theme: AppTheme.lightTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
