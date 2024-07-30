import 'dart:async';

import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/services/login_service.dart';

class LoginController {
  Map<String, dynamic> currentuser = {};
  final LoginService service;
  List<MemberUser> UserInfo = List.empty();

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;
  LoginController(this.service);

  Future<Map<String, dynamic>> fetchLogin(userId) async {
    onSyncController.add(true);
    currentuser = await service.getLogin(userId);
    onSyncController.add(false);
    return currentuser;
  }

  void addUser(MemberUser user) async {
    service.addUser(user);
  }

  Future<List<MemberUser>> fetchUserAccount() async {
    print("fetchBillOrder was: ${UserInfo}");
    onSyncController.add(true);
    UserInfo = await service.getAllUserAccount();
    onSyncController.add(false);
    return UserInfo;
  }
}
