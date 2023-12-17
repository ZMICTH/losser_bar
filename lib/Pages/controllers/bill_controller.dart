import 'dart:async';

import 'package:losser_bar/Pages/Model/bill_historymodel.dart';
import 'package:losser_bar/Pages/services/bill_historyservice.dart';

class BillHistoryController {
  Map<String, dynamic> currentbill = {};
  final BillHistoryService service;

  StreamController<bool> onSyncController = StreamController<bool>();
  Stream<bool> get onSync => onSyncController.stream;
  BillHistoryController(this.service);

  Future<void> addBillHistory(BillHistory billHistory) async {
    onSyncController.add(true);
    await service.addBillHistory(billHistory);
    onSyncController.add(false);
  }
}
