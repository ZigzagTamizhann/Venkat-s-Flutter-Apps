// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/intro_screen.dart';
import 'services/user_progress_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProgressService())],
      child: const ISLLearningApp(),
    ),
  );
}
 
class ISLLearningApp extends StatelessWidget {
  const ISLLearningApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      title: 'ISL Learning — Sign with Joy!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.childTheme,
      home: const IntroScreen(),
    );
  } 
}