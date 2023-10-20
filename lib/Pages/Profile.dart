import 'package:flutter/material.dart';

class styletext extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text('หน้าสมาชิก'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                //for popup messeng to user, sample locking page
                SnackBar(
                  content: Text('Hello....'),
                ),
              );
            },
            icon: Icon(Icons.add_alert),
          ),
          // IconButton(
          //   onPressed: () {
          //     //Move between page
          //     Navigator.pushNamed(context, '');
          //   },
          //   icon: Icon(Icons.navigate_next),
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/login');
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
                Navigator.pushNamed(context, '');
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
      ),
    );
  }
}
