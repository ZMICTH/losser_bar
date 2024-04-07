import 'dart:async';

import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/payorder_model.dart';
import 'package:losser_bar/Pages/services/payorder_services.dart';

class OrderHistoryController {
  List<PayOrder> allPayOrderModel = List.empty();
  final OrderHistoryService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  OrderHistoryController(this.service);

  Future<List<PayOrder>> fetchOrdersHistory() async {
    print("fetchOrdersHistory was: ${allPayOrderModel}");
    onSyncController.add(true);
    allPayOrderModel = await service.fetchOrdersHistory();
    onSyncController.add(false);
    return allPayOrderModel;
  }
}
