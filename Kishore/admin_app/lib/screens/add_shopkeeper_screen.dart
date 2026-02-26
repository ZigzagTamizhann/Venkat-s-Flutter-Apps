import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';

class AddShopkeeperScreen extends StatefulWidget {
  const AddShopkeeperScreen({super.key});

  @override
  State<AddShopkeeperScreen> createState() => _AddShopkeeperScreenState();
}

class _AddShopkeeperScreenState extends State<AddShopkeeperScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _collegeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isAvailable = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _saveShopkeeper() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    FirebaseApp? secondaryApp;
    try {
      FirebaseOptions firebaseOptions = Firebase.app().options;
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: firebaseOptions,
      );

      UserCredential userCredential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance.collection('shopkeepers').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'shopName': _shopNameController.text.trim(),
        'college': _collegeController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'isAvailable': _isAvailable,
        'createdAt': FieldValue.serverTimestamp(),
        'Login' : "Shop Keeper",
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Shopkeeper added successfully'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Authentication error'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Shopkeeper'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.background,
              AppTheme.background.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceGlass,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shop Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Owner Name',
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: 'John Doe',
                      ),
                      validator: (v) => v!.isEmpty ? 'Owner name required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _shopNameController,
                      decoration: const InputDecoration(
                        labelText: 'Shop Name',
                        prefixIcon: Icon(Icons.store_outlined),
                        hintText: 'The Coffee Shop',
                      ),
                      validator: (v) => v!.isEmpty ? 'Shop name required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _collegeController,
                      decoration: const InputDecoration(
                        labelText: 'College Name',
                        prefixIcon: Icon(Icons.school_outlined),
                        hintText: 'University Name',
                      ),
                      validator: (v) => v!.isEmpty ? 'College name required' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'shop@example.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty || !v.contains('@') ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        hintText: '••••••••',
                      ),
                      obscureText: _obscurePassword,
                      validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '+1 234 567 890',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Phone number required' : null,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Shop Status',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _isAvailable ? 'Open' : 'Closed',
                                style: TextStyle(
                                  color: _isAvailable ? AppTheme.success : AppTheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Switch(
                                value: _isAvailable,
                                onChanged: (val) => setState(() => _isAvailable = val),
                                activeColor: AppTheme.success,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveShopkeeper,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Add Shopkeeper'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}