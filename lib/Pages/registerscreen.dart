import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/Profile.dart';
import 'package:losser_bar/Pages/reserve_table_page.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String emailUser = '';
  String passwordUser = '';
  int ageUser = 0;
  String phoneUser = '';
  String nicknameUser = '';
  String firstnameUser = '';
  String lastnameUser = '';
  String idcard = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text('Register User'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'E-mail',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Please enter your Email"),
                    EmailValidator(errorText: "Wrong pattern Email"),
                  ]),
                  onSaved: (newEmailUser) {
                    emailUser = newEmailUser!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  obscureText: true,
                  inputFormatters: [LengthLimitingTextInputFormatter(15)],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Password';
                    }
                    if (value.length < 8) {
                      return 'Weak password';
                    }
                    return null;
                  },
                  onSaved: (newPasswordUser) {
                    passwordUser = newPasswordUser!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(13)],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tax ID',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Tax ID';
                    }
                    if (value.length < 13) {
                      return 'Short message';
                    }

                    return null;
                  },
                  onSaved: (newidcard) {
                    idcard = newidcard!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Firstname',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Firstname';
                    }

                    return null;
                  },
                  onSaved: (newfirstnameUser) {
                    firstnameUser = newfirstnameUser!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Lastname',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Lastname';
                    }

                    return null;
                  },
                  onSaved: (newlastnameUser) {
                    lastnameUser = newlastnameUser!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(15)],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nickname',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Nickname';
                    }

                    return null;
                  },
                  onSaved: (newnicknameUser) {
                    nicknameUser = newnicknameUser!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Age',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    int age = int.tryParse(value) ?? 0;

                    if (age < 20) {
                      return 'You must be at least 20 years old to register.';
                    }

                    return null;
                  },
                  onSaved: (newAgeUuser) {
                    ageUser = int.parse(newAgeUuser!);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Age must be a valid number';
                    }

                    return null;
                  },
                  onSaved: (newPhoneUser) {
                    phoneUser = newPhoneUser!;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    try {
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: emailUser,
                        password: passwordUser,
                      );

                      User? user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        await user.updateProfile(
                            displayName: 'Display Name', photoURL: null);

                        await FirebaseFirestore.instance
                            .collection('User')
                            .doc(user.uid)
                            .set({
                          'emailUser': emailUser,
                          'firstnameUser': firstnameUser,
                          'lastnameUser': lastnameUser,
                          'taxId': idcard,
                          'nicknameUser': nicknameUser,
                          'age': ageUser,
                          'phoneNumber': phoneUser,
                          // Add other fields as needed
                        });
                      }

                      _formKey.currentState!.reset();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      print(e.message);
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              'Registration Error',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              e.message ?? "An unknown error occurred",
                              style: TextStyle(color: Colors.black),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  textStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
