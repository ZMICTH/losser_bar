import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/bill_order_model.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
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
  int? selectedPaymentMethod;
  Set<String> selectedOrders = Set();
  double totalPayment = 0.00;

  final paymentLabels = ['Qr-code Promptpay'];
  final paymentIcons = [Icons.qr_code_2_outlined, Icons.money];

  @override
  void initState() {
    super.initState();
    billHistoryController = BillHistoryController(BillHistoryFirebaseService());
    fetchBillOrders(context);
  }

  void fetchBillOrders(BuildContext context) async {
    try {
      List<OrderHistories> fetchedOrders =
          await billHistoryController.fetchBillOrder();
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
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Failed to fetch bill orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final billOrderProvider = Provider.of<BillOrderProvider>(context);
    orders = billOrderProvider.allOrderHistory;

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
                                            : sum + item['price'];
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
                    paymentMethodList(),
                    confirmPaymentButton()
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

  Widget paymentMethodList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: paymentLabels.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Radio(
            value: index,
            groupValue: selectedPaymentMethod,
            onChanged: (int? i) {
              setState(() => selectedPaymentMethod = i);
            },
          ),
          title: Text(paymentLabels[index],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          trailing: Icon(paymentIcons[index],
              size: 35, color: Theme.of(context).colorScheme.primary),
          onTap: () => setState(() => selectedPaymentMethod = index),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  Widget confirmPaymentButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        onPressed: performPayment,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: Text('Pay with ${paymentLabels[selectedPaymentMethod ?? 0]}',
            style: TextStyle(color: Colors.black87)),
      ),
    );
  }

  void performPayment() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[600]!,
          title: Text('Confirm Payment',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          content: QRCodeGenerate(
            promptPayId: "0987487348",
            amount: totalPayment,
            isShowAmountDetail: true,
            promptPayDetailCustom: Text("สิทธิวิชญ์ พิสิฐภูวโภคิน"),
            amountDetailCustom: Text('${totalPayment} THB'),
            width: 400,
            height: 400,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Success', style: TextStyle(color: Colors.black)),
              onPressed: () async {
                if (selectedOrders.isNotEmpty) {
                  try {
                    var currentUser =
                        Provider.of<MemberUserModel>(context, listen: false)
                            .memberUser;
                    final Timestamp now = Timestamp.now();

                    await Future.forEach(selectedOrders,
                        (String orderId) async {
                      await FirebaseFirestore.instance
                          .collection('order_history')
                          .doc(orderId)
                          .update({
                        'userIdPaid': currentUser?.id ?? 'Unknown',
                        'paidName': currentUser?.nicknameUser ?? 'Unknown',
                        'paymentTime': now.toDate(),
                        'totalPrice': totalPayment,
                        'paymentMethod':
                            paymentLabels[selectedPaymentMethod ?? 0],
                        'paymentStatus': true,
                      });
                    });

                    Provider.of<ProductModel>(context, listen: false)
                        .clearproduct();
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacementNamed('/home');
                  } catch (e) {
                    print('Error during payment update: $e');
                  }
                } else {
                  print('No order selected');
                }
              },
            ),
          ],
        );
      },
    );
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
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "${item['quantity']} ${item['name']} ${item['item']} ${item['unit']}",
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
                isCanceled ? "0" : "${item['price']}",
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
      return item['delivered'] == false ? sum : sum + item['price'];
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
