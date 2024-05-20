import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BillOrder {
  String id = "";
  String tableNo;
  String roundTable;
  List<Map<String, dynamic>> orders;
  // Each order is a Map with details
  double totalPrice;
  double totalQuantity;
  String userId;
  DateTime billingTime;
  bool paymentStatus;
  String userNickName;

  BillOrder({
    this.id = "",
    required this.tableNo,
    required this.roundTable,
    required this.orders,
    required this.totalPrice,
    required this.totalQuantity,
    required this.userId,
    required this.billingTime,
    required this.paymentStatus,
    required this.userNickName,
  });

  factory BillOrder.fromJson(Map<String, dynamic> json) {
    print(json);
    return BillOrder(
      id: json['id'] ?? "",
      tableNo: json['tableNo'] as String? ?? "",
      roundTable: json['roundTable'] as String? ?? "",
      orders: (json['orders'] as List<dynamic>? ?? [])
          .map<Map<String, dynamic>>((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      totalQuantity: json['totalQuantity'] ?? 0,
      userId: json['userId'] as String? ?? "",
      billingTime:
          (json['billingTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentStatus: json['paymentStatus'] as bool? ?? false,
      userNickName: json['userNickName'] as String? ?? "",
    );
  }

  factory BillOrder.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data() as Map<String, dynamic>;
    return BillOrder(
      id: snapshot.id,
      tableNo: json['tableNo'],
      roundTable: json['roundTable'],
      orders: (json['orders'] as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
      totalPrice: json['totalPrice'],
      totalQuantity: json['totalQuantity'],
      userId: json['userId'],
      billingTime: (json['billingTime'] as Timestamp).toDate(),
      paymentStatus: json['paymentStatus'],
      userNickName: json['userNickName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableNo': tableNo,
      'roundtabel': roundTable,
      'orders': orders
          .map((order) => {
                'name': order['name'],
                'price': order['price'],
                'imagePath': order['imagePath'],
                'item': order['item'],
                'unit': order['unit'],
                'type': order['type'],
                'quantity': order['quantity'],
              })
          .toList(),
      'totalPrice': totalPrice,
      'totalQuantity': totalQuantity,
      'userId': userId,
      'billingTime': billingTime,
      'paymentStatus': paymentStatus,
      'userNickName': userNickName,
    };
  }
}

class AllBillOrder {
  final List<BillOrder> billOrders;

  AllBillOrder(this.billOrders);

  factory AllBillOrder.fromJson(List<dynamic> json) {
    List<BillOrder> billOrders =
        json.map((item) => BillOrder.fromJson(item)).toList();
    return AllBillOrder(billOrders);
  }

  factory AllBillOrder.fromSnapshot(QuerySnapshot qs) {
    List<BillOrder> billOrders = qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> dataWithId = ds.data() as Map<String, dynamic>;
      dataWithId['id'] = ds.id;
      return BillOrder.fromJson(dataWithId);
    }).toList();
    return AllBillOrder(billOrders);
  }

  Map<String, dynamic> toJson() {
    return {
      'reservetables':
          billOrders.map((billOrders) => billOrders.toJson()).toList(),
    };
  }
}

class BillOrderProvider extends ChangeNotifier {
  List<BillOrder> _allBillOrder = [];

  List<BillOrder> get allBillOrder => _allBillOrder;

  void setBillOrder(List<BillOrder> billingorder) {
    _allBillOrder = billingorder;
    notifyListeners();
  }

  void setBillOrderForUser(String userId) {
    var filteredList =
        _allBillOrder.where((ticket) => ticket.userId == userId).toList();
    _allBillOrder = filteredList;
    notifyListeners();
  }

  void clearbillingorder() {
    allBillOrder.clear();
    notifyListeners();
  }
}
