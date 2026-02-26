import 'package:flutter/material.dart';
import 'package:admin_app/services/auth_service.dart';
import 'package:admin_app/models/user_model.dart';

class AddStaffPage extends StatefulWidget {
  @override
  _AddStaffPageState createState() => _AddStaffPageState();
}

class _AddStaffPageState extends State<AddStaffPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  Future<void> _addStaff() async {
    UserModel? user = await _authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text,
      phone: _phoneController.text,
      role: 'staff',
    );

    if (user != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Staff added successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add staff')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Staff')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            SizedBox(height: 15),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            SizedBox(height: 15),
            TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
            SizedBox(height: 15),
            TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addStaff,
              child: Text('Add Staff'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
