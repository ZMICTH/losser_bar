import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberUser {
  String id = "";
  String firstName;
  String lastName;
  String postcode;

  final int age;

  MemberUser(
    this.firstName,
    this.lastName,
    this.postcode,
    this.age,
  );

  factory MemberUser.fromJson(Map<String, dynamic> json) {
    return MemberUser(
      json['firstName'] as String,
      json['lastName'] as String,
      json['postcode'] as String,
      json['age'] as int,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'postCode': postcode,
      'age': age,
    };
  }
}

class MemberUserModel with ChangeNotifier {
  MemberUser? _memberUser;

  MemberUser? get memberUser => _memberUser;

  void setMemberUser(MemberUser memberUser) {
    _memberUser = memberUser;
    print('Member was call');
    print(memberUser);
    notifyListeners();
  }

  void clearMemberUser() {
    _memberUser = null;
    notifyListeners();
  }

  // You can add other methods here to modify the MemberUser data
  // For example, updating the first name:
  void updateFirstName(String firstName) {
    if (_memberUser != null) {
      _memberUser!.firstName = firstName;
      notifyListeners();
    }
  }
}
