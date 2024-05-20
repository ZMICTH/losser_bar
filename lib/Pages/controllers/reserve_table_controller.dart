import 'dart:async';

import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:losser_bar/Pages/services/reserve_table_service.dart';

class ReserveTableHistoryController {
  List<ReserveTableHistory> ReserveTableHistories = List.empty();
  List<TableCatalog> TableCatalogs = List.empty();
  final ReserveTableHistoryService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  ReserveTableHistoryController(this.service);

  Future<List<TableCatalog>> fetchTableCatalog() async {
    print("fetchTableCatalog was: ${TableCatalogs}");
    onSyncController.add(true);
    TableCatalogs = await service.getAllTableCatalog();
    onSyncController.add(false);
    return TableCatalogs;
  }

  Future<List<ReserveTableHistory>> fetchReserveTableHistory() async {
    print("fetchReserveTableHistory was: ${ReserveTableHistories}");
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
