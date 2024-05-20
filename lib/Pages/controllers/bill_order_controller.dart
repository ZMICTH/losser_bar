import 'dart:async';

import 'package:losser_bar/Pages/Model/bill_order_model.dart';
import 'package:losser_bar/Pages/services/bill_historyservice.dart';

class BillHistoryController {
  // List<BillOrder> BillOrders = List.empty();
  final BillHistoryService service;

  StreamController<bool> onSyncController = StreamController<bool>();
  Stream<bool> get onSync => onSyncController.stream;
  BillHistoryController(this.service);

  Future<void> addBillHistory(BillOrder billOrder) async {
    onSyncController.add(true);
    await service.addBillHistory(billOrder);
    onSyncController.add(false);
  }

  Future<List<BillOrder>> fetchBillOrder() async {
    onSyncController.add(true);
    try {
      List<BillOrder> billOrders = await service.getAllBillOrders();
      onSyncController.add(false);
      return billOrders;
    } catch (e) {
      onSyncController.add(false);
      print("Failed to fetch bill orders: $e");
      return []; // Return an empty list on error or handle appropriately
    }
  }
}
