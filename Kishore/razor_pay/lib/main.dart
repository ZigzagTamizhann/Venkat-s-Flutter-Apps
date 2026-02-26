import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Razorpay Payment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
  
  // Your Razorpay Test Credentials
  final String testKeyId = "rzp_test_SKTOCq5T4OFEoR";

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    
    // Listen for payment success
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    
    // Listen for payment errors
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    
    // Listen for external wallet selection
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _openCheckout() {
    var options = {
      'key': testKeyId, // Your test key ID
      'amount': 100, // Amount in paise (500 INR = 50000 paise)
      'name': 'Skip Q',
      'description': 'Payment Description',
      'prefill': {
        'contact': '9876543210',
        'email': 'customer@example.com'
      },
      'theme': {
        'color': '#3399cc'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Payment Success!\nID: ${response.paymentId}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    debugPrint('Payment ID: ${response.paymentId}');
    debugPrint('Order ID: ${response.orderId}');
    debugPrint('Signature: ${response.signature}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✗ Payment Failed\nError: ${response.message}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    debugPrint('Error Code: ${response.code}');
    debugPrint('Error Message: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Wallet Selected: ${response.walletName}'),
        backgroundColor: Colors.orange,
      ),
    );
    debugPrint('Wallet: ${response.walletName}');
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Razorpay Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Payment Gateway',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Amount: ₹500',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: _openCheckout,
              icon: const Icon(Icons.payment),
              label: const Text('Pay Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                backgroundColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 30),
            const Card(
              margin: EdgeInsets.all(20),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Cards:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('Card: 4111 1111 1111 1111'),
                    Text('CVV: Any 3 digits'),
                    Text('Date: Any future date'),
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