import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';
import 'order_verification_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isScanning = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) async {
    if (!_isScanning || _isLoading) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final String code = barcode.rawValue!;
        _fetchOrder(code);
        break;
      }
    }
  }

  Future<void> _fetchOrder(String orderId) async {
    setState(() {
      _isLoading = true;
      _isScanning = false;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('main_orders')
          .doc(orderId)
          .get();

      if (doc.exists) {
        final order = Order.fromFirestore(doc);
        if (!mounted) return;
        
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderVerificationScreen(
              order: order,
              orderItems: order.items,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order not found!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isScanning = true;
        });
      }
    }
  }

  void _toggleCamera() {
    setState(() {
      _isScanning = !_isScanning;
    });
    if (_isScanning) {
      _controller.start();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Order QR")),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black45,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _toggleCamera,
                    icon: Icon(
                      _isScanning ? Icons.videocam : Icons.videocam_off,
                      color: Colors.white,
                      size: 32,
                    ),
                    tooltip: _isScanning ? "Turn Camera Off" : "Turn Camera On",
                  ),
                  IconButton(
                    onPressed: () => _controller.switchCamera(),
                    icon: const Icon(
                      Icons.cameraswitch,
                      color: Colors.white,
                      size: 32,
                    ),
                    tooltip: "Switch Camera",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
