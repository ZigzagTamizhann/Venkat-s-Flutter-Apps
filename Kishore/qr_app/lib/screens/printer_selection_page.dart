import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterSelectionPage extends StatefulWidget {
  const PrinterSelectionPage({super.key});

  @override
  State<PrinterSelectionPage> createState() => _PrinterSelectionPageState();
}

class _PrinterSelectionPageState extends State<PrinterSelectionPage> {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    loadDevices();
  }

  void loadDevices() async {
    devices = await bluetooth.getBondedDevices();
    setState(() {});
  }

  Future<void> connectPrinter() async {
    if (selectedDevice != null) {
      try {
        await bluetooth.connect(selectedDevice!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Printer Connected Successfully")),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connection Failed: Is the printer on?"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Printer")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<BluetoothDevice>(
              hint: const Text("Choose Printer"),
              value: selectedDevice,
              isExpanded: true,
              items: devices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(device.name ?? "Unknown Device"),
                );
              }).toList(),
              onChanged: (device) {
                setState(() {
                  selectedDevice = device;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: connectPrinter,
              icon: const Icon(Icons.bluetooth_connected),
              label: const Text("Connect Printer"),
            ),
          ],
        ),
      ),
    );
  }
}
