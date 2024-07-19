import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/bill_order_model.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:provider/provider.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:losser_bar/Pages/Model/login_model.dart';

class PaymentDetailScreen extends StatefulWidget {
  final String paymentMethod;
  final List<String> selectedOrders; // Add this field

  PaymentDetailScreen({
    required this.paymentMethod,
    required this.selectedOrders,
  }); // Update constructor

  @override
  _PaymentDetailScreenState createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  double totalPrice = 0.0;
  bool isLoading = true;
  List<String> userIds = [];

  @override
  void initState() {
    super.initState();
    calculateTotalPrice();
  }

  void calculateTotalPrice() async {
    final billOrderProvider =
        Provider.of<BillOrderProvider>(context, listen: false);
    final reserveTableProvider =
        Provider.of<ReserveTableProvider>(context, listen: false);
    final currentUser =
        Provider.of<MemberUserModel>(context, listen: false).memberUser;

    double calculatedPrice = 0.0;

    switch (widget.paymentMethod) {
      case 'Total':
        for (var order in billOrderProvider.allOrderHistory) {
          if (widget.selectedOrders.contains(order.id)) {
            calculatedPrice += order.totalPrice;
          }
        }
        userIds = reserveTableProvider.getAllSharedWith();
        print('Total payment calculated: $calculatedPrice');
        break;
      case 'Split':
        int sharedWithCount = reserveTableProvider.totalSharedWithCount;
        print('Shared With Count: $sharedWithCount');
        if (sharedWithCount > 0) {
          for (var order in billOrderProvider.allOrderHistory) {
            if (widget.selectedOrders.contains(order.id)) {
              calculatedPrice += order.totalPrice / sharedWithCount;
            }
          }
        }
        userIds = reserveTableProvider.getAllSharedWith();
        print('Split payment calculated: $calculatedPrice');
        break;
      case 'Individual':
        for (var order in billOrderProvider.allOrderHistory) {
          if (order.userId == currentUser?.id &&
              widget.selectedOrders.contains(order.id)) {
            calculatedPrice += order.totalPrice;
          }
        }
        userIds = [currentUser?.id ?? 'Unknown'];
        print('Individual payment calculated: $calculatedPrice');
        break;
      default:
        break;
    }

    setState(() {
      totalPrice = calculatedPrice;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Payment Detail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Total Payment: THB ${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff224b0c))),
                  SizedBox(height: 20),
                  QRCodeGenerate(
                    promptPayId: "0987487348",
                    amount: totalPrice,
                    isShowAmountDetail: true,
                    promptPayDetailCustom: Text("สิทธิวิชญ์ พิสิฐภูวโภคิน"),
                    amountDetailCustom: Text('${totalPrice} THB'),
                    width: 400,
                    height: 400,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.paymentMethod == 'Split') {
                        _updatePaymentStatusBySplit();
                      } else if (widget.paymentMethod == 'Total') {
                        _updatePaymentStatusByTotal();
                      } else if (widget.paymentMethod == 'Individual') {
                        _updatePaymentStatusByIndividual();
                      }
                    },
                    child: Text('Success Payment'),
                  )
                ],
              ),
            ),
    );
  }

  void _updatePaymentStatusBySplit() async {
    final currentUser =
        Provider.of<MemberUserModel>(context, listen: false).memberUser;
    final Timestamp now = Timestamp.now();
    final reserveTableProvider =
        Provider.of<ReserveTableProvider>(context, listen: false);

    List<Map<String, dynamic>> splitPayments = [];

    for (var userId in userIds) {
      splitPayments.add({
        'userId': userId,
        'amountPaid': totalPrice,
        'paymentTime': now.toDate(),
      });
    }

    for (var orderId in widget.selectedOrders) {
      await FirebaseFirestore.instance
          .collection('order_history')
          .doc(orderId)
          .update({
        'PaymentsBy': splitPayments,
        'paymentStatus': true,
      });
    }
    Navigator.pop(context);
  }

  void _updatePaymentStatusByTotal() async {
    final currentUser =
        Provider.of<MemberUserModel>(context, listen: false).memberUser;
    final Timestamp now = Timestamp.now();

    List<Map<String, dynamic>> totalPayment = [
      {
        'userId': currentUser?.id ?? 'Unknown',
        'amountPaid': totalPrice,
        'paymentTime': now.toDate(),
      }
    ];

    for (var orderId in widget.selectedOrders) {
      await FirebaseFirestore.instance
          .collection('order_history')
          .doc(orderId)
          .update({
        'PaymentsBy': totalPayment,
        'paymentStatus': true,
      });
    }
    Navigator.pop(context);
  }

  void _updatePaymentStatusByIndividual() async {
    final currentUser =
        Provider.of<MemberUserModel>(context, listen: false).memberUser;
    final Timestamp now = Timestamp.now();

    List<Map<String, dynamic>> individualPayment = [
      {
        'userId': currentUser?.id ?? 'Unknown',
        'amountPaid': totalPrice,
        'paymentTime': now.toDate(),
      }
    ];

    for (var order in Provider.of<BillOrderProvider>(context, listen: false)
        .allOrderHistory) {
      if (order.userId == currentUser?.id &&
          widget.selectedOrders.contains(order.id)) {
        await FirebaseFirestore.instance
            .collection('order_history')
            .doc(order.id)
            .update({
          'PaymentsBy': individualPayment,
          'paymentStatus': true,
        });
      }
    }
    Navigator.pop(context);
  }
}
