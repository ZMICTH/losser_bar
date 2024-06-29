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
    return MemberUser(
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

  // Method to get the latest useService entry
  Map<String, String>? getLatestUseService() {
    if (_memberUser != null && _memberUser!.useService.isNotEmpty) {
      var latestUseService = _memberUser!.useService.last;
      return {
        'partnerId': latestUseService['partnerId'] as String,
        'tableNo': latestUseService['tableNo'] as String,
        'roundTable': latestUseService['roundtable'] as String,
      };
    }
    return null;
  }

  // Method to add a new useService entry
  void addUseService(Map<String, dynamic> newUseService) {
    if (_memberUser != null) {
      _memberUser!.useService.add(newUseService);
      notifyListeners();
    }
  }
}
