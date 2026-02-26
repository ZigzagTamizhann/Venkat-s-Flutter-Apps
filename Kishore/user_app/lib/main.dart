import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/food_list_screen.dart';
import 'screens/shop_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp();
  }
  runApp(const UserApp());
}

class UserApp extends StatefulWidget {
  const UserApp({super.key});

  @override
  State<UserApp> createState() => _UserAppState();
}

class _UserAppState extends State<UserApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepFood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF007AFF),
          onPrimary: Colors.white,
          secondary: Color(0xFF5856D6),
          onSecondary: Colors.white,
          error: Color(0xFFFF3B30),
          onError: Colors.white,
          surface: Color(0xFFF2F2F7),
          onSurface: Color(0xFF1C1C1E),
          background: Color(0xFFF2F2F7),
          onBackground: Color(0xFF1C1C1E),
        ),
        fontFamily: '.SF Pro Display',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFFF2F2F7),
          foregroundColor: Color(0xFF1C1C1E),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
            fontFamily: '.SF Pro Display',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/order_history': (context) => const OrderHistoryScreen(),
        '/food_list': (context) => const FoodListScreen(),
        '/shop_list': (context) => const ShopListScreen(),
      },
    );
  }
}