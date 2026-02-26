import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../models/order.dart';

class PrinterService {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<void> printOrderBill(Order order, List<OrderItem> items, {String shopName = "SUPERMONEY FOOD", String? customStatus}) async {
    try {
      bool? isConnected = await bluetooth.isConnected;
      if (isConnected != true) return;

      double subTotal = items.fold(0, (sum, i) => sum + i.totalPrice);

      // 1. Header (Test code mariye)
      bluetooth.printNewLine();
      bluetooth.printCustom(shopName, 3, 1); // BIG CENTER
      bluetooth.printCustom("BILL / RECEIPT", 1, 1);
      bluetooth.printCustom("--------------------------------", 1, 1);

      // 2. Bill Details
      String dateStr = "${order.createdAt.day.toString().padLeft(2, '0')}-${order.createdAt.month.toString().padLeft(2, '0')}-${order.createdAt.year}";
      String timeStr = "${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}";

      bluetooth.printLeftRight("Bill No", "#${order.id.substring(0, 8)}", 1);
      bluetooth.printLeftRight("Date", dateStr, 1);
      bluetooth.printLeftRight("Time", timeStr, 1);
      if (order.phone != null && order.phone!.isNotEmpty) {
        bluetooth.printLeftRight("Phone", order.phone!, 1);
      }
      bluetooth.printLeftRight("Payment", order.paymentStatus.toUpperCase(), 1);
      bluetooth.printLeftRight("Status", (customStatus ?? order.status).toUpperCase(), 1);

      bluetooth.printNewLine();
      
      bluetooth.printCustom("--------------------------------", 1, 1);
      bluetooth.printLeftRight("Qty Item", "Amount", 1);
      bluetooth.printCustom("--------------------------------", 1, 1);

      // 3. Dynamic Items from Firebase (Looping)
      for (var item in items) {
        bluetooth.printLeftRight(
          "${item.quantity} x ${item.name}", 
          "Rs.${item.totalPrice.toStringAsFixed(2)}", 
          1
        );
      }

      // 4. Footer & Total
      bluetooth.printCustom("--------------------------------", 1, 1);
      bluetooth.printLeftRight("Subtotal", "Rs.${subTotal.toStringAsFixed(2)}", 1);
      bluetooth.printLeftRight("Tax", "Rs.0.00", 1);
      bluetooth.printCustom("--------------------------------", 1, 1);
      bluetooth.printLeftRight("Grand Total", "Rs.${subTotal.toStringAsFixed(2)}", 2); 
      bluetooth.printCustom("--------------------------------", 1, 1);
      
      bluetooth.printNewLine();
      bluetooth.printCustom("Thank you! Visit again", 1, 1);
      
      // Paper-a tear panna gap venum
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine();

    } catch (e) {
      print("Print error: $e");
    }
  }
}