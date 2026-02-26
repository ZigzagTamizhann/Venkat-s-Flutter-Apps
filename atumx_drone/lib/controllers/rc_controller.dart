import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:atumx_drone/widgets/dialogs/pid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/vertical_slider.dart';
import '../widgets/joystick.dart';
import '../widgets/trim_button.dart';
import '../utils/helpers.dart';
import '../settings_page.dart';
import 'drone_controller.dart';

// 1. Data Class for Telemetry
class FlightTelemetry {
  final double rollP, rollI, rollD;
  final double pitchP, pitchI, pitchD;
  final double angleP, angleI, angleD;
  final int aileron, elevator, throttle;

  FlightTelemetry({
    required this.rollP, required this.rollI, required this.rollD,
    required this.pitchP, required this.pitchI, required this.pitchD,
    required this.angleP, required this.angleI, required this.angleD,
    required this.aileron, required this.elevator, required this.throttle,
  });
}

class RCController extends StatefulWidget {
  @override
  _RCControllerState createState() => _RCControllerState();
}

class _RCControllerState extends State<RCController> {
  // ─── Control State ───────────────────────────────────────────
  double throttleValue = -1.0;
  double aileronValue = 0.0;
  double elevatorValue = 0.0;

  // ─── Trims ───────────────────────────────────────────────────
  double aileronTrimOffset = 0.0;
  double elevatorTrimOffset = 0.0;
  double throttleTrimOffset = 0.0;
  final double TRIM_STEP = 10.0;

  // ─── PID Values ──────────────────────────────────────────────
  double rollP = 1.2, rollI = 0.02, rollD = 0.04;
  double pitchP = 1.2, pitchI = 0.02, pitchD = 0.04;
  double angleP = 3.5, angleI = 0.05, angleD = 0.0;

  // ─── Settings ────────────────────────────────────────────────
  bool invertAileron = false;
  bool invertElevator = false;

  // ─── Network & Logic State ───────────────────────────────────
  String statusMessage = "Ready - Connect to Drone";
  bool isConnected = false;
  bool isHoldMode = false;
  
  // 2. FIXED STREAM CONTROLLER DEFINITION
  final _valueStreamController = StreamController<FlightTelemetry>.broadcast();
  late DroneController _droneController;
  Timer? _connectionTimer;

  @override
  void initState() {
    super.initState();
    _droneController = DroneController(
      onStatusUpdate: (status) {
        setState(() {
          statusMessage = status;
        });
      },
      onConnected: (connected) {
        if (connected) _connectionTimer?.cancel();
        setState(() {
          isConnected = connected;
          if (connected) {
            _droneController.sendPIDPacket(rollP, rollI, rollD, pitchP, pitchI, pitchD, angleP, angleI, angleD);
          }
        });
      },
      onPIDUpdated: () {
        setState(() {
          statusMessage = "Drone Ready - FLY!";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PID Synced!'),
            backgroundColor: Color(0xFFFF6B35),
          ),
        );
      },
    );
    _loadSettings();
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    _valueStreamController.close();
    _droneController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    setState(() {
      _droneController.targetIP = prefs.getString('targetIP') ?? '192.168.4.1';
      
      aileronTrimOffset = prefs.getDouble('aileronTrim') ?? 0.0;
      elevatorTrimOffset = prefs.getDouble('elevatorTrim') ?? 0.0;
      throttleTrimOffset = prefs.getDouble('throttleTrim') ?? 0.0;

      rollP = prefs.getDouble('rollP') ?? 1.2;
      rollI = prefs.getDouble('rollI') ?? 0.02;
      rollD = prefs.getDouble('rollD') ?? 0.04;

      pitchP = prefs.getDouble('pitchP') ?? 1.2;
      pitchI = prefs.getDouble('pitchI') ?? 0.02;
      pitchD = prefs.getDouble('pitchD') ?? 0.04;

      angleP = prefs.getDouble('angleP') ?? 3.5;
      angleI = prefs.getDouble('angleI') ?? 0.05;
      angleD = prefs.getDouble('angleD') ?? 0.0;

      invertAileron = prefs.getBool('invertAileron') ?? false;
      invertElevator = prefs.getBool('invertElevator') ?? false;
    });
    _updateValueDisplay();
  }

  // ─── UI Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'REKKA',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold,
                        color: Color(0xFF333333), letterSpacing: 1.2,
                      ),
                    ),
                    Row(
                      children: [
                        _buildIconButton(
                          icon: Icons.refresh, label: 'RESET',
                          onPressed: _resetApp, color: Colors.redAccent,
                        ),
                        SizedBox(width: 8),
                        _buildIconButton(
                          icon: Icons.tune, label: 'PID',
                          onPressed: _showPIDGridDialog, color: Color(0xFF4ECDC4),
                        ),
                        SizedBox(width: 8),
                        _buildIconButton(
                          icon: Icons.settings, label: 'Settings',
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SettingsPage()),
                            );
                            if (result == true) await _loadSettings();
                          },
                          color: Color(0xFF333333),
                        ),
                        SizedBox(width: 8),
                        _buildConnectionButton(),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Main Content Area
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      final availableHeight = constraints.maxHeight;
                      
                      return Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: availableWidth * 0.2,
                                  child: _buildLeftColumn(availableHeight),
                                ),
                                Expanded(
                                  child: _buildCenterColumn(availableHeight),
                                ),
                                SizedBox(
                                  width: availableWidth * 0.25,
                                  child: _buildRightColumn(availableHeight),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn(double availableHeight) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('THROTTLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF666666))),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              VerticalSliderWidget(
                height: availableHeight * 0.7, maxHeight: 300,
                color: _getThrottleColor(normalizedToADC(throttleValue)),
                onChanged: (y) {
                  setState(() { throttleValue = y; _onControlChanged(); });
                },
              ),
              SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: _buildTrimControl('throttle', isVertical: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. UI Redesign: The Center Dashboard
    Widget _buildCenterColumn(double availableHeight) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Changed from spaceEvenly to save space
          children: [
            // --- NEW DASHBOARD SECTION ---
            // Using Expanded ensures it takes available space but doesn't force overflow
            Expanded( 
              flex: 3,
              child: Container(
                // Removing fixed maxHeight constraints to let Expanded handle sizing
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: const Color.fromARGB(66, 255, 255, 255), blurRadius: 4)],
                ),
                child: StreamBuilder<FlightTelemetry>(
                  stream: _valueStreamController.stream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Text("Waiting for Input...", 
                          style: TextStyle(color: Colors.black, fontSize: 10))
                      );
                    }

                    final data = snapshot.data!;
                    
                    // Fixed layout to prevent scrolling and fit content
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // PID Row
                          Expanded(
                            flex: 6,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: _buildDashboardPidCard("ROLL", data.rollP, data.rollI, data.rollD, Colors.blueAccent)),
                                SizedBox(width: 4),
                                Expanded(child: _buildDashboardPidCard("PITCH", data.pitchP, data.pitchI, data.pitchD, Colors.orangeAccent)),
                                SizedBox(width: 4),
                                Expanded(child: _buildDashboardPidCard("ANGLE", data.angleP, data.angleI, data.angleD, const Color.fromARGB(255, 64, 245, 255))),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          // Channel Bars
                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildDashboardBar("Aileron", data.aileron, Colors.cyanAccent),
                                _buildDashboardBar("Elevator", data.elevator, Colors.greenAccent),
                                _buildDashboardBar("Throttle", data.throttle, _getThrottleColor(data.throttle)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            SizedBox(height: 8),

            // --- ACTION BUTTONS (CALIBRATE & RESET) ---
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _sendCalibration,
                        icon: Icon(Icons.compass_calibration, size: 20),
                        label: Text('CALIBRATE', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4ECDC4), foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _toggleHold,
                        icon: Icon(isHoldMode ? Icons.play_arrow : Icons.pause, size: 20),
                        label: Text(isHoldMode ? 'UNHOLD' : 'HOLD', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isHoldMode ? Colors.green : Colors.redAccent, foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _resetTrims,
                        icon: Icon(Icons.refresh, size: 20),
                        label: Text('RESET', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Color(0xFFFF6B35), foregroundColor: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

  Color _getThrottleColor(int value) {
    double percent = (value / 4095.0).clamp(0.0, 1.0);
    return Color.lerp(Colors.green, Colors.red, percent) ?? Colors.red;
  }

  // --- New Helper Widgets for the Dashboard ---
  Widget _buildDashboardPidCard(String title, double p, double i, double d, Color accentColor) {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 15)),
          Divider(color: const Color.fromARGB(26, 0, 0, 0), height: 8),
          _buildMiniPidRow("P", p),
          _buildMiniPidRow("I", i),
          _buildMiniPidRow("D", d),
        ],
      ),
    );
  }

  Widget _buildMiniPidRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: const Color.fromARGB(153, 255, 0, 0), fontSize: 15)),
          Text(val.toStringAsFixed(2), style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDashboardBar(String label, int value, Color color) {
    // ADC value usually 0-4095. Calculating percentage.
    double percent = (value / 4095.0).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: const Color.fromARGB(179, 0, 0, 0), fontSize: 9)),
            Text(value.toString(), style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 9, fontFamily: 'monospace')),
          ],
        ),
        SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 4,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        )
      ],
    );
  }

  Widget _buildRightColumn(double availableHeight) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('ROLL & PITCH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF666666))),
          SizedBox(height: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _buildTrimControl('elevator', isVertical: true),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: availableHeight * 0.4, maxHeight: availableHeight * 0.4),
                          child: JoystickWidget(
                            size: availableHeight * 0.4, maxSize: 160,
                            onChanged: (x, y) {
                              setState(() { aileronValue = x; elevatorValue = y; _onControlChanged(); });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                _buildTrimControl('aileron', isVertical: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Standard Widget Builders ---
  Widget _buildIconButton({required IconData icon, required String label, required VoidCallback onPressed, required Color color}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionButton() {
    bool isConnecting = statusMessage.contains("Connecting");
    return GestureDetector(
      onTap: _handleConnectionAction,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isConnected ? Color(0xFF4ECDC4) : (isConnecting ? Colors.grey : Color(0xFFFF6B35)),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: (isConnected ? Color(0xFF4ECDC4) : (isConnecting ? Colors.grey : Color(0xFFFF6B35))).withOpacity(0.3),
              blurRadius: 4, offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (isConnecting)
              Container(
                width: 14, height: 14, margin: EdgeInsets.only(right: 6),
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            else ...[
              Icon(isConnected ? Icons.link : Icons.link_off, color: Colors.white, size: 14),
              SizedBox(width: 6),
            ],
            Text(
              isConnected ? 'CONNECTED' : (isConnecting ? 'CONNECTING...' : 'CONNECT'),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrimControl(String control, {required bool isVertical}) {
    return isVertical
        ? SizedBox(
            width: 36,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TrimButton(icon: Icons.keyboard_arrow_up, onPressed: () => _adjustTrim(control, 1), color: Color(0xFFFF6B35)),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(color: Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(4)),
                  child: Text('T', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF333333)), textAlign: TextAlign.center),
                ),
                SizedBox(height: 6),
                TrimButton(icon: Icons.keyboard_arrow_down, onPressed: () => _adjustTrim(control, -1), color: Color(0xFFFF6B35)),
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TrimButton(icon: Icons.keyboard_arrow_left, onPressed: () => _adjustTrim(control, -1), color: Color(0xFFFF6B35)),
                SizedBox(width: 8),
                Container(
                  width: 28, padding: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(color: Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(4)),
                  child: Text('T', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF333333)), textAlign: TextAlign.center),
                ),
                SizedBox(width: 8),
                TrimButton(icon: Icons.keyboard_arrow_right, onPressed: () => _adjustTrim(control, 1), color: Color(0xFFFF6B35)),
              ],
            ),
          );
  }

  // ─── Helper Functions ────────────────────────────────────────
  void _resetTrims() {
    setState(() {
      aileronTrimOffset = 0.0; elevatorTrimOffset = 0.0;
      throttleTrimOffset = 0.0;
    });
    _onControlChanged();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trims Reset'), backgroundColor: Color(0xFFFF6B35)));
  }

  void _resetApp() {
    _connectionTimer?.cancel();
    // 1. Dispose existing connection to clear "stuck" states
    _droneController.dispose();
    
    // 2. Reset UI State
    setState(() {
      isConnected = false;
      isHoldMode = false;
      statusMessage = "Ready - Reset Complete";
      throttleValue = -1.0;
      aileronValue = 0.0;
      elevatorValue = 0.0;
    });

    // 3. Re-initialize Controller Logic (Same as initState)
    _droneController = DroneController(
      onStatusUpdate: (status) => setState(() => statusMessage = status),
      onConnected: (connected) {
        setState(() {
          isConnected = connected;
          if (connected) {
            _droneController.sendPIDPacket(rollP, rollI, rollD, pitchP, pitchI, pitchD, angleP, angleI, angleD);
          }
        });
      },
      onPIDUpdated: () {
        setState(() => statusMessage = "Drone Ready - FLY!");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PID Synced!'), backgroundColor: Color(0xFFFF6B35)));
      },
    );
    _loadSettings(); // Reload IP and settings
  }

  Future<void> _sendCalibration() async {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connect to Drone first!'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final ip = InternetAddress(_droneController.targetIP);
      const port = 4210; // Standard UDP port for ESP drones
      
      await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
        socket.send(utf8.encode("Cali"), ip, port);
        socket.close();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calibration Sent!'), backgroundColor: Color(0xFF4ECDC4)),
      );
    } catch (e) {
      print("Error sending calibration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleHold() async {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connect to Drone first!'), backgroundColor: Colors.red),
      );
      return;
    }

    final command = isHoldMode ? "UNHOLD" : "HOLD";

    try {
      final ip = InternetAddress(_droneController.targetIP);
      const port = 4210; // Standard UDP port for ESP drones
      
      await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
        socket.send(utf8.encode(command), ip, port);
        socket.close();
      });

      setState(() {
        isHoldMode = !isHoldMode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$command Command Sent!'), backgroundColor: Color(0xFF4ECDC4)),
      );
    } catch (e) {
      print("Error sending hold command: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _adjustTrim(String control, int direction) {
    setState(() {
      if (control == 'aileron') aileronTrimOffset = (aileronTrimOffset + direction * TRIM_STEP).clamp(-4095.0, 4095.0);
      else if (control == 'elevator') elevatorTrimOffset = (elevatorTrimOffset + direction * TRIM_STEP).clamp(-4095.0, 4095.0);
      else if (control == 'throttle') throttleTrimOffset = (throttleTrimOffset + direction * TRIM_STEP).clamp(-4095.0, 4095.0);
    });
    _onControlChanged();
  }

  void _onControlChanged() {
    if (isConnected) {
      int throttleADC = normalizedToADC(throttleValue + (throttleTrimOffset / 2047.5));
      int aileronADC = _applyInversion(normalizedToADC(aileronValue + (aileronTrimOffset / 2047.5)), invertAileron);
      int elevatorADC = _applyInversion(normalizedToADC(-elevatorValue + (elevatorTrimOffset / 2047.5)), invertElevator);
      _droneController.sendControlData(aileronADC, elevatorADC, throttleADC);
    }
    _updateValueDisplay();
  }

  void _handleConnectionAction() {
    bool isConnecting = statusMessage.contains("Connecting");
    if (isConnecting) return;

    if (isConnected) {
      _droneController.disconnect();
    } else {
      _droneController.connect();
      _connectionTimer?.cancel();
      _connectionTimer = Timer(Duration(seconds: 5), () {
        if (!isConnected) {
          setState(() {
            statusMessage = "Not Connected";
          });
          _droneController.disconnect();
        }
      });
    }
  }

  int _applyInversion(int value, bool invert) {
    return invert ? (4095 - value) : value;
  }

  // 4. Update the Logic to send Objects
  void _updateValueDisplay() {
    int t = normalizedToADC(throttleValue + (throttleTrimOffset / 2047.5));
    int a = _applyInversion(normalizedToADC(aileronValue + (aileronTrimOffset / 2047.5)), invertAileron);
    int e = _applyInversion(normalizedToADC(-elevatorValue + (elevatorTrimOffset / 2047.5)), invertElevator);
    
    // Create the Object
    final data = FlightTelemetry(
      rollP: rollP, rollI: rollI, rollD: rollD,
      pitchP: pitchP, pitchI: pitchI, pitchD: pitchD,
      angleP: angleP, angleI: angleI, angleD: angleD,
      aileron: a, elevator: e, throttle: t,
    );
    
    // Add to Stream
    _valueStreamController.add(data);
  }

  Future<void> _showPIDGridDialog() async {
    await showPIDDialog(
      context: context,
      rollP: rollP, rollI: rollI, rollD: rollD,
      pitchP: pitchP, pitchI: pitchI, pitchD: pitchD,
      angleP: angleP, angleI: angleI, angleD: angleD,
      isConnected: isConnected,
      onSave: (newRollP, newRollI, newRollD, newPitchP, newPitchI, newPitchD, newAngleP, newAngleI, newAngleD) async {
        setState(() {
          rollP = newRollP; rollI = newRollI; rollD = newRollD;
          pitchP = newPitchP; pitchI = newPitchI; pitchD = newPitchD;
          angleP = newAngleP; angleI = newAngleI; angleD = newAngleD;
        });

        final prefs = await SharedPreferences.getInstance();
        prefs.setDouble('rollP', rollP); prefs.setDouble('rollI', rollI); prefs.setDouble('rollD', rollD);
        prefs.setDouble('pitchP', pitchP); prefs.setDouble('pitchI', pitchI); prefs.setDouble('pitchD', pitchD);
        prefs.setDouble('angleP', angleP); prefs.setDouble('angleI', angleI); prefs.setDouble('angleD', angleD);

        if (isConnected) {
          _droneController.sendPIDPacket(rollP, rollI, rollD, pitchP, pitchI, pitchD, angleP, angleI, angleD);
        }
      },
    );
  }
} 