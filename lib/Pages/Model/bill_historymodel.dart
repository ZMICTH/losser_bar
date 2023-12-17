class BillHistory {
  String id = "";
  String tableNo;
  List<Map<String, dynamic>> orders;
  // Each order is a Map with details
  double totalPrice;
  String userId;
  DateTime billingtime;

  BillHistory({
    required this.tableNo,
    required this.orders,
    required this.totalPrice,
    required this.userId,
    required this.billingtime,
  });

  Map<String, dynamic> toMap() {
    return {
      'tableNo': tableNo,
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
      'userId': userId,
      'billingTime': billingtime,
    };
  }
}
