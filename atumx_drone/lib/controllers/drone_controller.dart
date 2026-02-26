import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class DroneController {
  String targetIP = "192.168.4.1";
  int targetPort = 4210;
  
  RawDatagramSocket? _socket;
  InternetAddress? _targetAddress;
  Timer? _heartbeatTimer;
  
  
  final Function(String) onStatusUpdate;
  final Function(bool) onConnected;
  final Function()? onPIDUpdated;
  
  DroneController({
    required this.onStatusUpdate,
    required this.onConnected,
    this.onPIDUpdated,
  });
  
  Future<void> connect() async {
    if (_socket != null && _heartbeatTimer != null) return;
    
    onStatusUpdate("Connecting to $targetIP...");
    
    try {
      _socket?.close();
      _targetAddress = InternetAddress(targetIP);
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      
      _socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram != null) {
            final response = String.fromCharCodes(datagram.data).trim();
            _handleIncomingPacket(response);
          }
        }
      });
      
      _socket!.send(Uint8List.fromList('PING'.codeUnits), _targetAddress!, targetPort);
      
    } catch (e) {
      onStatusUpdate("Connection Failed: $e");
      onConnected(false);
    }
  }
  
  void _handleIncomingPacket(String response) {
    if (response == 'PONG') {
      onConnected(true);
      onStatusUpdate("Connected! Syncing PID...");
      
      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        // Control data is sent from RCController directly
      });
    } else if (response.contains("PID_UPDATED")) {
      onPIDUpdated?.call();
    }
  }
  
  void disconnect() {
    _socket?.close();
    _heartbeatTimer?.cancel();
    _socket = null;
    _heartbeatTimer = null;
    
    onStatusUpdate("Disconnected");
    onConnected(false);
  }
  
  void sendPIDPacket(double rollP, double rollI, double rollD, double pitchP, double pitchI, double pitchD, double angleP, double angleI, double angleD) {
    if (_socket == null || _targetAddress == null) return;
    
    String pidString = 
        "Rp: ${rollP.toStringAsFixed(2)} | Ri: ${rollI.toStringAsFixed(3)} | Rd: ${rollD.toStringAsFixed(3)} | "
        "Pp: ${pitchP.toStringAsFixed(2)} | Pi: ${pitchI.toStringAsFixed(3)} | Pd: ${pitchD.toStringAsFixed(3)} |"
        "Ap: ${angleP.toStringAsFixed(2)} | Ai: ${angleI.toStringAsFixed(3)} | Ad: ${angleD.toStringAsFixed(3)}"; ;
        
    List<int> data = utf8.encode(pidString);
    try {
      _socket!.send(data, _targetAddress!, targetPort);
    } catch (e) {
      print("Error sending PID: $e");
    }
  }
  
  void sendControlData(int aileronADC, int elevatorADC, int throttleADC) {
    if (_socket == null || _targetAddress == null) return;
    
    String dataString = "A: $aileronADC | E: $elevatorADC | T: $throttleADC";
    List<int> data = utf8.encode(dataString);
    
    try {
      _socket!.send(data, _targetAddress!, targetPort);
    } catch (e) {
      print("Send Error: $e");
    }
  }
  
  void dispose() {
    _socket?.close();
    _heartbeatTimer?.cancel();
  }
}