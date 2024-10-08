import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class LoginService {
  Future<Map<String, dynamic>> getLogin(String userId);
  void addUser(MemberUser user);

  Future<List<MemberUser>> getAllUserAccount();
}

class LoginFirebaseService implements LoginService {
  @override
  Future<Map<String, dynamic>> getLogin(String userId) async {
    DocumentSnapshot qs =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();
    if (qs.data() != null) {
      Map<String, dynamic> userData = qs.data() as Map<String, dynamic>;
      dynamic user = FirebaseAuth.instance.currentUser;
      userData['id'] = user.uid;
      userData['email'] = user.email;
      print(userData);
      return userData;
    } else {
      print("Document does not exist or is empty.");
      return {};
    }
  }

  @override
  void addUser(MemberUser user) {
    print('Login user id=${user.id}');
    FirebaseFirestore.instance.collection('User').doc(user.id).update({
      // 'emailUser': user.emailUser,
      'ageUser': user.ageUser,
      'nicknameUser': user.nicknameUser,
      'phoneUser': user.phoneUser,
      'firstnameUser': user.firstnameUser,
      'lastnameUser': user.lastnameUser,
      'taxId': user.idcard,
    });
  }

  @override
  Future<List<MemberUser>> getAllUserAccount() async {
    print("getAllUserAccount is called");
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('User')
        .where('type', isEqualTo: 'customer')
        .get();
    print("BillOrder count: ${qs.docs.length}");
    AllMemberUser memberUser = AllMemberUser.fromSnapshot(qs);
    print(memberUser.memberusers);
    return memberUser.memberusers;
  }
}
