// lib/widgets/rgb_color_picker.dart
import 'package:flutter/material.dart';

/// Shows a bottom sheet RGB picker. Returns the picked Color or null.
Future<Color?> showRgbPicker(BuildContext context, {required Color initial}) {
  return showModalBottomSheet<Color>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RgbPickerSheet(initial: initial),
  );
}

class _RgbPickerSheet extends StatefulWidget {
  final Color initial;
  const _RgbPickerSheet({required this.initial});

  @override
  State<_RgbPickerSheet> createState() => _RgbPickerSheetState();
}

class _RgbPickerSheetState extends State<_RgbPickerSheet> {
  late int r, g, b;

  @override
  void initState() {
    super.initState();
    r = widget.initial.red;
    g = widget.initial.green;
    b = widget.initial.blue;
  }

  Color get _color => Color.fromARGB(255, r, g, b);

  String get _hex =>
      '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(width: 44, height: 5,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8))),

        const SizedBox(height: 18),

        // Title
        const Text('🎨 Pick a Color',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),

        const SizedBox(height: 20),

        // Color preview circle
        AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: 90, height: 90,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: _color.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)],
            border: Border.all(color: Colors.grey.shade200, width: 3),
          ),
        ),

        const SizedBox(height: 10),

        // Hex code
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(_hex,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  fontFamily: 'monospace', color: Color(0xFF555555))),
        ),

        const SizedBox(height: 24),

        // R slider
        _SliderRow(label: 'R', value: r, color: const Color(0xFFFF4444),
            onChanged: (v) => setState(() => r = v)),
        const SizedBox(height: 14),

        // G slider
        _SliderRow(label: 'G', value: g, color: const Color(0xFF44CC44),
            onChanged: (v) => setState(() => g = v)),
        const SizedBox(height: 14),

        // B slider
        _SliderRow(label: 'B', value: b, color: const Color(0xFF4488FF),
            onChanged: (v) => setState(() => b = v)),

        const SizedBox(height: 28),

        // Buttons
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text('Cancel',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF888888))),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context, _color),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: _color.withOpacity(0.45), blurRadius: 14, offset: const Offset(0, 5))],
                ),
                child: Center(
                  child: Text('Use This Color ✅',
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: _color.computeLuminance() > 0.4 ? Colors.black87 : Colors.white,
                      )),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ─── Single RGB Slider Row ────────────────────────────────────────────────────
class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  const _SliderRow({
    required this.label, required this.value,
    required this.color, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // Label badge
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
      ),
      const SizedBox(width: 12),

      // Slider
      Expanded(
        child: SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.15),
            thumbColor: color,
            overlayColor: color.withOpacity(0.15),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 6,
          ),
          child: Slider(
            min: 0, max: 255,
            value: value.toDouble(),
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ),

      const SizedBox(width: 8),

      // Value display
      Container(
        width: 42,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('$value',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
      ),
    ]);
  }
}