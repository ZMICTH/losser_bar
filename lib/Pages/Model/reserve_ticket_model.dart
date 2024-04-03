import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  });

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
    };
  }
}

class ReserveTicketProvider extends ChangeNotifier {
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
