import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class ManageStaffScreen extends StatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  void _showStaffDialog(BuildContext context, {DocumentSnapshot? staff}) {
    final isEditing = staff != null;
    final data = isEditing ? (staff.data() as Map<String, dynamic>) : null;

    final nameController = TextEditingController(text: isEditing ? data!['name'] : '');
    final roleController = TextEditingController(text: isEditing ? data!['role'] : '');
    final phoneController = TextEditingController(text: isEditing ? data!['phone'] : '');
    final emailController = TextEditingController(text: isEditing ? data!['email'] : '');
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceGlass,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Staff' : 'Add Staff Member',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'John Doe',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.work_outline),
                    hintText: 'Cashier, Server, etc.',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '+91 98765 43210',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                if (!isEditing) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Login Credentials',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'staff@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      hintText: '••••••••',
                    ),
                    obscureText: true,
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final uid = FirebaseAuth.instance.currentUser!.uid;
                          final collection = FirebaseFirestore.instance
                              .collection('staff');
                          
                          final staffData = {
                            'name': nameController.text,
                            'role': roleController.text,
                            'phone': phoneController.text,
                            'email':emailController.text,
                            'shopId': uid,
                            if (!isEditing) 'isPresent': false,
                            if (!isEditing) 'joinedAt': FieldValue.serverTimestamp(),
                          };

                          if (isEditing) {
                            collection.doc(staff.id).update(staffData);
                            Navigator.pop(context);
                          } else {
                            try {
                              // Create secondary app instance
                              FirebaseApp app;
                              try {
                                app = Firebase.app('Secondary');
                              } catch (e) {
                                app = await Firebase.initializeApp(
                                  name: 'Secondary',
                                  options: Firebase.app().options,
                                );
                              }

                              // Create auth user
                              UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
                                  .createUserWithEmailAndPassword(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  );
                              
                              final staffUid = userCredential.user?.uid;
                              
                              if (staffUid != null) {
                                // Create staff lookup
                                await FirebaseFirestore.instance
                                    .collection('staff_lookup')
                                    .doc(staffUid)
                                    .set({'shopId': uid});
                                
                                // Create staff document with UID as ID
                                await collection.doc(staffUid).set(staffData);
                              }
                              
                              Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text('Error creating staff: $e')),
                                      ],
                                    ),
                                    backgroundColor: AppTheme.surfaceGlass,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Text(isEditing ? 'Save' : 'Add Staff'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        centerTitle: false,
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('staff')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceGlass,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people_outline,
                        size: 50,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No staff members',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first staff member',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showStaffDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Staff'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final isPresent = data['isPresent'] ?? false;
                final joinedAt = data['joinedAt'] != null
                    ? (data['joinedAt'] as Timestamp).toDate()
                    : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceGlass,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Avatar with status indicator
                        Stack(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isPresent 
                                    ? AppTheme.success.withOpacity(0.1)
                                    : AppTheme.textSecondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  data['name'].isNotEmpty 
                                      ? data['name'][0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isPresent 
                                        ? AppTheme.success
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            if (isPresent)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: AppTheme.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Staff details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      data['role'],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    data['phone'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              if (joinedAt != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Joined ${DateFormat('MMM d, yyyy').format(joinedAt)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Status and actions
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  isPresent ? 'Present' : 'Absent',
                                  style: TextStyle(
                                    color: isPresent 
                                        ? AppTheme.success
                                        : AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Switch(
                                  value: isPresent,
                                  onChanged: (val) {
                                    doc.reference.update({'isPresent': val});
                                  },
                                  activeColor: AppTheme.success,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: AppTheme.primary,
                              ),
                              onPressed: () => _showStaffDialog(context, staff: doc),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: () => _showStaffDialog(context),
          icon: const Icon(Icons.person_add),
          label: const Text('Add Staff'),
          backgroundColor: AppTheme.primary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}