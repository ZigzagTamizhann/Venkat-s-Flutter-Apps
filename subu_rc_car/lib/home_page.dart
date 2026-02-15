import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final String ipAddress = "192.168.4.1";
  bool isConnected = false;
  String connectionStatus = "Not Connected";
  String wifiName = "Not Connected";
  bool isConnecting = false;

  // WiFi connect/disconnect function
  Future<void> toggleWifiConnection() async {
    if (isConnecting) return;
    
    if (!isConnected) {
      await _connectToWifi();
    } else {
      await _disconnectFromWifi();
    }
  }

  Future<void> _connectToWifi() async {
    setState(() {
      isConnecting = true;
      connectionStatus = "Connecting...";
    });
    
    try {
      // Try to get current WiFi Name
      String? ssid;
      try {
        ssid = await NetworkInfo().getWifiName();
        if (ssid != null) {
          ssid = ssid.replaceAll('"', ''); // Remove quotes on Android
        }
      } catch (e) {
        print("Error getting WiFi name: $e");
      }

      final response = await http
          .get(Uri.parse('http://$ipAddress/stop'))
          .timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        setState(() {
          isConnected = true;
          isConnecting = false;
          connectionStatus = "Connected";
          wifiName = ssid ?? "ESP32_CAR";
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Connected to ESP32 Car"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isConnected = false;
        isConnecting = false;
        connectionStatus = "Connection Failed";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connection Failed: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      print("Error connecting: $e");
    }
  }

  Future<void> _disconnectFromWifi() async {
    setState(() {
      isConnected = false;
      connectionStatus = "Disconnected";
      wifiName = "Not Connected";
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Disconnected from ESP32 Car"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Send command to ESP32
  Future<void> sendCommand(String command) async {
    if (!isConnected) return;
    
    try {
      final response = await http
          .get(Uri.parse('http://$ipAddress/$command'))
          .timeout(const Duration(seconds: 2));
      
      if (response.statusCode == 200) {
        print("Sent: $command");
      }
    } catch (e) {
      print("Error sending command: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connection Lost: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 1),
          ),
        );
        setState(() {
          isConnected = false;
          connectionStatus = "Connection Lost";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            // Top Header with All Details
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade900,
                    Colors.blue.shade800,
                    Colors.blue.shade900,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Side - Branding
                  Row(
                    children: [
                      // AtumX Brand
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade300, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Text(
                          "AtumX",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      
                      // SUBOO RC CAR Brand
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade800,
                              Colors.red.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Text(
                          "SUBOO RC CAR",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                blurRadius: 3,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Center - Connection Status
                  Column(
                    children: [
                      // WiFi Name
                      Row(
                        children: [
                          Icon(
                            Icons.wifi,
                            color: Colors.white.withOpacity(0.9),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            wifiName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      
                      // Status Indicator
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isConnected ? Colors.green : Colors.red,
                              boxShadow: [
                                BoxShadow(
                                  color: (isConnected ? Colors.green : Colors.red)
                                      .withOpacity(0.8),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            connectionStatus,
                            style: TextStyle(
                              color: isConnected
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(
                                  blurRadius: 2,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Right Side - Connect/Disconnect Button
                  GestureDetector(
                    onTap: toggleWifiConnection,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isConnected
                              ? [Colors.red.shade700, Colors.red.shade900]
                              : [Colors.green.shade700, Colors.green.shade900],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isConnected
                              ? Colors.red.shade300
                              : Colors.green.shade300,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isConnected
                                    ? Colors.red.shade800!
                                    : Colors.green.shade800!)
                                .withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (isConnecting)
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            Icon(
                              isConnected ? Icons.wifi_off : Icons.wifi,
                              color: Colors.white,
                              size: 20,
                            ),
                          const SizedBox(width: 10),
                          Text(
                            isConnecting
                                ? "CONNECTING..."
                                : isConnected
                                    ? "DISCONNECT"
                                    : "CONNECT",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Controller Area
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 75, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey[850]!,
                      Colors.grey[900]!,
                      Colors.black,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Left Side - Forward/Backward Controls
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          // Forward Button
                          GestureDetector(
                            onTapDown: (_) =>
                                isConnected ? sendCommand("forward") : null,
                            onTapUp: (_) =>
                                isConnected ? sendCommand("stop") : null,
                            onTapCancel: () =>
                                isConnected ? sendCommand("stop") : null,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isConnected
                                      ? [
                                          Colors.green.shade600,
                                          Colors.green.shade800,
                                          Colors.green.shade900,
                                        ]
                                      : [
                                          Colors.grey.shade600,
                                          Colors.grey.shade700,
                                          Colors.grey.shade800,
                                        ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isConnected
                                      ? Colors.green.shade300
                                      : Colors.grey.shade500,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.arrow_upward,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "FORWARD",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 3,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 50),
                          
                          // Backward Button
                          GestureDetector(
                            onTapDown: (_) =>
                                isConnected ? sendCommand("backward") : null,
                            onTapUp: (_) =>
                                isConnected ? sendCommand("stop") : null,
                            onTapCancel: () =>
                                isConnected ? sendCommand("stop") : null,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isConnected
                                      ? [
                                          Colors.blue.shade600,
                                          Colors.blue.shade800,
                                          Colors.blue.shade900,
                                        ]
                                      : [
                                          Colors.grey.shade600,
                                          Colors.grey.shade700,
                                          Colors.grey.shade800,
                                        ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isConnected
                                      ? Colors.blue.shade300
                                      : Colors.grey.shade500,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.arrow_downward,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "BACKWARD",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 3,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      ),
                    ),

                    // Right Side - Left/Right Controls
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Horn Button
                            GestureDetector(
                              onTap: () => isConnected ? sendCommand("horn") : null,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isConnected
                                        ? [
                                            Colors.red.shade600,
                                            Colors.red.shade800,
                                            Colors.red.shade900,
                                          ]
                                        : [
                                            Colors.grey.shade600,
                                            Colors.grey.shade700,
                                            Colors.grey.shade800,
                                          ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isConnected
                                        ? Colors.red.shade300
                                        : Colors.grey.shade500,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.campaign,
                                      size: 35,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "HORN",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 1.2,
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 3,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Left Button
                          GestureDetector(
                            onTapDown: (_) =>
                                isConnected ? sendCommand("left") : null,
                            onTapUp: (_) =>
                                isConnected ? sendCommand("stop") : null,
                            onTapCancel: () =>
                                isConnected ? sendCommand("stop") : null,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: isConnected
                                      ? [
                                          Colors.orange.shade600,
                                          Colors.orange.shade800,
                                          Colors.orange.shade900,
                                        ]
                                      : [
                                          Colors.grey.shade600,
                                          Colors.grey.shade700,
                                          Colors.grey.shade800,
                                        ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isConnected
                                      ? Colors.orange.shade300
                                      : Colors.grey.shade500,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.arrow_back,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "LEFT",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 3,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 50),
                          
                          // Right Button
                          GestureDetector(
                            onTapDown: (_) =>
                                isConnected ? sendCommand("right") : null,
                            onTapUp: (_) =>
                                isConnected ? sendCommand("stop") : null,
                            onTapCancel: () =>
                                isConnected ? sendCommand("stop") : null,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: isConnected
                                      ? [
                                          Colors.orange.shade600,
                                          Colors.orange.shade800,
                                          Colors.orange.shade900,
                                        ]
                                      : [
                                          Colors.grey.shade600,
                                          Colors.grey.shade700,
                                          Colors.grey.shade800,
                                        ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isConnected
                                      ? Colors.orange.shade300
                                      : Colors.grey.shade500,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "RIGHT",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 3,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}