import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class BotsPage extends StatefulWidget {
  const BotsPage({super.key});

  @override
  State<BotsPage> createState() => _BotsPageState();
}

class _BotsPageState extends State<BotsPage> {
  @override
  void initState() {
    super.initState();
    _updateQuestions();
  }

  Future<void> _updateQuestions() async {
    // Updates the 'Question' field to 'hii' for all devices under Device_IP
    final ref = FirebaseDatabase.instance.ref('Device_IP');
    try {
      final snapshot = await ref.get();
      if (snapshot.exists) {
        for (final child in snapshot.children) {
          await child.ref.update({
            'Question': 'hii',
            'Answer': null,
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating question: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        title: const Text('Bots Management'),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _updateQuestions();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing bots...')),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('Device_IP').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text('No bots connected'));
          }

          // Parse the data from RTDB
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final devices = data.values.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index] as Map<dynamic, dynamic>;
              final isOnline = device['Answer'] == 'Am There';
              
              return Column(
                children: [
                  _buildBotItem(
                    context,
                    name: device['Device_Name']?.toString() ?? 'Unknown Bot',
                    wifiName: device['Wifi_SSID']?.toString() ?? 'Unknown Wifi',
                    status: isOnline ? 'Online' : 'Offline',
                    isActive: isOnline,
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBotItem(
    BuildContext context, {
    required String name,
    required String wifiName,
    required String status,
    required bool isActive,
  }) {
    Color statusColor;
    IconData statusIcon;

    if (status.toLowerCase().contains('charging')) {
      statusColor = Colors.orange;
      statusIcon = Icons.battery_charging_full;
    } else if (isActive) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.highlight_off;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: statusColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [const SizedBox(width: 4),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.wifi, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          wifiName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}