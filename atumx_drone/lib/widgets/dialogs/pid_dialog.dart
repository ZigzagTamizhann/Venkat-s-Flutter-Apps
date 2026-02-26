import 'package:flutter/material.dart';

Future<void> showPIDDialog({
  required BuildContext context,
  required double rollP,
  required double rollI,
  required double rollD,
  required double pitchP,
  required double pitchI,
  required double pitchD,
  required double angleP,
  required double angleI,
  required double angleD,
  required bool isConnected,
  required Function(
    double rollP,
    double rollI,
    double rollD,
    double pitchP,
    double pitchI,
    double pitchD,
    double angleP,
    double angleI,
    double angleD,
  ) onSave,
}) async {
  final cRp = TextEditingController(text: rollP.toStringAsFixed(2));
  final cRi = TextEditingController(text: rollI.toStringAsFixed(3));
  final cRd = TextEditingController(text: rollD.toStringAsFixed(3));
  final cPp = TextEditingController(text: pitchP.toStringAsFixed(2));
  final cPi = TextEditingController(text: pitchI.toStringAsFixed(3));
  final cPd = TextEditingController(text: pitchD.toStringAsFixed(3));
  final cAp = TextEditingController(text: angleP.toStringAsFixed(2));
  final cAi = TextEditingController(text: angleI.toStringAsFixed(3));
  final cAd = TextEditingController(text: angleD.toStringAsFixed(3));

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: Text('PID TUNING', style: TextStyle(color: Color(0xFF333333))),
        content: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPIDSection("ROLL", cRp, cRi, cRd),
                SizedBox(height: 16),
                _buildPIDSection("PITCH", cPp, cPi, cPd),
                SizedBox(height: 16),
                _buildPIDSection("ANGLE", cAp, cAi, cAd),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL', style: TextStyle(color: Color(0xFF666666))),
          ),
          ElevatedButton(
            onPressed: () {
              double safeParse(String v, double def) => double.tryParse(v) ?? def;
              onSave(
                safeParse(cRp.text, rollP),
                safeParse(cRi.text, rollI),
                safeParse(cRd.text, rollD),
                safeParse(cPp.text, pitchP),
                safeParse(cPi.text, pitchI),
                safeParse(cPd.text, pitchD),
                safeParse(cAp.text, angleP),
                safeParse(cAi.text, angleI),
                safeParse(cAd.text, angleD),
              );
              
              if (isConnected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('PID Sent to Drone!'),
                    backgroundColor: Color(0xFFFF6B35),
                  ),
                );
              }
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6B35),
            ),
            child: Text('SAVE & SYNC', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

Widget _buildPIDSection(String label, TextEditingController p, TextEditingController i, TextEditingController d) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
      SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: _buildPIDField("P", p)),
          SizedBox(width: 8),
          Expanded(child: _buildPIDField("I", i)),
          SizedBox(width: 8),
          Expanded(child: _buildPIDField("D", d)),
        ],
      ),
    ],
  );
}

Widget _buildPIDField(String label, TextEditingController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF666666)),
      ),
      SizedBox(height: 4),
      Container(
        height: 36,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFFFF6B35)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: TextStyle(fontSize: 12, fontFamily: 'RobotoMono'),
        ),
      ),
    ],
  );
}