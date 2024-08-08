import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:losser_bar/Pages/provider/partner_model.dart';
import 'package:provider/provider.dart';

class TicketConcertModel {
  String id = "";
  late String eventName;
  late String imageEvent;
  late int numberOfTickets;
  late DateTime eventDate;
  late DateTime openingSaleDate;
  late DateTime endingSaleDate;
  late String partnerId;
  double ticketPrice;

  TicketConcertModel(
    this.eventName,
    this.imageEvent,
    this.numberOfTickets,
    this.eventDate,
    this.openingSaleDate,
    this.endingSaleDate,
    this.ticketPrice,
    this.partnerId,
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
      json['partnerId'] as String,
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
      'partnerId': partnerId,
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
  String id = "";
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
  List<String>? sharedWith;
  String partnerId;
  String userPhone;
  String? tableNo;
  String? roundtable;
  bool? checkOut;

  BookingTicket({
    this.id = "",
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
    required this.sharedWith,
    required this.userPhone,
    this.tableNo,
    this.roundtable,
    this.checkOut,
  });

  factory BookingTicket.fromJson(Map<String, dynamic> json) {
    print(json);
    return BookingTicket(
      id: json['id'] as String,
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

      sharedWith: json['sharedWith'] != null
          ? List<String>.from(json['sharedWith'] as List)
          : null,
      userPhone: json['userPhone'] as String,
      tableNo: json['tableNo'] as String? ?? "",
      roundtable: json['roundtable'] as String? ?? "",
      checkOut: json['checkOut'],
    );
  }
  factory BookingTicket.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data() as Map<String, dynamic>;
    return BookingTicket(
      id: snapshot.id, // Correctly assign the document ID
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

      sharedWith: json['sharedWith'] != null
          ? List<String>.from(json['sharedWith'] as List)
          : null,
      userPhone: json['userPhone'] as String,
      tableNo: json['tableNo'] as String? ?? "",
      roundtable: json['roundtable'] as String? ?? "",
      checkOut: json['checkOut'],
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
      'sharedWith': sharedWith,
      'userPhone': userPhone,
    };
  }
}

class AllReservationTicketModel {
  final List<BookingTicket> reservetickets;

  AllReservationTicketModel(this.reservetickets);

  factory AllReservationTicketModel.fromJson(List<dynamic> json) {
    List<BookingTicket> reservetickets =
        json.map((item) => BookingTicket.fromJson(item)).toList();

    return AllReservationTicketModel(reservetickets);
  }

  factory AllReservationTicketModel.fromSnapshot(QuerySnapshot qs) {
    List<BookingTicket> reservetickets = qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> dataWithId = ds.data() as Map<String, dynamic>;
      dataWithId['id'] = ds.id;
      return BookingTicket.fromJson(dataWithId);
    }).toList();
    return AllReservationTicketModel(reservetickets);
  }

  Map<String, dynamic> toJson() {
    return {
      'reservetickets': reservetickets
          .map((reserveticket) => reserveticket.toJson())
          .toList(),
    };
  }
}

class TicketcatalogProvider extends ChangeNotifier {
  List<TicketConcertModel> _allTicketConcert = [];

  List<TicketConcertModel> get allTicketConcert => _allTicketConcert;

  void setReserveTicket(List<TicketConcertModel> tickets, String? partnerId) {
    if (partnerId != null) {
      _allTicketConcert =
          tickets.where((ticket) => ticket.partnerId == partnerId).toList();
    } else {
      _allTicketConcert = tickets;
    }
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
  num? _selectedTablePrice; // Changed to num?
  double _totalPrice = 0.0;
  int _ticketQuantity = 1;
  int _selectedTableSeats = 0;
  TableCatalog? _selectedTable;
  String? _selectedTableId;
  int _totalSharedWithCount = 0;

  List<BookingTicket> get allReservationTicket => _allReservationTicket;
  List<TableCatalog> get tables => _tables;
  DateTime? get eventDate => _eventDate;
  int get quantityTable => _quantityTable;
  String? get selectedTableLabel => _selectedTableLabel;
  num? get selectedTablePrice => _selectedTablePrice; // Changed to num?
  double get totalPrice => _totalPrice;
  int get ticketQuantity => _ticketQuantity;
  int get selectedTableSeats => _selectedTableSeats;
  TableCatalog? get selectedTable => _selectedTable;
  String? get selectedTableId => _selectedTableId;
  int get totalSharedWithCount => _totalSharedWithCount;

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

  void setSelectedTableLabel(String? label, num? price, int seats) {
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
    _eventDate = null;
    _selectedTableId = "";
    _selectedTableLabel = "";
    _selectedTablePrice = 0;
    _ticketQuantity = 0;
    _totalPrice = 0;
    notifyListeners();
  }

  bool isEventDate(DateTime date) {
    return _allReservationTicket
        .any((ticket) => ticket.eventDate.isAtSameMomentAs(date));
  }

  // for use in cart
  void setTableNo(List<BookingTicket> reservationTickets) {
    _allReservationTicket = reservationTickets;
    _updateTotalSharedWithCount(); // Update shared count
    notifyListeners();
  }

  void setTableNoForUser(String userId) {
    var filteredList = _allReservationTicket
        .where((ticket) => ticket.userId == userId)
        .toList();
    _allReservationTicket = filteredList;
    _updateTotalSharedWithCount(); // Update shared count
    notifyListeners();
  }

  void filterCheckedInToday(BuildContext context) {
    DateTime now = DateTime.now();
    String? selectedPartnerId =
        Provider.of<SelectedPartnerProvider>(context, listen: false)
            .selectedPartnerId;
    String? currentUserId =
        Provider.of<MemberUserModel>(context, listen: false).memberUser?.id;

    if (selectedPartnerId == null) {
      // Handle the case when there is no selected partner
      _allReservationTicket = [];
    } else {
      var filteredList = _allReservationTicket.where((reservation) {
        bool isUserShared =
            reservation.sharedWith?.contains(currentUserId) ?? false;
        bool checkOut =
            reservation.checkOut ?? false; // Default to false if null
        return reservation.checkIn &&
            !checkOut && // Ensure checkOut is false
            reservation.partnerId == selectedPartnerId &&
            (reservation.eventDate
                    .isAtSameMomentAs(DateTime(now.year, now.month, now.day)) ||
                reservation.eventDate.isAfter(
                    DateTime(now.year, now.month, now.day)
                        .subtract(Duration(days: 1)))) &&
            (reservation.userId == currentUserId || isUserShared);
      }).toList();
      _allReservationTicket = filteredList;
    }
    _updateTotalSharedWithCount(); // Update shared count
    notifyListeners();
  }

  void _updateTotalSharedWithCount() {
    _totalSharedWithCount = _allReservationTicket.fold(0, (sum, table) {
      int count = table.sharedWith?.length ?? 0;
      print('Table: ${table.id}, Shared With Count: $count'); // Added print
      return sum + count;
    });
    print('Total Shared With Count: $_totalSharedWithCount'); // Added print
  }

  List<String> getAllSharedWith() {
    Set<String> sharedWithSet = {};
    for (var table in _allReservationTicket) {
      if (table.sharedWith != null) {
        sharedWithSet.addAll(table.sharedWith!);
      }
    }
    return sharedWithSet.toList();
  }

  void clearAllReserveTable() {
    _allReservationTicket = [];
    _totalSharedWithCount = 0;
    notifyListeners();
  }
}
