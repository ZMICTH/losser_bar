import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TableCatalog {
  String id = "";
  DateTime onTheDay;
  bool closeDate;
  List<Map<String, dynamic>> tableLables;

  TableCatalog({
    this.id = "",
    required this.onTheDay,
    required this.closeDate,
    required this.tableLables,
  });

  factory TableCatalog.fromJson(Map<String, dynamic> json) {
    print(json);
    return TableCatalog(
      id: json['id'] as String,
      onTheDay: (json['onTheDay'] as Timestamp).toDate(),
      closeDate: json['closeDate'] as bool,
      tableLables: (json['tableLables'] as List<dynamic>? ?? [])
          .map<Map<String, dynamic>>((tableLable) {
        return Map<String, dynamic>.from(tableLable as Map);
      }).toList(),
    );
  }

  factory TableCatalog.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data() as Map<String, dynamic>;
    return TableCatalog(
      id: snapshot.id, // Correctly assign the document ID
      onTheDay: (json['onTheDay'] as Timestamp).toDate(),
      closeDate: json['closeDate'] as bool,
      tableLables: (json['tableLables'] as List<dynamic>? ?? [])
          .map<Map<String, dynamic>>((tableLable) {
        return Map<String, dynamic>.from(tableLable as Map);
      }).toList(), // Ensure double
    );
  }

  // Method to convert TableCatalog instance to a map.
  Map<String, dynamic> toJson() {
    return {
      'onTheDay': onTheDay,
      'closeDate': closeDate,
      'tableLables': tableLables
          .map((table) => {
                'label': table['label'],
                'numberofchairs': table['numberofchairs'],
                'seats': table['seats'],
                'tablePrices': table['tablePrices'],
                'totaloftable': table['totaloftable'],
              })
          .toList(),
    };
  }
}

class AllTableCatalog {
  final List<TableCatalog> tablecatalogs;

  AllTableCatalog(this.tablecatalogs);

  factory AllTableCatalog.fromJson(List<dynamic> json) {
    List<TableCatalog> tablecatalogs =
        json.map((item) => TableCatalog.fromJson(item)).toList();
    return AllTableCatalog(tablecatalogs);
  }

  factory AllTableCatalog.fromSnapshot(QuerySnapshot qs) {
    List<TableCatalog> tablecatalogs = qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> dataWithId = ds.data() as Map<String, dynamic>;
      dataWithId['id'] = ds.id;
      return TableCatalog.fromJson(dataWithId);
    }).toList();
    return AllTableCatalog(tablecatalogs);
  }

  Map<String, dynamic> toJson() {
    return {
      'tablecatalogs':
          tablecatalogs.map((tablecatalogs) => tablecatalogs.toJson()).toList(),
    };
  }
}

class ReserveTableHistory {
  String id = "";
  String selectedTableId;
  int quantityTable;
  String selectedTableLabel;
  double totalPrices;
  DateTime formattedSelectedDay;
  String userId;
  String nicknameUser;
  bool checkIn;
  int selectedSeats;
  String userPhone;
  bool payable;
  DateTime paymentTime;
  int sharedCount;
  List<String>? sharedWith;

  ReserveTableHistory({
    this.id = "",
    required this.selectedTableId,
    required this.quantityTable,
    required this.selectedTableLabel,
    required this.totalPrices,
    required this.formattedSelectedDay,
    required this.userId,
    required this.nicknameUser,
    required this.checkIn,
    required this.selectedSeats,
    required this.userPhone,
    required this.payable,
    required this.paymentTime,
    required this.sharedCount,
    required this.sharedWith,
  });

  factory ReserveTableHistory.fromJson(Map<String, dynamic> json) {
    print(json);
    return ReserveTableHistory(
      id: json['id'] as String,
      userId: json['userId'],
      selectedTableId: json['selectedTableId'],
      quantityTable: json['quantityTable'] as int,
      selectedTableLabel: json['selectedTableLabel'],
      totalPrices: (json['totalPrices'] as num).toDouble(),
      formattedSelectedDay:
          (json['formattedSelectedDay'] as Timestamp).toDate(), // Corrected
      nicknameUser: json['nicknameUser'],
      selectedSeats: json['selectedSeats'] as int,
      userPhone: json['userPhone'],
      checkIn: json['checkIn'],
      payable: json['payable'],
      paymentTime: (json['paymentTime'] as Timestamp).toDate(),
      sharedCount: json['sharedCount'] as int? ?? 0,
      sharedWith: json['sharedWith'] != null
          ? List<String>.from(json['sharedWith'] as List)
          : null,
    );
  }

  factory ReserveTableHistory.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data() as Map<String, dynamic>;
    return ReserveTableHistory(
      id: snapshot.id, // Correctly assign the document ID
      userId: json['userId'],
      selectedTableId: json['selectedTableId'],
      quantityTable: json['quantityTable'] as int,
      selectedTableLabel: json['selectedTableLabel'],
      totalPrices: (json['totalPrices'] as num).toDouble(),
      formattedSelectedDay:
          (json['formattedSelectedDay'] as Timestamp).toDate(), // Corrected
      nicknameUser: json['nicknameUser'],
      selectedSeats: json['selectedSeats'] as int,
      userPhone: json['userPhone'],
      checkIn: json['checkIn'],
      payable: json['payable'],
      paymentTime: (json['paymentTime'] as Timestamp).toDate(),
      sharedCount: json['sharedCount'] as int? ?? 0,
      sharedWith: json['sharedWith'] != null
          ? List<String>.from(json['sharedWith'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedTableId': selectedTableId,
      'quantityTable': quantityTable,
      'selectedTableLabel': selectedTableLabel,
      'totalPrices': totalPrices,
      'formattedSelectedDay': formattedSelectedDay,
      'userId': userId,
      'nicknameUser': nicknameUser,
      'checkIn': checkIn,
      'selectedSeats': selectedSeats,
      'userPhone': userPhone,
      'payable': payable,
      'paymentTime': paymentTime,
      'sharedCount': sharedCount,
      'sharedWith': sharedWith,
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
  String selectedTableId;
  int quantityTable;
  String selectedTableLabel;
  double totalPrices;
  DateTime formattedSelectedDay;
  String userId;
  String nicknameUser;
  bool checkIn;
  int selectedSeats;
  String userPhone;
  bool payable;
  DateTime paymentTime;

  ReserveTable({
    required this.selectedTableId,
    required this.quantityTable,
    required this.selectedTableLabel,
    required this.totalPrices,
    required this.formattedSelectedDay,
    required this.userId,
    required this.nicknameUser,
    required this.checkIn,
    required this.selectedSeats,
    required this.userPhone,
    required this.payable,
    required this.paymentTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'selectedTableId': selectedTableId,
      'quantityTable': quantityTable,
      'selectedTableLabel': selectedTableLabel,
      'totalPrices': totalPrices,
      'formattedSelectedDay': formattedSelectedDay,
      'userId': userId,
      'nicknameUser': nicknameUser,
      'checkIn': checkIn,
      'selectedSeats': selectedSeats,
      'userPhone': userPhone,
      'payable': payable,
      'paymentTime': paymentTime,
    };
  }
}

class ReserveTableProvider extends ChangeNotifier {
  List<TableCatalog> _tables = [];
  List<DateTime> _inactiveDates = [];
  DateTime? _selectedDate;
  int _selectedTableSeat = 0;
  int _seatQuantity = 1;
  int _maxSeats = 1; // Default value, will be updated dynamically
  TableCatalog? _selectedTable;
  String? _selectedLabel;
  String? _selectedTableId;
  int _quantityTable = 0;

  List<DateTime> get inactiveDates => _inactiveDates;
  int? get selectedTableSeat => _selectedTableSeat;
  TableCatalog? get selectedTable => _selectedTable;
  String? get selectedLabel => _selectedLabel;
  int get seatQuantity => _seatQuantity;
  int get maxSeats => _maxSeats;
  int get quantityTable => _quantityTable;

  List<ReserveTableHistory> _allReserveTable = [];
  List<ReserveTableHistory> get allReserveTable => _allReserveTable;

  List<TableCatalog> get tables => _selectedDate == null
      ? []
      : _tables
          .where((table) =>
              table.onTheDay.year == _selectedDate!.year &&
              table.onTheDay.month == _selectedDate!.month &&
              table.onTheDay.day == _selectedDate!.day)
          .toList();

  DateTime? get selectedDate => _selectedDate;
  String? get selectedTableId => _selectedTableId;

  set selectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  set selectedTable(TableCatalog? table) {
    _selectedTable = table;
    if (table != null) {
      _selectedTableId = table.id;
      // Good for debugging
    } else {
      _selectedTableId = null; // Clear the selected ID if no table is selected
    }
    notifyListeners();
  }

  set selectedTableId(String? id) {
    _selectedTableId = id;
    notifyListeners();
  }

  void setTables(List<TableCatalog> tables) {
    _tables = tables;
    _updateInactiveDates();
    notifyListeners();
  }

  void _updateInactiveDates() {
    _inactiveDates = _tables
        .where((table) => table.closeDate)
        .map((table) => DateTime(
            table.onTheDay.year, table.onTheDay.month, table.onTheDay.day))
        .toList();
  }

  void setSelectedTableSeat(int seats) {
    _selectedTableSeat = seats;
    _maxSeats = seats;
    notifyListeners();
  }

  set quantityTable(int quantity) {
    _quantityTable = quantity;

    notifyListeners();
  }

  void incrementSeatQuantity() {
    if (_seatQuantity < _maxSeats) {
      _seatQuantity++;
      notifyListeners();
    }
  }

  void decrementSeatQuantity() {
    if (_seatQuantity > 1) {
      _seatQuantity--;
      notifyListeners();
    }
  }

  void clearBookingTable() {
    _allReserveTable.clear();
    notifyListeners();
  }

  //for Reservation History
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
