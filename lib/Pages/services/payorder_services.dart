import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:losser_bar/Pages/Model/payorder_model.dart';

abstract class OrderHistoryService {
  Future<List<PayOrder>> fetchOrdersHistory();
}

class OrderHistoryFirebaseService implements OrderHistoryService {
  @override
  Future<List<PayOrder>> fetchOrdersHistory() async {
    print("fetchOrdersHistory is called");
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('order_history')
        .where('userId')
        .get();
    print("Orders History count: ${qs.docs.length}");
    AllOrderHistory allOrderHistory = AllOrderHistory.fromSnapshot(qs);
    print(allOrderHistory.ordersHistory);
    return allOrderHistory.ordersHistory;
  }
}
