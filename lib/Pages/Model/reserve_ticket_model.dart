import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';

class TicketConcertModel {
  String id = "";
  late String eventName;
  late String imageEvent;
  late int numberOfTickets;
  late DateTime eventDate;
  late DateTime openingSaleDate;
  late DateTime endingSaleDate;
  double ticketPrice;

  TicketConcertModel(
    this.eventName,
    this.imageEvent,
    this.numberOfTickets,
    this.eventDate,
    this.openingSaleDate,
    this.endingSaleDate,
    this.ticketPrice,
  );

  factory TicketConcertModel.fromJson(Map<String, dynamic> json) {
    print(json);
    return TicketConcertModel(
      json['eventName'] as String,
      json['imageEvent'] as String,
      json['numberOfTickets'] as int,
      (json['eventDate'] as Timestamp).toDate(),
      (json['openingSaleDate'] as Timestamp).toDate(),
      (json['endingSaleDate'] as Timestamp).toDate(),
      (json['ticketPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': id,
      'eventName': eventName,
      'imageEvent': imageEvent,
      'numberOfTickets': numberOfTickets,
      'eventDate': eventDate,
      'openingSaleDate': openingSaleDate,
      'endingSaleDate': endingSaleDate,
      'ticketPrice': ticketPrice,
    };
  }
}

class AllTicketConcertModel {
  final List<TicketConcertModel> allTicketConcertModel;

  AllTicketConcertModel(this.allTicketConcertModel);

  factory AllTicketConcertModel.fromJson(List<dynamic> json) {
    print(json);
    List<TicketConcertModel> allTicketConcertModel;

    allTicketConcertModel =
        json.map((item) => TicketConcertModel.fromJson(item)).toList();

    return AllTicketConcertModel(allTicketConcertModel);
  }

  factory AllTicketConcertModel.fromSnapshot(QuerySnapshot qs) {
    List<TicketConcertModel> allTicketConcertModel;

    allTicketConcertModel = qs.docs.map((DocumentSnapshot ds) {
      TicketConcertModel ticketconcertmodel =
          TicketConcertModel.fromJson(ds.data() as Map<String, dynamic>);
      ticketconcertmodel.id = ds.id;
      return ticketconcertmodel;
    }).toList();
    return AllTicketConcertModel(allTicketConcertModel);
  }
}

class BookingTicket {
  String reserveticketId = "";
  String userId;
  String ticketId;
  String nicknameUser;
  String eventName;
  String selectedTableLabel;
  DateTime eventDate;
  double totalPayment;
  int ticketQuantity;
  bool payable;
  bool checkIn;
  DateTime paymentTime;
  int? sharedCount;
  List<String>? sharedWith;
  String partnerId;

  BookingTicket({
    required this.userId,
    required this.ticketId,
    required this.nicknameUser,
    required this.eventName,
    required this.selectedTableLabel,
    required this.eventDate,
    required this.totalPayment,
    required this.ticketQuantity,
    required this.payable,
    required this.checkIn,
    required this.partnerId,
    required this.paymentTime,
    required this.sharedCount,
    required this.sharedWith,
  });

  factory BookingTicket.fromJson(Map<String, dynamic> json) {
    return BookingTicket(
      userId: json['userId'] as String,
      ticketId: json['ticketId'] as String,
      nicknameUser: json['nicknameUser'] as String,
      eventName: json['eventName'] as String,
      selectedTableLabel: json['selectedTableLabel'] as String,
      eventDate: (json['eventDate'] as Timestamp).toDate(),
      totalPayment:
          (json['totalPayment'] as num).toDouble(), // Ensures double type
      ticketQuantity: json['ticketQuantity'] as int,
      payable: json['payable'] as bool,
      checkIn: json['checkIn'] as bool,
      partnerId: json['partnerId'] as String,
      paymentTime: (json['eventDate'] as Timestamp).toDate(),
      sharedCount: json['sharedCount'] as int? ?? 0,
      sharedWith: json['sharedWith'] != null
          ? List<String>.from(json['sharedWith'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'ticketId': ticketId,
      'nicknameUser': nicknameUser,
      'eventName': eventName,
      'selectedTableLabel': selectedTableLabel,
      'eventDate': Timestamp.fromDate(eventDate),
      'totalPayment': totalPayment,
      'ticketQuantity': ticketQuantity,
      'payable': payable,
      'checkIn': checkIn,
      'partnerId': partnerId,
      'paymentTime': paymentTime,
      'sharedCount': sharedCount,
      'sharedWith': sharedWith,
    };
  }
}

class AllReservationTicketModel {
  final List<BookingTicket> allReservationTicketModel;

  AllReservationTicketModel(this.allReservationTicketModel);

  factory AllReservationTicketModel.fromJson(List<dynamic> json) {
    List<BookingTicket> allReservationTicketModel;

    allReservationTicketModel =
        json.map((item) => BookingTicket.fromJson(item)).toList();

    return AllReservationTicketModel(allReservationTicketModel);
  }

  factory AllReservationTicketModel.fromSnapshot(QuerySnapshot qs) {
    List<BookingTicket> allReservationTicketModel;

    allReservationTicketModel = qs.docs.map((DocumentSnapshot ds) {
      BookingTicket bookingticketmodel =
          BookingTicket.fromJson(ds.data() as Map<String, dynamic>);
      bookingticketmodel.reserveticketId = ds.id;
      return bookingticketmodel;
    }).toList();
    return AllReservationTicketModel(allReservationTicketModel);
  }
}

class TicketcatalogProvider extends ChangeNotifier {
  List<TicketConcertModel> _allTicketConcert = [];

  List<TicketConcertModel> get allTicketConcert => _allTicketConcert;

  void setReserveTicket(List<TicketConcertModel> tickets) {
    _allTicketConcert = tickets;
    notifyListeners();
  }

  void addReserveTicket(TicketConcertModel bookingticket) {
    _allTicketConcert.add(bookingticket);
    notifyListeners();
  }

  void clearbookingticket() {
    allTicketConcert.clear();
    notifyListeners();
  }
}

class ReservationTicketProvider extends ChangeNotifier {
  List<BookingTicket> _allReservationTicket = [];
  List<TableCatalog> _tables = [];
  DateTime? _eventDate;
  int _quantityTable = 0;
  String? _selectedTableLabel;
  int? _selectedTablePrice;
  double _totalPrice = 0.0;
  int _ticketQuantity = 1;
  int _selectedTableSeats = 0;
  TableCatalog? _selectedTable;
  String? _selectedTableId;

  List<BookingTicket> get allReservationTicket => _allReservationTicket;
  List<TableCatalog> get tables => _tables;
  DateTime? get eventDate => _eventDate;
  int get quantityTable => _quantityTable;
  String? get selectedTableLabel => _selectedTableLabel;
  int? get selectedTablePrice => _selectedTablePrice;
  double get totalPrice => _totalPrice;
  int get ticketQuantity => _ticketQuantity;
  int get selectedTableSeats => _selectedTableSeats;
  TableCatalog? get selectedTable => _selectedTable;
  String? get selectedTableId => _selectedTableId;

  void setAllReservationTicket(List<BookingTicket> reservationTickets) {
    _allReservationTicket = reservationTickets;
    notifyListeners();
  }

  void setReservationsForUser(String userId) {
    var filteredList = _allReservationTicket
        .where((ticket) => ticket.userId == userId)
        .toList();
    _allReservationTicket = filteredList;
    notifyListeners();
  }

  set eventDate(DateTime? newDate) {
    if (_eventDate != newDate) {
      _eventDate = newDate;
      filterTablesForDate(newDate);
      notifyListeners();
    }
  }

  set quantityTable(int quantity) {
    _quantityTable = quantity;
    notifyListeners();
  }

  void setTables(List<TableCatalog> newTables) {
    _tables = newTables;
    filterTablesForDate(_eventDate);
    notifyListeners();
  }

  void filterTablesForDate(DateTime? date) {
    if (date != null) {
      _tables = _tables
          .where((table) =>
              table.onTheDay.year == date.year &&
              table.onTheDay.month == date.month &&
              table.onTheDay.day == date.day)
          .toList();
    }
  }

  void setSelectedTable(TableCatalog? table) {
    _selectedTable = table;
    if (table != null) {
      _selectedTableId = table.id;
      print(_selectedTable);
      print(_selectedTableId);
    } else {
      _selectedTableId = null;
    }
    print(_selectedTable);
    notifyListeners();
  }

  void setSelectedTableLabel(String? label, int? price, int seats) {
    _selectedTableLabel = label;
    _selectedTablePrice = price;
    _selectedTableSeats = seats;
    print(_selectedTableLabel);
    print(_selectedTablePrice);
    print(_selectedTableSeats);
    notifyListeners();
  }

  void incrementTicketQuantity() {
    if (_ticketQuantity < _selectedTableSeats) {
      _ticketQuantity++;
      notifyListeners();
    }
  }

  void decrementTicketQuantity() {
    if (_ticketQuantity > 1) {
      _ticketQuantity--;
      notifyListeners();
    }
  }

  set totalPrice(double price) {
    _totalPrice = price;
    print(_totalPrice);
    notifyListeners();
  }

  void clearBookingTable() {
    _allReservationTicket.clear();
    notifyListeners();
  }

  bool isEventDate(DateTime date) {
    return _allReservationTicket
        .any((ticket) => ticket.eventDate.isAtSameMomentAs(date));
  }
}
