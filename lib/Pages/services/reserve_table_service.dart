import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';

abstract class ReserveTableHistoryService {
  Future<List<ReserveTableHistory>> getAllReserveTableHistory();
  Future<List<TableCatalog>> getAllTableCatalog();

  addReserveTable(ReserveTable BookingReserveTable) {}
}

class ReserveTableFirebaseService implements ReserveTableHistoryService {
  @override
  Future<List<ReserveTableHistory>> getAllReserveTableHistory() async {
    print("getAllReserveTableHistory is called");
    QuerySnapshot qs =
        await FirebaseFirestore.instance.collection('reservation_table').get();
    print("ReserveTable count: ${qs.docs.length}");
    AllReserveTableHistory ReserveTableHistories =
        AllReserveTableHistory.fromSnapshot(qs);
    print(ReserveTableHistories.reservetables);
    return ReserveTableHistories.reservetables;
  }

  @override
  addReserveTable(ReserveTable BookingReserveTable) async {
    try {
      await FirebaseFirestore.instance.collection('reservation_table').add({
        'selectedTableId': BookingReserveTable.selectedTableId,
        'quantityTable': BookingReserveTable.quantityTable,
        'selectedTableLabel': BookingReserveTable.selectedTableLabel,
        'totalPrices': BookingReserveTable.totalPrices,
        'formattedSelectedDay': BookingReserveTable.formattedSelectedDay,
        'userId': BookingReserveTable.userId,
        'nicknameUser': BookingReserveTable.nicknameUser,
        'checkIn': BookingReserveTable.checkIn,
        'selectedSeats': BookingReserveTable.selectedSeats,
        'partnerId': BookingReserveTable.partnerId,
        'payable': BookingReserveTable.payable,
        'userPhone': BookingReserveTable.userPhone,
        'paymentTime': BookingReserveTable.paymentTime,
      });
      print("Reservation uploaded successfully");
    } catch (e) {
      print('Error adding Reservation: $e');
    }
  }

  Future<List<TableCatalog>> getAllTableCatalog() async {
    print("getAllTableCatalog is called");
    QuerySnapshot qs =
        await FirebaseFirestore.instance.collection('table_catalog').get();
    print("TableCatalog count: ${qs.docs.length}");
    AllTableCatalog TableCatalogs = AllTableCatalog.fromSnapshot(qs);
    print(TableCatalogs.tablecatalogs);
    return TableCatalogs.tablecatalogs;
  }
}
