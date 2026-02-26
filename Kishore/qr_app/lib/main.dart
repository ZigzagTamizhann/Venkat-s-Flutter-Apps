import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const QRApp());
}

class QRApp extends StatefulWidget {
  const QRApp({super.key});

  @override
  State<QRApp> createState() => _QRAppState();
}

class _QRAppState extends State<QRApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
