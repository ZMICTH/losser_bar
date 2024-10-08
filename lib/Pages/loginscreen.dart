import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/Profile.dart';
import 'package:losser_bar/Pages/controllers/login_controller.dart';
import 'package:losser_bar/Pages/services/login_service.dart';
import 'package:losser_bar/newhome.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  bool isloading = false;
  LoginController controller = LoginController(LoginFirebaseService());

  @override //for use first step
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 8.0,
              ),
              Image.asset(
                'images/logo.png',
                width: 150,
                height: 200,
              ),
              SizedBox(
                height: 8.0,
              ),
              Container(
                height: 2,
                color: Colors.grey[600],
              ),
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
                  onSaved: (newemail) {
                    email = newemail!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
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
                      counterText: '${password.length.toString()}/15'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Password';
                    }
                    if (value.length < 8) {
                      return 'Wrong pasword';
                    }
                    return null;
                  },
                  onSaved: (newpassword) {
                    password = newpassword!;
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
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Validates the form
                              _formKey.currentState!.save();
                              try {
                                UserCredential userCredential =
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );
                                // _formKey.currentState!.reset();
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);

                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => NewHomePage()),
                                // );

                                // Get the User object
                                User? user = userCredential.user;

                                // Get the User ID
                                String userId = user?.uid ?? '';
                                print("User ID: $userId");
                                Map<String, dynamic> UserData =
                                    await controller.fetchLogin(userId);

                                MemberUser mu = MemberUser.fromJson(UserData);
                                mu.id = userId;
                                context
                                    .read<MemberUserModel>()
                                    .setMemberUser(mu);
                              } on FirebaseAuthException catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Registration Error',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      content: Text(
                                        "Invalid Account",
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
                      //       print('logout is call 1');
                      //       FirebaseAuth.instance.signOut();
                      //     },
                      //     child: Text('Logout'),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
