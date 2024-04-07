import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReserveTableHistory {
  String id = "";
  String userId;
  String selectedTableLabel;
  int selectedTablePrice;
  DateTime formattedSelectedDay;
  String nicknameUser;
  bool checkIn;

  ReserveTableHistory({
    this.id = "",
    required this.userId,
    required this.selectedTableLabel,
    required this.selectedTablePrice,
    required this.formattedSelectedDay,
    required this.nicknameUser,
    required this.checkIn,
  });

  factory ReserveTableHistory.fromJson(Map<String, dynamic> json) {
    return ReserveTableHistory(
      userId: json['userId'],
      selectedTableLabel: json['selectedTableLabel'],
      selectedTablePrice: json['selectedTablePrice'],
      formattedSelectedDay:
          (json['formattedSelectedDay'] as Timestamp).toDate(), // Corrected
      nicknameUser: json['nicknameUser'],
      checkIn: json['checkIn'],
    );
  }

  factory ReserveTableHistory.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data() as Map<String, dynamic>;
    return ReserveTableHistory(
      id: snapshot.id, // Correctly assign the document ID
      userId: json['userId'],
      selectedTableLabel: json['selectedTableLabel'],
      selectedTablePrice: json['selectedTablePrice'],
      formattedSelectedDay:
          (json['formattedSelectedDay'] as Timestamp).toDate(), // Corrected
      nicknameUser: json['nicknameUser'],
      checkIn: json['checkIn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'selectedTableLabel': selectedTableLabel,
      'selectedTablePrice': selectedTablePrice,
      'formattedSelectedDay': formattedSelectedDay,
      'nicknameUser': nicknameUser,
    };
  }
}

class AllReserveTableHistory {
  final List<ReserveTableHistory> reservetables;

  AllReserveTableHistory(this.reservetables);

  factory AllReserveTableHistory.fromJson(List<dynamic> json) {
    List<ReserveTableHistory> reservetables =
        json.map((item) => ReserveTableHistory.fromJson(item)).toList();
    return AllReserveTableHistory(reservetables);
  }

  factory AllReserveTableHistory.fromSnapshot(QuerySnapshot qs) {
    List<ReserveTableHistory> reservetables =
        qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> dataWithId = ds.data() as Map<String, dynamic>;
      dataWithId['id'] = ds.id;
      return ReserveTableHistory.fromJson(dataWithId);
    }).toList();
    return AllReserveTableHistory(reservetables);
  }

  Map<String, dynamic> toJson() {
    return {
      'reservetables':
          reservetables.map((reservetable) => reservetable.toJson()).toList(),
    };
  }
}

class ReserveTable {
  String id = "";
  String selectedTableLabel;
  int? selectedTablePrice;
  DateTime formattedSelectedDay;
  String userId;
  String nicknameUser;
  bool checkIn;

  ReserveTable({
    required this.selectedTableLabel,
    required this.selectedTablePrice,
    required this.formattedSelectedDay,
    required this.userId,
    required this.nicknameUser,
    required this.checkIn,
  });

  Map<String, dynamic> toMap() {
    return {
      'selectedTableLabel': selectedTableLabel,
      'selectedTablePrice': selectedTablePrice,
      'formattedSelectedDay': formattedSelectedDay,
      'userId': userId,
      'nicknameUser': nicknameUser,
      'checkIn': checkIn,
    };
  }
}

class ReserveTableProvider extends ChangeNotifier {
  List<ReserveTableHistory> _allReserveTable = [];

  List<ReserveTableHistory> get allReserveTable => _allReserveTable;

  void setReserveTable(List<ReserveTableHistory> bookingtable) {
    _allReserveTable = bookingtable;
    notifyListeners();
  }

  void setReservationsForUser(String userId) {
    var filteredList =
        _allReserveTable.where((ticket) => ticket.userId == userId).toList();
    _allReserveTable = filteredList;
    notifyListeners();
  }

  void addReserveTable(ReserveTableHistory bookingTable) {
    _allReserveTable.add(bookingTable);
    notifyListeners();
  }

  void clearbookingtable() {
    allReserveTable.clear();
    notifyListeners();
  }
}
