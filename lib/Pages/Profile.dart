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
  @override
  Widget build(BuildContext context) {
    final memberUser = Provider.of<MemberUserModel>(context).memberUser;
    final isLoggedIn = memberUser != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text('Membership'),
        // ... other AppBar properties ...
      ),
      body: Center(
        child: Column(
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
                    Text("First Name: ${memberUser.firstName}",
                        style: TextStyle(color: Colors.black)),
                    Text("Last Name: ${memberUser.lastName}",
                        style: TextStyle(color: Colors.black)),
                    Text("Postcode: ${memberUser.postcode}",
                        style: TextStyle(color: Colors.black)),
                    Text("Age: ${memberUser.age}",
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
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(),
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
