import 'package:flutter/material.dart';

class MemberUser {
  String id = "";
  String? nicknameUser; // Nullable type
  String? ageUser; // Nullable type
  String? phoneUser; // Nullable type

  MemberUser(
    this.nicknameUser,
    this.ageUser,
    this.phoneUser,
  );

  factory MemberUser.fromJson(Map<String, dynamic> json) {
    return MemberUser(
      json['nicknameUser'] as String?, // Handling null with nullable type
      json['ageUser'] as String?, // Handling null with nullable type
      json['phoneUser'] as String?, // Handling null with nullable type
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nicknameUser': nicknameUser,
      'ageUser': ageUser,
      'phoneUser': phoneUser,
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
