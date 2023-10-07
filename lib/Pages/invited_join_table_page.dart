import 'package:flutter/material.dart';

class InvitedJoinTablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        title: Text('ประกาศหาเพื่อนนั่งโต๊ะ'),
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
          IconButton(
            onPressed: () {
              //Move between page
              Navigator.pushNamed(context, '');
            },
            icon: Icon(Icons.navigate_next),
          ),
        ],
      ),
      body: Center(
        child: Text('Blank Page'),
      ),
    );
  }
}
