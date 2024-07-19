import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:losser_bar/Pages/Model/bill_order_model.dart';

abstract class BillHistoryService {
  Future<List<OrderHistories>> getAllBillOrders();

  addBillHistory(BillOrder billOrder) {}
}

class BillHistoryFirebaseService implements BillHistoryService {
  @override
  Future<void> addBillHistory(BillOrder billOrder) async {
    try {
      await FirebaseFirestore.instance.collection('order_history').add({
        'orders': billOrder.orders,
        'totalPrice': billOrder.totalPrice,
        'totalQuantity': billOrder.totalQuantity,
        'partnerId': billOrder.partnerId,
        'billingTime': billOrder.billingTime,
        'paymentStatus': billOrder.paymentStatus,
        'userNickName': billOrder.userNickName,
        'tableNo': billOrder.tableNo,
        'roundtable': billOrder.roundtable,
        'userId': billOrder.userId,
      });
      print("Bill history uploaded successfully");
    } catch (e) {
      print('Error adding bill history: $e');
    }
  }

  @override
  Future<List<OrderHistories>> getAllBillOrders() async {
    print("getAllBillOrders is called");
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('order_history')
        .where('paymentStatus', isEqualTo: false)
        .get();
    print("BillOrder count: ${qs.docs.length}");
    AllOrderHistory OrderHistory = AllOrderHistory.fromSnapshot(qs);
    print(OrderHistory.orderHistories);
    return OrderHistory.orderHistories;
  }
}
