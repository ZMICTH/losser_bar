import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/bill_order_model.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:losser_bar/Pages/payment_detail.dart';
import 'package:losser_bar/Pages/provider/partner_model.dart';
import 'package:losser_bar/Pages/provider/product_model_page.dart';
import 'package:losser_bar/Pages/controllers/bill_order_controller.dart';
import 'package:losser_bar/Pages/services/bill_historyservice.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final Key? key;

  PaymentScreen({this.key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late BillHistoryController billHistoryController;
  bool isLoading = true;
  List<OrderHistories> orders = [];
  String? selectedPaymentMethod;
  Set<String> selectedOrders = Set();
  double totalPayment = 0.00;
  bool hasPendingOrder = false;

  final paymentLabels = ['Total', 'Split', 'Individual'];
  final paymentIcons = [Icons.qr_code_2_outlined, Icons.money];

  @override
  void initState() {
    super.initState();
    billHistoryController = BillHistoryController(BillHistoryFirebaseService());
    fetchBillOrders();
  }

  void fetchBillOrders() async {
    try {
      List<OrderHistories> fetchedOrders =
          await billHistoryController.fetchBillOrder();
      if (mounted) {
        Provider.of<BillOrderProvider>(context, listen: false)
            .setBillOrder(fetchedOrders);

        final reserveTableProvider =
            Provider.of<ReserveTableProvider>(context, listen: false);
        if (reserveTableProvider.allReserveTable.isNotEmpty) {
          String tableNo =
              reserveTableProvider.allReserveTable.first.tableNo ?? '';
          String roundtable =
              reserveTableProvider.allReserveTable.first.roundtable ?? '';
          Provider.of<BillOrderProvider>(context, listen: false)
              .setBillOrderForTableAndRoundtable(tableNo, roundtable, context);
        }

        setState(() {
          orders = Provider.of<BillOrderProvider>(context, listen: false)
              .allOrderHistory;
          isLoading = false;
          selectAllOrders();
        });

        listenForPaymentMethod();
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      print("Failed to fetch bill orders: $e");
    }
  }

  void selectAllOrders() {
    double total = 0.0;
    for (var order in orders) {
      bool includeOrder = true;
      for (var item in order.orders) {
        if (item['delivered'] == null) {
          setState(() {
            hasPendingOrder = true;
          });
          return;
        }
        if (item['delivered'] == false) {
          includeOrder = false;
          break;
        }
      }
      if (includeOrder) {
        selectedOrders.add(order.id);
        total += order.totalPrice;
      }
    }
    setState(() {
      totalPayment = total;
    });
  }

  void listenForPaymentMethod() {
    final billOrderProvider =
        Provider.of<BillOrderProvider>(context, listen: false);
    billOrderProvider.addListener(() {
      if (!mounted) return;
      for (var order in billOrderProvider.allOrderHistory) {
        if (order.paymentMethod != null && order.paymentMethod!.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentDetailScreen(
                paymentMethod: order.paymentMethod!,
                selectedOrders: selectedOrders.toList(),
              ),
            ),
          );
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final billOrderProvider = Provider.of<BillOrderProvider>(context);
    orders = billOrderProvider.allOrderHistory;

    // เพิ่มการตรวจสอบข้อมูล paymentMethod ใน build method
    for (var order in orders) {
      if (order.paymentMethod != null && order.paymentMethod!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentDetailScreen(
                paymentMethod: order.paymentMethod!,
                selectedOrders: selectedOrders.toList(),
              ),
            ),
          );
        });
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Payments Order',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<BillOrderProvider>(
              builder: (context, billOrderProvider, child) {
                orders = billOrderProvider.allOrderHistory;

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final orderStatus = getOrderStatus(order.orders);
                          final isSelectable = orderStatus == "Delivered";

                          return GestureDetector(
                            onTap: isSelectable
                                ? () {
                                    setState(() {
                                      double orderTotalPrice =
                                          order.orders.fold(0.0, (sum, item) {
                                        return item['delivered'] == false
                                            ? sum
                                            : sum +
                                                (item['price'] as num)
                                                    .toDouble();
                                      });
                                      if (selectedOrders.contains(order.id)) {
                                        selectedOrders.remove(order.id);
                                        totalPayment -= orderTotalPrice;
                                      } else {
                                        selectedOrders.add(order.id);
                                        totalPayment += orderTotalPrice;
                                      }
                                    });
                                  }
                                : null,
                            child: OrderCard(
                              order: order,
                              isSelected: selectedOrders.contains(order.id),
                              orderStatus: orderStatus,
                              isSelectable: isSelectable,
                            ),
                          );
                        },
                      ),
                    ),
                    displayTotalPayment(),
                    if (!hasPendingOrder) paymentMethodDropdown(),
                    if (!hasPendingOrder) confirmPaymentMethodButton()
                  ],
                );
              },
            ),
    );
  }

  Widget displayTotalPayment() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("Total Payment: THB ${totalPayment.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff224b0c))),
        ],
      ),
    );
  }

  Widget paymentMethodDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Please Select Payment Method:',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange[900]),
          ),
          DropdownButton<String>(
            value: selectedPaymentMethod,
            hint: Text('Select Payment Method'),
            alignment: Alignment.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            items: paymentLabels.map((label) {
              return DropdownMenuItem<String>(
                alignment: Alignment.center,
                value: label,
                child: Text(label),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedPaymentMethod = value;
              });
              print(value);
            },
          ),
        ],
      ),
    );
  }

  Widget confirmPaymentMethodButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        onPressed: () => _updatePaymentMethod(context),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: Text('Pay by ${selectedPaymentMethod ?? 'Select Method'}',
            style: TextStyle(color: Colors.black87)),
      ),
    );
  }

  void _updatePaymentMethod(BuildContext context) async {
    if (selectedOrders.isNotEmpty && selectedPaymentMethod != null) {
      try {
        final Timestamp now = Timestamp.now();

        await Future.forEach(selectedOrders, (String orderId) async {
          await FirebaseFirestore.instance
              .collection('order_history')
              .doc(orderId)
              .update({
            'paymentMethodTime': now.toDate(),
            'paymentMethod': selectedPaymentMethod,
          });
        });

        Provider.of<ProductModel>(context, listen: false).clearproduct();

        // Navigate to payment page based on selected payment method
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailScreen(
              paymentMethod: selectedPaymentMethod,
              selectedOrders: selectedOrders.toList(), // Pass selectedOrders
            ),
          ),
        );
      } catch (e) {
        print('Error during payment update: $e');
      }
    } else {
      print('No order selected or payment method not selected');
    }
  }

  String getOrderStatus(List<Map<String, dynamic>> orders) {
    bool hasDelivered = false;
    bool hasPending = false;
    bool allCanceled = true;

    for (var order in orders) {
      if (order['delivered'] == null) {
        hasPending = true;
      }
      if (order['delivered'] == true) {
        hasDelivered = true;
        allCanceled = false;
      }
      if (order['delivered'] == false) {
        allCanceled = allCanceled && true;
      } else {
        allCanceled = false;
      }
    }

    if (hasPending) return "Order pending";
    if (allCanceled) return "Order Cancel";
    if (hasDelivered) return "Delivered";
    return "Delivered"; // Default to delivered if there's any delivered item
  }
}

class OrderCard extends StatelessWidget {
  final OrderHistories order;
  final bool isSelected;
  final bool isSelectable;
  final String orderStatus;

  OrderCard({
    required this.order,
    required this.isSelected,
    required this.isSelectable,
    required this.orderStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: isSelected
              ? Color(0xff7a3e3e)
              : Color.fromARGB(255, 250, 244, 235),
          margin: EdgeInsets.all(8.0),
          elevation: isSelected ? 5.0 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildHeader(),
                SizedBox(height: 15),
                buildItemList(order.orders),
                SizedBox(height: 12),
                buildTotal(order, orderStatus),
                if (isSelected) buildSelectedTag(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Row buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white60,
          ),
          height: 60,
          width: 150,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Table: ${order.tableNo}",
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  "By ${order.userNickName}",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        Text(
          DateFormat.yMMMMd().add_jm().format(order.billingTime),
          style: TextStyle(color: Color.fromARGB(255, 162, 176, 149)),
        ),
      ],
    );
  }

  Column buildItemList(List<Map<String, dynamic>> items) {
    return Column(
      children: items.map((item) {
        bool isCanceled = item['delivered'] == false;
        double itemTotalPrice = (item['quantity'] as num).toDouble() *
            (item['price'] as num).toDouble();
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "${item['name']} ${item['item']} ${item['unit']} X ${item['quantity']}",
                  style: TextStyle(
                    color: isCanceled ? Colors.red : Colors.black,
                    decoration: isCanceled
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: isCanceled ? Colors.red : Colors.black,
                  ),
                ),
              ),
              Text(
                isCanceled ? "0" : "${itemTotalPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  color: isCanceled ? Colors.red : Colors.black,
                  decoration: isCanceled
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: isCanceled ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Row buildTotal(OrderHistories order, String orderStatus) {
    double totalPrice = order.orders.fold(0.0, (sum, item) {
      return item['delivered'] == false
          ? sum
          : sum +
              (item['quantity'] as num).toDouble() *
                  (item['price'] as num).toDouble();
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          orderStatus,
          style: TextStyle(
            color: getOrderStatusColor(orderStatus),
            fontSize: 20,
          ),
        ),
        SizedBox(width: 10),
        Text(
          "Total: ${totalPrice.toStringAsFixed(2)}",
          style: TextStyle(
            color: Color.fromARGB(255, 162, 180, 108),
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Color getOrderStatusColor(String orderStatus) {
    if (orderStatus == "Order pending") return Colors.orange;
    if (orderStatus == "Order Cancel") return Colors.red;
    return Colors.green;
  }

  Padding buildSelectedTag() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text("Selected", style: TextStyle(color: Colors.grey[50])),
    );
  }
}
