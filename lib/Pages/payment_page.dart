import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/bill_order_model.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';

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
  List<BillOrder> orders = [];
  int? value;
  bool filledSelected = false;
  Set<String> selectedOrders = Set();
  double totalPayment = 0.00;

  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat.yMMMMd().add_jm();

    return formatter.format(dateTime);
  }

  final paymentLabels = ['Qr-code Promptpay'];
  final paymentIcons = [Icons.qr_code_2_outlined, Icons.money];

  @override
  void initState() {
    super.initState();
    billHistoryController = BillHistoryController(BillHistoryFirebaseService());
    fetchBillOrders();
  }

  void fetchBillOrders() async {
    try {
      orders = await billHistoryController.fetchBillOrder();
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      // Handle error
      print("Failed to fetch bill orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text('Payments Order'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: orders
                        .map((order) => GestureDetector(
                              onTap: () {
                                print(order.id);
                                setState(() {
                                  if (selectedOrders.contains(order.id)) {
                                    selectedOrders.remove(order.id);
                                    totalPayment -= order.totalPrice;
                                  } else {
                                    selectedOrders.add(order.id);
                                    totalPayment += order.totalPrice;
                                  }
                                });
                              },
                              child: Card(
                                color: selectedOrders.contains(order.id)
                                    ? Color(0xff7a3e3e) // Selected color
                                    : Color.fromARGB(
                                        255, 250, 244, 235)!, // Normal color
                                margin: EdgeInsets.all(8.0),
                                elevation: selectedOrders.contains(order.id)
                                    ? 5.0
                                    : 1.0, // Elevated when selected
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: buildCardContents(order),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                displayTotalPayment(),
                paymentMethodList(),
                confirmPaymentMethod()
              ],
            ),
    );
  }

  Column buildCardContents(BillOrder order) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white60,
              ),
              height: 30,
              width: 150,
              child: Center(
                child: Text(
                  "Table: ${order.tableNo} - ${order.userNickName}",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            Text(
              formatDate(order.billingTime),
              style: TextStyle(color: Color(0xffadbc9f)),
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Text('Items', style: TextStyle(color: Colors.black)),
            ),
            Text('Price(THB)', style: TextStyle(color: Colors.black)),
          ],
        ),
        ...order.orders.map(
          (item) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                              "${item['quantity']}    ${item['name']} ${item['item']} ${item['unit']} ",
                              style: TextStyle(color: Colors.black)),
                        ),
                        Text("${item['price']}",
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Total: ${order.totalPrice.toStringAsFixed(2)}",
                style: TextStyle(
                    color: Color.fromARGB(255, 162, 180, 108), fontSize: 20)),
          ],
        ),
        if (selectedOrders.contains(order.id))
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Text(
                  "Selected",
                  style: TextStyle(color: Colors.grey[50]),
                ),
                Row(),
              ],
            ),
          ),
      ],
    );
  }

  Widget displayTotalPayment() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Total Payment: THB ${totalPayment.toStringAsFixed(2)}",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff224b0c)),
          ),
        ],
      ),
    );
  }

  ListView paymentMethodList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: paymentLabels.length,
      itemBuilder: (context, index) {
        return ListTile(
          selectedColor: Colors.blue[400],
          splashColor: Colors.cyan[100],
          leading: Radio(
            value: index,
            groupValue: value,
            onChanged: (int? i) {
              setState(() => value = i);
            },
          ),
          title: Text(paymentLabels[index],
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onBackground)),
          trailing: Icon(paymentIcons[index],
              size: 35, color: Theme.of(context).colorScheme.primary),
          onTap: () => setState(() => value = index),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  Padding confirmPaymentMethod() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        onPressed: performPayment,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(
          'Pay with ${paymentLabels[value ?? 0]}',
          style: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  void performPayment() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[600]!,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          title: Text('Confirm Payment'),
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
                        'paymentMethod': paymentLabels[value ?? 0],
                        'paymentStatus': true,
                      });
                    });

                    Provider.of<ProductModel>(context, listen: false)
                        .clearproduct();
                    Navigator.pop(
                        context); // Navigate back to the previous screen
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
}
