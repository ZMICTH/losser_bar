import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Blank'),
            SizedBox(
              height: 8.0,
            ),
            Container(
              height: 2,
              color: Colors.grey[600],
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: TextFormField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary),
                    counterText: '${_username.length.toString()}/20'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Username';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _username = newValue!;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                inputFormatters: [LengthLimitingTextInputFormatter(15)],
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary),
                    counterText: '${_password.length.toString()}/15'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Username';
                  }
                  if (value.length < 6) {
                    return 'Wrong pasword';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _password = newValue!;
                },
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');

                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Button border radius
                          ),
                        ),
                        child: Text('LOGIN'),
                      ),
                    ),
                    // Flexible(
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         SnackBar(
                    //           content: Text('Go to Register Page'),
                    //         ),
                    //       );
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       textStyle: TextStyle(
                    //           fontSize: 20, fontWeight: FontWeight.bold),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(
                    //             8), // Button border radius
                    //       ),
                    //     ),
                    //     child: Text('REGISTER'),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
