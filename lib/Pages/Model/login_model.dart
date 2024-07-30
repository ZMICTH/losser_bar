import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberUser {
  String id = "";
  late String nicknameUser; // Nullable type
  late String ageUser; // Nullable type
  late String phoneUser; // Nullable type
  late String firstnameUser;
  late String lastnameUser;
  late String idcard;
  late String type;
  List<Map<String, dynamic>> useService;

  MemberUser({
    this.id = "",
    required this.nicknameUser,
    required this.ageUser,
    required this.phoneUser,
    required this.firstnameUser,
    required this.lastnameUser,
    required this.idcard,
    required this.type,
    required this.useService,
  });

  factory MemberUser.fromJson(Map<String, dynamic> json) {
    print(json);
    return MemberUser(
      id: json['id'] ?? "",
      nicknameUser: json['nicknameUser'] ?? '', // Safe handling of null values
      ageUser: json['age']?.toString() ?? '',
      phoneUser: json['phoneNumber'] ?? '',
      firstnameUser: json['firstnameUser'] ?? '',
      lastnameUser: json['lastnameUser'] ?? '',
      idcard: json['taxId'] ?? '',
      type: json['type'] as String,
      useService: (json['useService'] as List<dynamic>? ?? [])
          .map<Map<String, dynamic>>((useService) {
        return Map<String, dynamic>.from(useService as Map);
      }).toList(),
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
      'useService': useService
          .map((useservice) => {
                'date': useservice['date'],
                'partnerId': useservice['partnerId'],
                'roundtable': useservice['roundtable'],
                'tableNo': useservice['tableNo'],
              })
          .toList(),
    };
  }
}

class AllMemberUser {
  final List<MemberUser> memberusers;

  AllMemberUser(this.memberusers);

  factory AllMemberUser.fromJson(List<dynamic> json) {
    List<MemberUser> memberusers =
        json.map((item) => MemberUser.fromJson(item)).toList();
    return AllMemberUser(memberusers);
  }

  factory AllMemberUser.fromSnapshot(QuerySnapshot qs) {
    List<MemberUser> memberusers = qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> dataWithId = ds.data() as Map<String, dynamic>;
      dataWithId['id'] = ds.id;
      return MemberUser.fromJson(dataWithId);
    }).toList();
    return AllMemberUser(memberusers);
  }

  Map<String, dynamic> toJson() {
    return {
      'memberusers': memberusers.map((member) => member.toJson()).toList(),
    };
  }
}

class MemberUserModel with ChangeNotifier {
  MemberUser? _memberUser;
  MemberUser? get memberUser => _memberUser;

  List<MemberUser> _allMembers = [];
  List<MemberUser> get allMembers => _allMembers;

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

  void setAllMemberUser(List<MemberUser> memberUser) {
    _allMembers = memberUser;
    notifyListeners();
  }
}
