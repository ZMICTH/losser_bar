import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:provider/provider.dart';

class BillOrder {
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

  BillOrder({
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
  });

  factory BillOrder.fromJson(Map<String, dynamic> json) {
    return BillOrder(
      id: json['id'] ?? "",
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
    );
  }

  factory BillOrder.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data() as Map<String, dynamic>;
    return BillOrder(
      id: snapshot.id,
      orders: (json['orders'] as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
      totalPrice: json['totalPrice'],
      totalQuantity: json['totalQuantity'],
      partnerId: json['partnerId'] as String,
      billingTime: (json['billingTime'] as Timestamp).toDate(),
      paymentStatus: json['paymentStatus'],
      userNickName: json['userNickName'],
      tableNo: json['tableNo'] as String,
      roundtable: json['roundtable'] as String,
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

class OrderHistories {
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

  OrderHistories({
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
  });

  factory OrderHistories.fromJson(Map<String, dynamic> json) {
    print(json);
    return OrderHistories(
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
    );
  }

  factory OrderHistories.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data() as Map<String, dynamic>;
    return OrderHistories(
      id: snapshot.id,
      orders: (json['orders'] as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
      totalPrice: json['totalPrice'],
      totalQuantity: json['totalQuantity'],
      partnerId: json['partnerId'] as String,
      billingTime: (json['billingTime'] as Timestamp).toDate(),
      paymentStatus: json['paymentStatus'],
      userNickName: json['userNickName'],
      tableNo: json['tableNo'] as String,
      roundtable: json['roundtable'] as String,
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
    };
  }
}

class AllOrderHistory {
  final List<OrderHistories> orderHistories;

  AllOrderHistory(this.orderHistories);

  factory AllOrderHistory.fromJson(List<dynamic> json) {
    List<OrderHistories> orderHistories =
        json.map((item) => OrderHistories.fromJson(item)).toList();
    return AllOrderHistory(orderHistories);
  }

  factory AllOrderHistory.fromSnapshot(QuerySnapshot qs) {
    List<OrderHistories> orderHistories = qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> dataWithId = ds.data() as Map<String, dynamic>;
      dataWithId['id'] = ds.id;
      return OrderHistories.fromJson(dataWithId);
    }).toList();
    return AllOrderHistory(orderHistories);
  }

  Map<String, dynamic> toJson() {
    return {
      'orderHistories':
          orderHistories.map((reservetable) => reservetable.toJson()).toList(),
    };
  }
}

class BillOrderProvider extends ChangeNotifier {
  List<BillOrder> _allBillOrder = [];
  List<BillOrder> get allBillOrder => _allBillOrder;

  List<OrderHistories> _allOrderHistory = [];
  List<OrderHistories> get allOrderHistory => _allOrderHistory;

  // Set all bill orders
  void setBillOrder(List<OrderHistories> billingOrder) {
    _allOrderHistory = billingOrder;
    notifyListeners();
  }

  // Set bill orders for a specific tableNo and roundtable
  void setBillOrderForTableAndRoundtable(
      String tableNo, String roundtable, BuildContext context) {
    var reserveTableProvider =
        Provider.of<ReserveTableProvider>(context, listen: false);

    print('Before filtering: ${_allOrderHistory.length} orders');

    var filteredList = _allOrderHistory.where((history) {
      bool match = reserveTableProvider.allReserveTable.any((reserve) =>
          reserve.tableNo == tableNo &&
          reserve.roundtable == roundtable &&
          reserve.partnerId == history.partnerId &&
          reserve.tableNo == history.tableNo &&
          reserve.roundtable == history.roundtable);
      if (match) {
        print(
            'Matched order: ${history.id} with tableNo: ${history.tableNo} and roundtable: ${history.roundtable}');
      }
      return match;
    }).toList();

    print('After filtering: ${filteredList.length} orders');

    _allOrderHistory = filteredList;
    notifyListeners();
  }

  void clearBillingOrder() {
    _allOrderHistory.clear();
    notifyListeners();
  }
}
