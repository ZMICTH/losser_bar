import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PayOrder {
  String id;
  String tableNo;
  List<Map<String, dynamic>> orders;
  double totalPrice;
  String userId;
  DateTime billingTime;

  PayOrder({
    this.id = '',
    required this.tableNo,
    required this.orders,
    required this.totalPrice,
    required this.userId,
    required this.billingTime,
  });

  factory PayOrder.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> orders = (json['orders'] as List? ?? [])
        .map((order) => order as Map<String, dynamic>)
        .toList();

    return PayOrder(
      tableNo: json['tableNo'] as String? ?? 'default value',
      orders: orders,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      userId: json['userId'] as String? ?? 'default value',
      billingTime: json['billingTime'] as DateTime? ?? DateTime.now(),
    );
  }

  factory PayOrder.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data()! as Map<String, dynamic>; // Assuming data exists

    List<Map<String, dynamic>> orders = (json['orders'] as List? ?? [])
        .map((order) => order as Map<String, dynamic>)
        .toList();

    DateTime billingTime = (json['billingTime'] as Timestamp).toDate();

    return PayOrder(
      id: snapshot.id,
      tableNo: json['tableNo'] ?? 'default',
      orders: orders,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      userId: json['userId'] ?? 'default',
      billingTime: billingTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableNo': tableNo,
      'orders': orders.map((order) {
        return {
          'id': order['id'],
          'name': order['name'],
          'price': order['price'],
          'imagePath': order['imagePath'],
          'item': order['item'],
          'unit': order['unit'],
          'type': order['type'],
          'quantity': order['quantity'],
        };
      }).toList(),
      'totalPrice': totalPrice,
      'userId': userId,
      'billingTime': billingTime,
    };
  }
}

class AllOrderHistory {
  final List<PayOrder> ordersHistory;

  AllOrderHistory(this.ordersHistory);

  factory AllOrderHistory.fromJson(List<dynamic> json) {
    List<PayOrder> ordersHistory = json
        .map((item) => PayOrder.fromJson(item as Map<String, dynamic>))
        .toList();
    return AllOrderHistory(ordersHistory);
  }

  factory AllOrderHistory.fromSnapshot(QuerySnapshot snapshot) {
    List<PayOrder> ordersHistory = snapshot.docs.map((doc) {
      var order = PayOrder.fromSnapshot(doc);
      return order;
    }).toList();
    return AllOrderHistory(ordersHistory);
  }

  Map<String, dynamic> toJson() {
    print(ordersHistory);
    return {
      'ordersHistory': ordersHistory.map((order) => order.toJson()).toList(),
    };
  }
}

class OrderHistoryProvider extends ChangeNotifier {
  List<PayOrder> _allOrderHistory = [];
  List<PayOrder> get allOrderHistory => _allOrderHistory;

  void setAllOrderHistories(List<PayOrder> reservationtickets) {
    _allOrderHistory = reservationtickets;
    notifyListeners();
  }

  void setOrderHistories(List<PayOrder> userId) {
    var filteredList =
        _allOrderHistory.where((ticket) => ticket.userId == userId).toList();
    _allOrderHistory = filteredList;
    notifyListeners();
  }

  void clearOrderHistories() {
    _allOrderHistory = [];
    notifyListeners();
  }
}
