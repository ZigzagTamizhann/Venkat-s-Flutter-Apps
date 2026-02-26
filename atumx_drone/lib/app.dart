import 'package:flutter/material.dart';
import 'controllers/rc_controller.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rekka',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFFF6B35), // Orange
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF333333)),
        ),
        colorScheme: ColorScheme.light(
          primary: Color(0xFFFF6B35),
          secondary: Color(0xFF4ECDC4),
        ),
      ),
      home: RCController(),
    );
  }
}