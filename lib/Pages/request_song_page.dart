import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RequestSongPage extends StatefulWidget {
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
                  color: Theme.of(context).colorScheme.onPrimary,
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
                    color: Theme.of(context).colorScheme.onPrimary,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SonglistRequestPage(
                        detail: SonglistDetail(_songname),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              child: Text(
                'Sent Song',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SonglistRequestPage extends StatelessWidget {
  final SonglistDetail detail;

  const SonglistRequestPage({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text('Music Chart Request'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ลำดับเพลงถัดไป',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            Text(
              detail.songname,
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SonglistDetail {
  final String songname;

  const SonglistDetail(this.songname);
}
