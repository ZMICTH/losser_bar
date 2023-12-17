import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:losser_bar/Pages/Model/bill_historymodel.dart';

class BillHistoryService {
  Future<void> addBillHistory(BillHistory billHistory) async {
    try {
      await FirebaseFirestore.instance.collection('bill_history').add({
        'bill_history'
            'tableNo': billHistory.tableNo,
        'orders': billHistory.orders,
        'totalPrice': billHistory.totalPrice,
        'userId': billHistory.userId,
        'billingTime': billHistory.billingtime,
      });
      print("Bill history uploaded successfully");
    } catch (e) {
      print('Error adding bill history: $e');
    }
  }

  @override
  void updatebillpayment(BillHistory billHistory) {
    print('Updating bill history for id=${billHistory}');
    // FirebaseFirestore.instance
    //     .collection('bill_history')
    //     .doc(billpayment.id)
    //     .update({
    //   'tableNo': billpayment.tableNo,
    //   'nameFoodBeverage': billpayment.nameFoodBeverage,
    //   'priceFoodBeverage': billpayment.priceFoodBeverage,
    //   'quantity': billpayment.quantity,
    //   'totalPrice': billpayment.totalPrice,
    //   'userID': billpayment.userID,
    // });
  }
}
