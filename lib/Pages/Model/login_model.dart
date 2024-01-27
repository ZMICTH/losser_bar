import 'package:flutter/material.dart';

class MemberUser {
  String id = "";
  String? nicknameUser; // Nullable type
  String? ageUser; // Nullable type
  String? phoneUser; // Nullable type
  String? firstnameUser;
  String? lastnameUser;
  String? idcard;

  MemberUser(
    this.nicknameUser,
    this.ageUser,
    this.phoneUser,
    this.firstnameUser,
    this.lastnameUser,
    this.idcard,
  );

  factory MemberUser.fromJson(Map<String, dynamic> json) {
    return MemberUser(
      json['nicknameUser'] as String?, // Handling null with nullable type
      json['ageUser'] as String?, // Handling null with nullable type
      json['phoneUser'] as String?,
      json['firstnameUser'] as String?,
      json['lastnameUser'] as String?,
      json['idcard'] as String?,
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
