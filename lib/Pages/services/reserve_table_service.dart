import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';

abstract class ReserveTableHistoryService {
  Future<List<ReserveTableHistory>> getAllReserveTableHistory();

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
        'selectedTableLabel': BookingReserveTable.selectedTableLabel,
        'selectedTablePrice': BookingReserveTable.selectedTablePrice,
        'formattedSelectedDay': BookingReserveTable.formattedSelectedDay,
        'userId': BookingReserveTable.userId,
        'nicknameUser': BookingReserveTable.nicknameUser,
        'checkIn': BookingReserveTable.checkIn,
      });
      print("Reservation uploaded successfully");
    } catch (e) {
      print('Error adding Reservation: $e');
    }
  }
}
