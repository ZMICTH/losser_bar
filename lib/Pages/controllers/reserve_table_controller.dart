import 'dart:async';

import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:losser_bar/Pages/services/reserve_table_service.dart';

class ReserveTableHistoryController {
  List<ReserveTableHistory> ReserveTableHistories = List.empty();
  final ReserveTableHistoryService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  ReserveTableHistoryController(this.service);

  Future<List<ReserveTableHistory>> fetchReserveTableHistory() async {
    print("fetchMateCatalog was: ${ReserveTableHistories}");
    onSyncController.add(true);
    ReserveTableHistories = await service.getAllReserveTableHistory();
    onSyncController.add(false);
    return ReserveTableHistories;
  }

  Future<void> addReserveTable(ReserveTable BookingReserveTable) async {
    onSyncController.add(true);
    await service.addReserveTable(BookingReserveTable);
    onSyncController.add(false);
  }
}
