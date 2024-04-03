import 'package:flutter/material.dart';

class MemberUser {
  String id = "";
  late String nicknameUser; // Nullable type
  late String ageUser; // Nullable type
  late String phoneUser; // Nullable type
  late String firstnameUser;
  late String lastnameUser;
  late String idcard;

  MemberUser({
    required this.nicknameUser,
    required this.ageUser,
    required this.phoneUser,
    required this.firstnameUser,
    required this.lastnameUser,
    required this.idcard,
  });

  factory MemberUser.fromJson(Map<String, dynamic> json) {
    return MemberUser(
      nicknameUser: json['nicknameUser'] ?? '', // Safe handling of null values
      ageUser: json['age']?.toString() ?? '',
      phoneUser: json['phoneNumber'] ?? '',
      firstnameUser: json['firstnameUser'] ?? '',
      lastnameUser: json['lastnameUser'] ?? '',
      idcard: json['taxId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nicknameUser': nicknameUser,
      'ageUser': ageUser,
      'phoneUser': phoneUser,
      'firstnameUser': firstnameUser,
      'lastnameUser': lastnameUser,
      'taxId': idcard,
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
  void updateFirstName(String nickName) {
    if (_memberUser != null) {
      _memberUser!.nicknameUser = nickName;
      notifyListeners();
    }
  }
}
