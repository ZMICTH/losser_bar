import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RequestSongPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
    );
  }

  State<RequestSongPage> createState() => _RequestSongPageState();
}

class _RequestSongPageState extends State<RequestSongPage> {
  final _formKey = GlobalKey<FormState>();
  String _songname = '';

  get child => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text('What your mood ?'),
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
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'บอกเราหน่อย คุณอยากฟังเพลงอะไร ?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            Container(
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                onChanged: (value) {
                  setState(() {
                    _songname = value;
                  });
                },
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Song name',
                  labelStyle: TextStyle(
                    // fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your message';
                  }

                  return null;
                },
                onSaved: (newValue) {
                  _songname = newValue!;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$_songname'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                // primary: Colors.blue,
                // onPrimary: Colors.white,
                padding: EdgeInsets.fromLTRB(120, 10, 120, 10),
                textStyle: TextStyle(
                    fontSize: 25, // Text size
                    fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Button border radius
                ),
              ),
              child: Text('Sent Song'),
            ),
          ],
        ),
      ),
    );
  }
}
