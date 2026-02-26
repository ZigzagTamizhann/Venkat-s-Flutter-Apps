import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TableDetailsPage extends StatefulWidget {
  const TableDetailsPage({super.key});

  @override
  State<TableDetailsPage> createState() => _TableDetailsPageState();
}

class _TableDetailsPageState extends State<TableDetailsPage> {
  final Set<String> _visiblePasswordUserIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('User Management'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {},
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {},
            tooltip: 'Export',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          final data = snapshot.requireData;

          if (data.docs.isEmpty) {
            return _buildEmptyState();
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with stats
                _buildStatsCard(data),
                const SizedBox(height: 24),
                
                // Search and actions bar
                _buildSearchBar(),
                const SizedBox(height: 16),
                
                // Table with advanced styling
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildDataTable(data),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(Colors.blue[700]!),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Users...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              color: Colors.grey[300],
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'No Users Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first user to get started',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(QuerySnapshot data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[700]!,
            Colors.blue[900]!,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(
            count: data.docs.length.toString(),
            label: 'Total Users',
            icon: Icons.people,
          ),
          _buildStatItem(
            count: DateFormat('MMM d, y').format(DateTime.now()),
            label: 'Last Updated',
            icon: Icons.update,
          ),
          _buildStatItem(
            count: 'Active',
            label: 'Status',
            icon: Icons.check_circle,
            color: Colors.green[400],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String count,
    required String label,
    required IconData icon,
    Color? color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color ?? Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              count,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[500],
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[200],
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.sort,
              color: Colors.grey[700],
            ),
            tooltip: 'Sort',
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(QuerySnapshot data) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return Colors.grey[50]!;
            },
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[100]!),
            borderRadius: BorderRadius.circular(8),
          ),
          headingTextStyle: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          dataRowHeight: 60,
          headingRowHeight: 50,
          horizontalMargin: 16,
          columnSpacing: 32,
          columns: const [
            DataColumn(
              label: Row(
                children: [
                  Icon(Icons.person_outline, size: 16),
                  SizedBox(width: 8),
                  Text('Name'),
                ],
              ),
            ),
            DataColumn(
              label: Row(
                children: [
                  Icon(Icons.email_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Email'),
                ],
              ),
            ),
            DataColumn(
              label: Row(
                children: [
                  Icon(Icons.lock_outline, size: 16),
                  SizedBox(width: 8),
                  Text('Password'),
                ],
              ),
            ),
            DataColumn(
              label: Row(
                children: [
                  Icon(Icons.more_vert, size: 16),
                  SizedBox(width: 8),
                  Text('Actions'),
                ],
              ),
            ),
          ],
          rows: data.docs.map((doc) {
            final userData = doc.data() as Map<String, dynamic>;
            final docId = doc.id;
            final isPasswordVisible = _visiblePasswordUserIds.contains(docId);

            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            userData['name']?.toString().isNotEmpty == true
                                ? userData['name'][0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        userData['name'] ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      userData['email'] ?? 'N/A',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isPasswordVisible
                              ? (userData['password']?.toString() ?? 'N/A')
                              : '•' * 8,
                          style: TextStyle(
                            letterSpacing: isPasswordVisible ? 0 : 2,
                            fontSize: isPasswordVisible ? 14 : 18,
                            color: isPasswordVisible ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18,
                          color: Colors.grey[500],
                        ),
                        onPressed: () {
                          setState(() {
                            if (isPasswordVisible) {
                              _visiblePasswordUserIds.remove(docId);
                            } else {
                              _visiblePasswordUserIds.add(docId);
                            }
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz,
                      color: Colors.grey[600],
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {},
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}