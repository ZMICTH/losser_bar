import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/bill_historymodel.dart';

import 'package:losser_bar/Pages/Model/product_model_page.dart';
import 'package:losser_bar/Pages/controllers/bill_controller.dart';
import 'package:losser_bar/Pages/services/bill_historyservice.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final Key? key;

  PaymentScreen({this.key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final BillHistoryController billHistoryController =
      BillHistoryController(BillHistoryService());
  final paymentLabels = ['Qr-code Promptpay'];
  final paymentIcons = [Icons.money, Icons.qr_code_2_outlined];

  String tableNo = "1";
  List<String> nameOrder = [];
  List<double> priceOrder = [];
  List<int> quantity = [];
  double totalPrice = 0.0;
  String userId = "D1jtXbIlHOhkjVRN8OEk";
  int? value = 0; // This is the correct field to use

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Payments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ProductModel>(builder: (context, model, child) {
        print("Call all model ${model.cart}");
        // var cartItems = model.cart; // Assuming this gets the list of cart items
        // if (cartItems.isEmpty) {
        //   return Center(
        //     child: Text(
        //       "Nothing in cart",
        //       style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        //     ),
        //   );
        // }
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: paymentLabels.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Radio(
                      activeColor: Theme.of(context).colorScheme.primary,
                      value: index,
                      groupValue: value,
                      onChanged: (int? i) => setState(() => value = i),
                    ),
                    title: Text(paymentLabels[index],
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground)),
                    trailing: Icon(paymentIcons[index],
                        color: Theme.of(context).colorScheme.primary),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: performPayment,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text('Pay with ${paymentLabels[value ?? 0]}',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      }),
    );
  }

  void performPayment() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Payment', style: TextStyle(color: Colors.black)),
          content: Image.asset('images/promtpay.jpeg',
              width: 300, height: 450, fit: BoxFit.cover),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Success', style: TextStyle(color: Colors.black)),
              onPressed: () async {
                try {
                  // Retrieve necessary data

                  var cart =
                      Provider.of<ProductModel>(context, listen: false).cart;
                  List<Map<String, dynamic>> billuser =
                      cart.cast<Map<String, dynamic>>();
                  totalPrice = Provider.of<ProductModel>(context, listen: false)
                      .getTotalPrice() as double;

                  print("UserID who pay this transaction $userId");

                  // Construct a list of orders

                  // Create BillHistory object
                  final billHistory = BillHistory(
                    tableNo: tableNo,
                    orders: billuser,
                    totalPrice: totalPrice,
                    userId: userId,
                    billingtime: DateTime.now(),
                  );

                  await billHistoryController.addBillHistory(billHistory);
                  print("Upload successful");

                  // Navigate to the success page
                  Provider.of<ProductModel>(context, listen: false)
                      .clearproduct();
                  Navigator.of(context).pushReplacementNamed('/home');
                } catch (e, d) {
                  // Handle error
                  print(d);
                  print('Error occurred: qr code $e');
                  // Optionally, show a snackbar or dialog with the error message
                }
              },
            ),
          ],
        );
      },
    );
  }
}
