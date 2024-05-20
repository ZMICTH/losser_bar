import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:losser_bar/Pages/Model/bill_order_model.dart';

abstract class BillHistoryService {
  Future<List<BillOrder>> getAllBillOrders();

  addBillHistory(BillOrder billOrder) {}
}

class BillHistoryFirebaseService implements BillHistoryService {
  @override
  Future<void> addBillHistory(BillOrder billOrder) async {
    try {
      await FirebaseFirestore.instance.collection('order_history').add({
        'tableNo': billOrder.tableNo,
        'roundtabel': billOrder.roundTable,
        'orders': billOrder.orders,
        'totalPrice': billOrder.totalPrice,
        'totalQuantity': billOrder.totalQuantity,
        'userId': billOrder.userId,
        'billingTime': billOrder.billingTime,
        'paymentStatus': billOrder.paymentStatus,
        'userNickName': billOrder.userNickName,
      });
      print("Bill history uploaded successfully");
    } catch (e) {
      print('Error adding bill history: $e');
    }
  }

  @override
  Future<List<BillOrder>> getAllBillOrders() async {
    try {
      QuerySnapshot qs = await FirebaseFirestore.instance
          .collection('order_history')
          .where('paymentStatus', isEqualTo: false)
          .get();
      print("BillOrder count: ${qs.docs.length}");

      AllBillOrder allBillOrder = AllBillOrder.fromSnapshot(qs);
      return allBillOrder.billOrders;
    } catch (e) {
      print("Error fetching Orders History: $e");
      throw e;
    }
  }
}
