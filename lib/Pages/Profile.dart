import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/loginscreen.dart';
import 'package:losser_bar/Pages/registerscreen.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      setState(() {
        user = currentUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberUser = Provider.of<MemberUserModel>(context).memberUser;
    final isLoggedIn = memberUser != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoggedIn) ...[
              ProfileCard(memberUser: memberUser),
              LogoutButton(),
            ] else ...[
              LoginRegisterButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget ProfileCard({required MemberUser? memberUser}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Consumer<MemberUserModel>(
            builder: (context, provider, child) {
              final memberUser = provider.memberUser;
              if (memberUser != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("nickName: ${memberUser.nicknameUser}",
                        style: TextStyle(color: Colors.black)),
                    Text("ageUser: ${memberUser.ageUser}",
                        style: TextStyle(color: Colors.black)),
                    Text("phoneUser: ${memberUser.phoneUser}",
                        style: TextStyle(color: Colors.black)),
                    // Include other fields as needed
                  ],
                );
              } else {
                return Text("No user data available",
                    style: TextStyle(color: Colors.black));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget LogoutButton() {
    return ElevatedButton(
      onPressed: () {
        FirebaseAuth.instance.signOut();
        print('login is call 2');
        context.read<MemberUserModel>().clearMemberUser();
      },
      child: Text('Logout'),
    );
  }

  Widget LoginRegisterButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return LoginScreen();
                },
              ));
            },
            child: Container(
              alignment: Alignment.center,
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20.0)),
              child: Text(
                'Login',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );

              // ทำสิ่งที่คุณต้องการกับผลลัพธ์ที่ได้จากหน้า RegisterScreen ต่อไป
            },
            child: Container(
              alignment: Alignment.center,
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20.0)),
              child: Text(
                'Register',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
