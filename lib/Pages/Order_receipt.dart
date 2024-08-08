import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/payorder_model.dart';

import 'package:losser_bar/Pages/controllers/payorder_controller.dart';
import 'package:losser_bar/Pages/controllers/pdf_document.dart';
import 'package:losser_bar/Pages/services/payorder_services.dart';
import 'package:provider/provider.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late OrderHistoryController orderhistorycontroller =
      OrderHistoryController(OrderHistoryFirebaseService());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    orderhistorycontroller =
        OrderHistoryController(OrderHistoryFirebaseService());
    _getOrderHistories();
  }

  Future<void> _getOrderHistories() async {
    setState(() => isLoading = true);
    try {
      final userId =
          FirebaseAuth.instance.currentUser?.uid; // Get current user's ID
      if (userId == null) {
        throw Exception("User not logged in");
      }

      List<PayOrder> fetchOrdersHistory =
          await orderhistorycontroller.fetchOrdersHistory();

      // Directly set the fetched order histories for the current user in the provider
      Provider.of<OrderHistoryProvider>(context, listen: false)
          .setAllOrderHistories(fetchOrdersHistory
              .where((receipts) => receipts.userId == userId)
              .toList());
    } catch (e) {
      print("Error fetching order history: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _getOrderNames(List<Map<String, dynamic>> orders) {
    return orders.map((order) => order['name'].toString()).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final orderHistoryProvider = Provider.of<OrderHistoryProvider>(context);
    List<PayOrder>? ordersHistory = orderHistoryProvider.allOrderHistory;
    // Create a NumberFormat instance for formatting
    final numberFormat = NumberFormat("#,##0", "en_US");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: const Text('Order History'),
      ),
      body: ordersHistory == null || ordersHistory.isEmpty
          ? const Center(child: Text('No Order History'))
          : ListView.builder(
              itemCount: ordersHistory.length,
              itemBuilder: (context, index) {
                final order = ordersHistory[index];
                // Format the billingTime using DateFormat
                final formattedBillingTime =
                    DateFormat('yyyy-MM-dd – kk:mm').format(order.billingTime);
                return InkWell(
                  child: Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.receipt_long, color: Colors.black),
                      title: Text(
                        'Billing Time: $formattedBillingTime',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      subtitle: Text(
                        'Table No: ${order.tableNo}\nTotal Price: ${numberFormat.format(order.totalPrice)} THB',
                        style: const TextStyle(color: Colors.black),
                      ),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OrderDetailPage(order: order),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class OrderDetailPage extends StatelessWidget {
  final PayOrder order;

  OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String orderNames = order.orders.map((o) {
      var name = o['name'].toString();
      var item = o['item'].toString();
      var unit = o['unit'].toString();
      return "$name, $item $unit";
    }).join(', ');

    String formattedBillingTime =
        DateFormat('yyyy-MM-dd – kk:mm').format(order.billingTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Table No: ${order.tableNo}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Billing Time: $formattedBillingTime',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Orders: $orderNames', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Total Price: ${order.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final pdfGenerator = PdfGenerator(order);
                  pdfGenerator.generatePdf();
                },
                child: Text('Generate PDF',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
