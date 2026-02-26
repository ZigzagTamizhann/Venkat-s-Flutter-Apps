import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/printer_service.dart';
import 'printer_selection_page.dart';

class OrderVerificationScreen extends StatefulWidget {
  final Order order;
  final List<OrderItem> orderItems;

  const OrderVerificationScreen({
    super.key,
    required this.order,
    required this.orderItems,
  });

  @override
  State<OrderVerificationScreen> createState() => _OrderVerificationScreenState();
}

class _OrderVerificationScreenState extends State<OrderVerificationScreen> {
  late String _currentStatus;
  final PrinterService _printerService = PrinterService();
  String _shopName = "";
  bool _showPrintButton = false;


  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
    _fetchShopName();

    // Fix: Check status case-insensitively (e.g. "Pending" vs "pending")
    if (_currentStatus.toLowerCase().trim() == 'pending') {
      _showPrintButton = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateStatus('prepare');
      });
    }
  }

  List<OrderItem> get _items =>
      widget.order.items.isNotEmpty ? widget.order.items : widget.orderItems;

  Future<void> _fetchShopName() async {
    if (widget.order.shopId.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('shopkeepers')
          .doc(widget.order.shopId)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>?;
        setState(() {
          _shopName = data?['shopName']?.toString() ?? data?['name']?.toString() ?? _shopName;
        });
      }
    } catch (e) {
      debugPrint("Error fetching shop name: $e");
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      debugPrint("Updating Order ${widget.order.id} status to: $newStatus");
      final orderRef = FirebaseFirestore.instance
          .collection('main_orders')
          .doc(widget.order.id);

      await orderRef.update({'status': newStatus});

      final orderSnapshot = await orderRef.get();
      final userId = orderSnapshot.data()?['userId'] as String?;

      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(userId)
            .collection('orders')
            .doc(widget.order.id)
            .update({'status': newStatus});
      }

      if (!mounted) return;

      setState(() {
        _currentStatus = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
      

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  String _getStatusText() {
    switch (_currentStatus) {
      case 'pending':
        return 'Pending';
      case 'prepare':
        return 'Prepare';
      case 'completed':
        return 'Ready for Pickup';
      default:
        return _currentStatus;
    }
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case 'pending':
        return Colors.orange;
      case 'prepare':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case 'pending':
        return Icons.schedule;
      case 'prepare':
        return Icons.restaurant;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = widget.order.createdAt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: "Select Printer",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrinterSelectionPage(),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ Status Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(),
                    size: 70,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getStatusText(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Order #${widget.order.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ✅ BILL / RECEIPT FORMAT
            _buildBillReceipt(createdAt),

            const SizedBox(height: 16),

            if (_showPrintButton)
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  _printerService.printOrderBill(widget.order, _items, shopName: _shopName, customStatus: _currentStatus);
                },
                icon: const Icon(Icons.print),
                label: const Text(
                  "Print Bill",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 28),

            // ✅ Buttons
            if (_currentStatus == 'pending')
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus('prepare'),
                  icon: const Icon(Icons.restaurant),
                  label: const Text(
                    'Start Preparing',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else if (_currentStatus == 'completed')
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    'Order Collected',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Scanner',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ BILL RECEIPT UI
  Widget _buildBillReceipt(DateTime createdAt) {
    final items = _items;

    final subTotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final tax = 0.0; // optional
    final grandTotal = subTotal + tax;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _shopName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "BILL / RECEIPT",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const Divider(thickness: 1.2),

            _billRow("Bill No", "#${widget.order.id.substring(0, 8)}"),
            _billRow(
              "Date",
              "${createdAt.day.toString().padLeft(2, '0')}-"
                  "${createdAt.month.toString().padLeft(2, '0')}-"
                  "${createdAt.year}",
            ),
            _billRow(
              "Time",
              "${createdAt.hour.toString().padLeft(2, '0')}:"
                  "${createdAt.minute.toString().padLeft(2, '0')}",
            ),
            if (widget.order.phone != null)
              _billRow("Phone", widget.order.phone!),

            _billRow(
              "Payment",
              widget.order.paymentStatus.toUpperCase(),
              valueColor: widget.order.paymentStatus == "paid"
                  ? Colors.green
                  : Colors.orange,
            ),

            _billRow(
              "Status",
              _getStatusText(),
              valueColor: _getStatusColor(),
            ),

            const SizedBox(height: 10),
            const Divider(thickness: 1.2),

            // table header
            Row(
              children: const [
                SizedBox(width: 28, child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text("Item", style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 70, child: Text("Rate", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 80, child: Text("Amount", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(),

            // items
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text("${item.quantity}")),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      child: Text(
                        "₹${item.price.toStringAsFixed(2)}",
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        "₹${item.totalPrice.toStringAsFixed(2)}",
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const Divider(thickness: 1.2),

            _amountRow("Subtotal", subTotal),
            _amountRow("Tax", tax),
            const SizedBox(height: 8),
            _amountRow("Grand Total", grandTotal, bold: true),

            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "Thank you! Visit again 😊",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _billRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                fontSize: bold ? 16 : 14,
              ),
            ),
          ),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
