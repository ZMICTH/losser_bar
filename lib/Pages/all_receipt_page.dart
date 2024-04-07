import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/payorder_model.dart';

import 'package:losser_bar/Pages/controllers/payorder_controller.dart';
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
    // _listenToSync();
  }

  // void _listenToSync() {
  //   orderhistorycontroller.onSync.listen((isLoading) {
  //     setState(() {
  //       _isLoading = isLoading;
  //     });
  //   });
  // }

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
                        'Table No: ${order.tableNo}\nTotal Price: ${order.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      isThreeLine: true,
                      onTap: () => _showOrderDetailDialog(context, order),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showOrderDetailDialog(BuildContext context, PayOrder order) {
    final formattedBillingTime =
        DateFormat('yyyy-MM-dd – kk:mm').format(order.billingTime);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Order Receipt',
            style: TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Table No: ${order.tableNo}',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Orders: ${_getOrderNames(order.orders)}',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Total Price: ${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Billing Time: $formattedBillingTime',
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
