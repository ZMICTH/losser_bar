import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:losser_bar/Pages/Model/bill_order_model.dart';

class BillHistoryService {
  Future<void> addBillHistory(BillOrder billOrder) async {
    try {
      await FirebaseFirestore.instance.collection('order_history').add({
        'order_history'
            'tableNo': billOrder.tableNo,
        'orders': billOrder.orders,
        'totalPrice': billOrder.totalPrice,
        'userId': billOrder.userId,
        'billingTime': billOrder.billingtime,
      });
      print("Bill history uploaded successfully");
    } catch (e) {
      print('Error adding bill history: $e');
    }
  }
}
