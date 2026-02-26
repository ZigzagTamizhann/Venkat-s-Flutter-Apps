import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/sign_data.dart';
import 'dart:math';

class CameraPracticeScreen extends StatefulWidget {
  final SignData signData;

  const CameraPracticeScreen({Key? key, required this.signData}) : super(key: key);

  @override
  State<CameraPracticeScreen> createState() => _CameraPracticeScreenState();
}

class _CameraPracticeScreenState extends State<CameraPracticeScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _feedback = '';
  int _points = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(() {
          _feedback = 'No camera found';
        });
        return;
      }

      // Find front camera
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _feedback = 'Camera error: $e';
        });
      }
    }
  }

  void _simulateAIFeedback() {
    setState(() {
      _isProcessing = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final random = Random();
        final feedbacks = [
          'Great thumb position! +5 points 🎉',
          'Perfect hand shape! +5 points ⭐',
          'Excellent! Keep it up! +5 points 💪',
          'Amazing! You got it! +5 points 🌟',
          'Try to keep fingers more straight +2 points 👍',
          'Good attempt! Practice more +3 points 📚',
        ];

        final selectedFeedback = feedbacks[random.nextInt(feedbacks.length)];
        final earnedPoints = random.nextInt(3) + 3;

        setState(() {
          _feedback = selectedFeedback;
          _points += earnedPoints;
          _isProcessing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice ${widget.signData.letter}'),
        backgroundColor: Colors.blue[400],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[300]!,
              Colors.cyan[200]!,
            ],
          ),
        ),
        child: Column(
          children: [
            // Instructions
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    'Sign: ${widget.signData.letter}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.signData.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Points Earned: '),
                      Text(
                        '$_points',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const Text(' ⭐'),
                    ],
                  ),
                ],
              ),
            ),

            // Camera Preview
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                clipBehavior: Clip.hardEdge,
                child: _isCameraInitialized && _controller != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraPreview(_controller!),
                          if (_isProcessing)
                            Container(
                              color: Colors.black.withOpacity(0.3),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          // Guide Overlay
                          CustomPaint(
                            painter: HandGuidePainter(),
                          ),
                        ],
                      )
                    : Center(
                        child: _feedback.isNotEmpty
                            ? Text(
                                _feedback,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              )
                            : const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                      ),
              ),
            ),

            // Feedback Display
            if (_feedback.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _feedback,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _simulateAIFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        '📸 Check My Sign',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Icon(Icons.check, size: 30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HandGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    canvas.drawCircle(center, radius, paint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Place hand here',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + radius + 20,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
