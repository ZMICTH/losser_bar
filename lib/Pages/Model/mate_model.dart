import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MateCatalog {
  String id = "";
  late String nameMate;
  late String description;
  late String genderMate;
  late String ageMate;
  late String weightMate;
  late String heightMate;
  late String shapeMate;
  late String talentMate;
  late int pricePerHour;
  String mateimagePath;
  bool drinking;

  MateCatalog(
    this.nameMate,
    this.description,
    this.genderMate,
    this.ageMate,
    this.weightMate,
    this.heightMate,
    this.shapeMate,
    this.talentMate,
    this.pricePerHour,
    this.mateimagePath,
    this.drinking,
  );
  factory MateCatalog.fromJson(Map<String, dynamic> json) {
    print("MateCatalog.fromJson");
    print(json);
    return MateCatalog(
      json['nameMate'] as String,
      json['description'] as String,
      json['genderMate'] as String,
      json['ageMate'] as String,
      json['weightMate'] as String,
      json['heightMate'] as String,
      json['shapeMate'] as String,
      json['talentMate'] as String,
      json['pricePerHour'] as int,
      json['mateimagePath'] as String,
      json['drinking'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': nameMate,
      'description': description,
      'gender': genderMate,
      'age': ageMate,
      'weight': weightMate,
      'height': heightMate,
      'shape': shapeMate,
      'talent': talentMate,
      'price': pricePerHour,
      'imagePath': mateimagePath,
      'drinking': drinking,
    };
  }
}

class AllMateCatalog {
  final List<MateCatalog> MateCatalogs;

  AllMateCatalog(this.MateCatalogs); // for Todo read each list from json

  factory AllMateCatalog.fromJson(List<dynamic> json) {
    List<MateCatalog> MateCatalogs;

    MateCatalogs = json.map((item) => MateCatalog.fromJson(item)).toList();

    return AllMateCatalog(MateCatalogs);
  }

  factory AllMateCatalog.fromSnapshot(QuerySnapshot qs) {
    List<MateCatalog> MateCatalogs;

    MateCatalogs = qs.docs.map((DocumentSnapshot ds) {
      MateCatalog matecatalog =
          MateCatalog.fromJson(ds.data() as Map<String, dynamic>);
      matecatalog.id = ds.id;
      return matecatalog;
    }).toList();

    return AllMateCatalog(MateCatalogs);
  }
}

class BillBookingMate {
  String id = "";
  String tableNo;
  Map<String, dynamic> bookingMate;
  String userId;
  String nicknameUser;
  DateTime billingTime;

  BillBookingMate({
    required this.tableNo,
    required this.bookingMate,
    required this.userId,
    required this.nicknameUser,
    required this.billingTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'tableNo': tableNo,
      'bookingDetails': bookingMate,
      'userId': userId,
      'nicknameUser': nicknameUser,
      'billingTime': billingTime,
    };
  }
}

class MateCafeModel extends ChangeNotifier {
  List<MateCatalog> _matecafe = [];

  final List<Map<String, dynamic>> _booking = [];

  List<MateCatalog> get matescafe => _matecafe;
  List<Map<String, dynamic>> get booking => _booking;

  int _findmateIndex(MateCatalog mate) {
    return _booking.indexWhere((item) => item['id'] == mate.id);
  }

  void setMateCatalogs(List<MateCatalog> mateCatalogs) {
    _matecafe = mateCatalogs;
    notifyListeners();
  }

  void addBooking(MateCatalog mate, int hoursBooked) {
    int totalPrice = mate.pricePerHour * hoursBooked;

    Map<String, dynamic> bookingDetails = {
      'id': mate.id,
      'name': mate.nameMate,
      'price': mate.pricePerHour,
      'hours': hoursBooked,
      'totalPrice': totalPrice,
      // Add other necessary fields from MateCatalog if needed
    };

    _booking.add(bookingDetails);
    notifyListeners();
  }

  void clearbookingmate() {
    booking.clear();
    notifyListeners();
  }

  // Add methods to fetch and set MateCatalog data if needed
}
