import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PayOrder {
  late String id = "";
  late String tableNo;
  late List<Map<String, dynamic>> orders;
  late double totalPrice;
  late String userId;
  late DateTime billingtime;

  PayOrder(
    this.tableNo,
    this.orders,
    this.totalPrice,
    this.userId,
    this.billingtime,
  );

  factory PayOrder.fromJson(Map<String, dynamic> json) {
    var ordersJson = json['orders'] as List? ?? [];
    List<Map<String, dynamic>> orders =
        ordersJson.map((order) => order as Map<String, dynamic>).toList();

    return PayOrder(
      json['tableNo'] as String? ?? 'default value',
      orders,
      (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      json['userId'] as String? ?? 'default value',
      json['billingtime'] as DateTime? ?? DateTime.now(),
    );
  }

  factory PayOrder.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> json = snapshot.data() as Map<String, dynamic>? ?? {};

    // Handling 'orders' field
    var ordersJson = json['orders'] as List? ?? [];
    List<Map<String, dynamic>> orders =
        ordersJson.map((order) => order as Map<String, dynamic>).toList();

    // Safe casting with default values for nullable fields
    String tableNo = json['tableNo'] as String? ?? 'default';
    double totalPrice = (json['totalPrice'] as num?)?.toDouble() ?? 0.0;
    String userId = json['userId'] as String? ?? 'default';

    // Safe parsing for 'billingtime'
    String billingTimeString = json['billingtime'] as String? ?? '';
    DateTime billingtime =
        DateTime.tryParse(billingTimeString) ?? DateTime.now();

    return PayOrder(
      tableNo,
      orders,
      totalPrice,
      userId,
      billingtime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableNo': tableNo,
      'orders': orders
          .map((order) => {
                'id': order['id'],
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
      'userId': userId,
      'billingTime': billingtime,
    };
  }
}

class AllOrderHistory {
  final List<PayOrder> ordershistory;

  AllOrderHistory(this.ordershistory);

  factory AllOrderHistory.fromJson(List<dynamic> json) {
    List<PayOrder> ordershistory =
        json.map((item) => PayOrder.fromJson(item)).toList();
    return AllOrderHistory(ordershistory);
  }

  factory AllOrderHistory.fromSnapshot(QuerySnapshot qs) {
    List<PayOrder> ordershistory;

    ordershistory = qs.docs.map((DocumentSnapshot ds) {
      PayOrder orderhistory =
          PayOrder.fromJson(ds.data() as Map<String, dynamic>);
      orderhistory.id = ds.id;
      return orderhistory;
    }).toList();

    return AllOrderHistory(ordershistory);
  }
  Map<String, dynamic> toJson() {
    return {
      'ordershistory':
          ordershistory.map((orderhisory) => orderhisory.toJson()).toList(),
    };
  }
}

class OrderHistoryProvider extends ChangeNotifier {
  List<PayOrder>? _allOrderHistory = [];

  List<PayOrder>? get allOrderHistory => _allOrderHistory;

  void setOrderHistory(List<PayOrder>? ordershistory) {
    _allOrderHistory = ordershistory;
    notifyListeners();
  }

  void setOrderHistories(List<PayOrder> newOrderHistoriesData) {
    _allOrderHistory = newOrderHistoriesData;
    notifyListeners();
  }

  // void addCar(Car car) {
  //   print("addCar @ provider is called");
  //   _allCars!.add(car);
  //   notifyListeners();
  // }

  // void updateCar(Car updatedCar) {
  //   print("updateCar @ provider is called");
  //   int index = _allCars!.indexWhere((car) => car.id == updatedCar.id);
  //   if (index != -1) {
  //     _allCars![index] = updatedCar;
  //     notifyListeners();
  //   }
  // }
}
