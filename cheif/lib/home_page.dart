import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_user_page.dart';
import 'bots_page.dart';
import 'login_page.dart';
import 'orders_page.dart';
import 'table_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB), // Warm parchment-like background
      body: Column(
        children: [
          // Restaurant-style Header
          _buildRestaurantHeader(context),
          
          // Main Content
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Dashboard Stats
                      _buildDashboardStats(context),
                      const SizedBox(height: 24),
                      
                      // Section Title
                      _buildSectionTitle('Restaurant Operations'),
                      
                      // Operations Grid
                      _buildOperationsGrid(context),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Floating Action Button
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.shade700.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddUserPage()),
            );
          },
          backgroundColor: Colors.amber.shade800,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.amber.shade600,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 24),
          ),
          label: const Text(
            'NEW TABLE',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildRestaurantHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.amber.shade900,
            Colors.amber.shade700,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade800.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Restaurant Logo/Name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GOURMET KITCHEN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Restaurant Management',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Logout Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.exit_to_app, color: Colors.white),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Welcome Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, Chef!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your restaurant with ease',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStats(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.dashboard,
                    color: Colors.amber.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Live Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Stats Row
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collectionGroup('orders').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final currentUid = FirebaseAuth.instance.currentUser?.uid;
                int pendingOrdersCount = 0;
                Set<String> activeTableIds = {};

                // Filter orders client-side to match OrdersPage logic
                final myOrders = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['user_created_by'] == currentUid;
                });

                for (var doc in myOrders) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['Food_Delivered'] ?? 'not delivered';
                  
                  if (status != 'delivered') {
                    pendingOrdersCount++;
                    // Use table_name if available, otherwise fallback to user ID
                    final tableName = data['table_name']?.toString() ?? 
                                    doc.reference.parent.parent?.id ?? 
                                    'Unknown';
                    activeTableIds.add(tableName);
                  }
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      context,
                      title: 'Active Tables',
                      icon: Icons.table_restaurant,
                      color: Colors.amber.shade600,
                      value: activeTableIds.length.toString(),
                      subtitle: 'With pending orders',
                    ),
                    Container(
                      width: 1,
                      height: 80,
                      color: Colors.grey.shade200,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Pending Orders',
                      icon: Icons.restaurant,
                      color: pendingOrdersCount > 0 ? Colors.red.shade600 : Colors.green.shade600,
                      value: pendingOrdersCount.toString(),
                      subtitle: 'Awaiting delivery',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String value,
    required String subtitle,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildOperationCard(
          context,
          title: 'Table Management',
          subtitle: 'Manage tables & seating',
          icon: Icons.table_restaurant_rounded,
          iconColor: Colors.white,
          bgColor: Colors.amber.shade700,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TableDetailsPage()),
            );
          },
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade700,
              Colors.amber.shade800,
            ],
          ),
        ),
        
        _buildOperationCard(
          context,
          title: 'Orders',
          subtitle: 'View & manage orders',
          icon: Icons.restaurant_menu_rounded,
          iconColor: Colors.white,
          bgColor: Colors.red.shade600,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const OrdersPage()),
            );
          },
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.shade600,
              Colors.red.shade700,
            ],
          ),
        ),
        
        _buildOperationCard(
          context,
          title: 'Delivery Bots',
          subtitle: 'Manage food delivery bots',
          icon: Icons.delivery_dining_rounded,
          iconColor: Colors.white,
          bgColor: Colors.blue.shade600,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const BotsPage()),
            );
          },
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade600,
              Colors.blue.shade700,
            ],
          ),
        ),
        
        // Empty card for future expansion or as placeholder
        _buildOperationCard(
          context,
          title: 'Menu',
          subtitle: 'Coming soon',
          icon: Icons.menu_book_rounded,
          iconColor: Colors.grey.shade600,
          bgColor: Colors.grey.shade100,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Feature coming soon!'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade100,
              Colors.grey.shade200,
            ],
          ),
          isDisabled: true,
        ),
      ],
    );
  }

  Widget _buildOperationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Gradient gradient,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: gradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(isDisabled ? 0.2 : 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                
                const Spacer(),
                
                // Title
                Text(
                  title,
                  style: TextStyle(
                    color: isDisabled ? Colors.grey.shade600 : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 6),
                
                // Subtitle
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDisabled ? Colors.grey.shade500 : Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Arrow indicator
                if (!isDisabled)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}