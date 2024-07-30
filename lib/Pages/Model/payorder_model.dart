import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PayOrder {
  String id = "";
  List<Map<String, dynamic>> orders;
  double totalPrice;
  double totalQuantity;
  String partnerId;
  DateTime billingTime;
  bool paymentStatus;
  String userNickName;
  String tableNo;
  String roundtable;
  String userId;
  String paymentMethod;
  List<Map<String, dynamic>> paymentsBy;

  PayOrder({
    this.id = "",
    required this.orders,
    required this.totalPrice,
    required this.totalQuantity,
    required this.partnerId,
    required this.billingTime,
    required this.paymentStatus,
    required this.userNickName,
    required this.tableNo,
    required this.roundtable,
    required this.userId,
    required this.paymentMethod,
    required this.paymentsBy,
  });

  factory PayOrder.fromJson(Map<String, dynamic> json) {
    print(json);
    return PayOrder(
      id: json['id'] as String,
      orders: (json['orders'] as List<dynamic>? ?? [])
          .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      totalQuantity: json['totalQuantity'] ?? 0,
      partnerId: json['partnerId'] as String,
      billingTime:
          (json['billingTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentStatus: json['paymentStatus'] as bool? ?? false,
      userNickName: json['userNickName'] as String? ?? "",
      tableNo: json['tableNo'] as String? ?? "",
      roundtable: json['roundtable'] as String? ?? "",
      userId: json['userId'] as String? ?? "",
      paymentMethod: json['paymentMethod'] as String? ?? "",
      paymentsBy: (json['paymentsBy'] as List<dynamic>? ?? [])
          .map<Map<String, dynamic>>((item) => {
                'amountPaid': (item['amountPaid'] as num).toDouble(),
                'paymentTime': (item['paymentTime'] as Timestamp).toDate(),
                'userId': item['userId']
              })
          .toList(),
    );
  }

  factory PayOrder.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data()! as Map<String, dynamic>; // Assuming data exists
    print(json);
    return PayOrder(
      id: snapshot.id,
      orders: (json['orders'] as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      totalQuantity: (json['totalQuantity'] as num).toDouble(),
      partnerId: json['partnerId'] as String,
      billingTime: (json['billingTime'] as Timestamp).toDate(),
      paymentStatus: json['paymentStatus'],
      userNickName: json['userNickName'],
      tableNo: json['tableNo'] as String,
      roundtable: json['roundtable'] as String,
      userId: json['userId'] as String,
      paymentMethod: json['paymentMethod'] as String,
      paymentsBy: (json['paymentsBy'] as List<dynamic>? ?? [])
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billingTime': billingTime,
      'totalPrice': totalPrice,
      'totalQuantity': totalQuantity,
      'paymentStatus': paymentStatus,
      'orders': orders
          .map((order) => {
                'delivered': order['delivered'],
                'name': order['name'],
                'price': order['price'],
                'item': order['item'],
                'unit': order['unit'],
                'type': order['type'],
                'quantity': order['quantity'],
              })
          .toList(),
      'userNickName': userNickName,
      'partnerId': partnerId,
      'tableNo': tableNo,
      'roundtable': roundtable,
      'userId': userId,
      'paymentMethod': paymentMethod,
      'paymentsBy': paymentsBy
          .map((paid) => {
                'amountPaid': (paid['amountPaid'] as num).toDouble(),
                'paymentTime': paid['paymentTime'],
                'userId': paid['userId'],
              })
          .toList(),
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
