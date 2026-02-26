import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'orders_screen.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Add a small delay for the splash effect
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseService.auth.currentUser;
    if (user != null) {
      // User is logged in, try to restore session
      try {
        final staffQuery = await FirebaseService.db
            .collection('staff')
            .where('email', isEqualTo: user.email)
            .get();

        if (staffQuery.docs.isNotEmpty) {
          final staffData = staffQuery.docs.first.data();
          final shopId = staffData['shopId'];

          if (shopId != null) {
            final shopDoc = await FirebaseService.db.collection('shopkeepers').doc(shopId).get();
            
            FirebaseService.currentShopId = shopId;
            FirebaseService.currentShopName = shopDoc.data()?['shopName'];

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            );
            return;
          }
        }
      } catch (e) {
        debugPrint('Session restore failed: $e');
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Staff Hub',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}