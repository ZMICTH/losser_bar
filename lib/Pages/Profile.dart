import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isLoggedIn) ...[
              ProfileCard(memberUser: memberUser),
              QRCodeButton(),
              AllReceiptButton(),
              SizedBox(
                height: 30,
              ),
              LogoutButton(),
            ] else ...[
              SizedBox(
                height: 50,
              ),
              Image.asset(
                'images/logo.png',
                width: 400,
                height: 400,
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: 50,
              ),
              Text("Welcome to DrinkXplorer!"),
              SizedBox(
                height: 20,
              ),
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
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<MemberUserModel>(
                builder: (context, provider, child) {
                  final memberUser = provider.memberUser;
                  if (memberUser != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nickname: ${memberUser.nicknameUser}",
                            style: TextStyle(color: Colors.black)),
                        Text("First Name: ${memberUser.firstnameUser}",
                            style: TextStyle(color: Colors.black)),
                        Text("Last Name: ${memberUser.lastnameUser}",
                            style: TextStyle(color: Colors.black)),
                        Text("Phone Number: ${memberUser.phoneUser}",
                            style: TextStyle(color: Colors.black)),
                        Text("Tax ID: ${memberUser.idcard}",
                            style: TextStyle(color: Colors.black)),
                        Text("Age: ${memberUser.ageUser}",
                            style: TextStyle(color: Colors.black)),

                        // Include other fields as needed
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.content_copy),
                              tooltip: 'Copy User ID',
                              onPressed: () {
                                // Handle copying user ID logic here
                                Clipboard.setData(
                                    ClipboardData(text: memberUser.id));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('User ID copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
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
        ],
      ),
    );
  }

  Widget LogoutButton() {
    return ElevatedButton(
      onPressed: () {
        FirebaseAuth.instance.signOut();
        print('logout is call');
        context.read<MemberUserModel>().clearMemberUser();
      },
      child: Text(
        'Logout',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
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

  Widget QRCodeButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/allqr');
      },
      child: Text(
        'QR Code',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget AllReceiptButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/allReceipt');
      },
      child: Text(
        'All Receipts',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
