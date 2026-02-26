import 'package:flutter/material.dart';
import 'package:admin_app/services/auth_service.dart';
import 'package:admin_app/screens/login_page.dart';
import 'package:admin_app/screens/add_food_item_page.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AuthService _authService = AuthService();

  void _logout() async {
    await _authService.logout();
    // Navigate back to Login Page after logout
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AdminLoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddFoodItemPage()));
          },
          child: Text('Add Food Item'),
        ),
      ),
    );
  }
}