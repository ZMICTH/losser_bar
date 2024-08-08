import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/controllers/login_controller.dart';
import 'package:losser_bar/Pages/services/login_service.dart';

import 'package:provider/provider.dart';

class ShareQrTicketPage extends StatefulWidget {
  final String reservationId;
  final int ticketQuantity;
  final List<String>? sharedWithIds;

  ShareQrTicketPage({
    required this.reservationId,
    required this.ticketQuantity,
    required this.sharedWithIds,
  });

  @override
  _ShareQrTicketPage createState() => _ShareQrTicketPage();
}

class _ShareQrTicketPage extends State<ShareQrTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _phoneControllers = [
    TextEditingController()
  ];
  final List<String> _userIds = [''];

  late LoginController loginController =
      LoginController(LoginFirebaseService());
  bool isLoading = true;
  final List<bool> _isCorrectPhoneNumber = [true];
  final List<String> _nicknames = [''];
  final List<bool> _isDuplicate = [false];

  @override
  void initState() {
    super.initState();
    loginController = LoginController(LoginFirebaseService());
    _loadMemberInformations();
  }

  @override
  void dispose() {
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPhoneNumberField() {
    int maxAddition =
        widget.ticketQuantity - (widget.sharedWithIds?.length ?? 0);

    if (_phoneControllers.length < maxAddition) {
      setState(() {
        _phoneControllers.add(TextEditingController());
        _isCorrectPhoneNumber.add(true);
        _nicknames.add('');
        _userIds.add('');
        _isDuplicate.add(false);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can only add up to $maxAddition more phone numbers.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkPhoneNumber(int index) {
    if (index >= _phoneControllers.length ||
        index >= _isCorrectPhoneNumber.length) {
      return; // Safeguard against invalid index access
    }

    String phoneNumber = _phoneControllers[index].text;
    MemberUserModel memberUserModel =
        Provider.of<MemberUserModel>(context, listen: false);

    MemberUser? member = memberUserModel.allMembers.firstWhere(
      (member) => member.phoneUser == phoneNumber,
      orElse: () => MemberUser(
        id: '', // Ensure the ID is empty if not found
        nicknameUser: '',
        ageUser: '',
        phoneUser: '',
        firstnameUser: '',
        lastnameUser: '',
        idcard: '',
        type: '',
        useService: [],
      ),
    );

    bool isDuplicate = widget.sharedWithIds?.contains(member.id) ?? false;

    setState(() {
      _isCorrectPhoneNumber[index] =
          member.phoneUser == phoneNumber && !isDuplicate;
      _isDuplicate[index] = isDuplicate;
      if (_isCorrectPhoneNumber[index]) {
        _nicknames[index] = member.nicknameUser;
        _userIds[index] = member.id;
      } else {
        _nicknames[index] = '';
        _userIds[index] = '';
      }
    });
  }

  void _loadMemberInformations() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Fetch member information from Firebase
      List<MemberUser> memberUsers = await loginController.fetchUserAccount();

      // Save the fetched data to the MemberUserModel provider
      Provider.of<MemberUserModel>(context, listen: false)
          .setAllMemberUser(memberUsers);
    } catch (e) {
      print('Error fetching member information: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check all phone numbers before submission
      for (int i = 0; i < _phoneControllers.length; i++) {
        _checkPhoneNumber(i);
      }

      List<String> phoneNumbers =
          _phoneControllers.map((controller) => controller.text).toList();
      List<String> validUserIds =
          _userIds.where((id) => id.isNotEmpty).toList();

      // Ensure we only update Firebase if we have valid user IDs
      if (validUserIds.isNotEmpty) {
        // Combine validUserIds with existing sharedWithIds
        List<String> updatedSharedWithIds = [
          ...?widget.sharedWithIds,
          ...validUserIds
        ];

        await FirebaseFirestore.instance
            .collection('reservation_ticket')
            .doc(widget.reservationId)
            .update({
          'sharedWith': FieldValue.arrayUnion(updatedSharedWithIds),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully added users to the reservation.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
        Navigator.pop(context); // Close the dialog
        Navigator.pop(context); // Close the dialog
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No valid phone numbers provided.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the remaining number of users that can be added
    int maxAddition =
        widget.ticketQuantity - (widget.sharedWithIds?.length ?? 0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Share QR Code',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "You can add $maxAddition persons",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _phoneControllers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _phoneControllers[index],
                                        keyboardType: TextInputType.phone,
                                        maxLength: 10,
                                        decoration: InputDecoration(
                                          labelStyle: TextStyle(fontSize: 18),
                                          labelText: 'Phone Number',
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  _isCorrectPhoneNumber[index]
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a phone number';
                                          }
                                          if (value.length != 10 ||
                                              !RegExp(r'^\d{10}$')
                                                  .hasMatch(value)) {
                                            return 'Please enter a valid 10-digit phone number';
                                          }
                                          return null;
                                        },
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: _isCorrectPhoneNumber[index]
                                              ? Colors.black
                                              : Colors.red, // Text color
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isDuplicate[index])
                                  Text(
                                    'This phone number is already in the shared list.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                if (_isCorrectPhoneNumber[index] &&
                                    _nicknames[index].isNotEmpty)
                                  Text(
                                    'Nickname: ${_nicknames[index]}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              ElevatedButton(
                onPressed: _addPhoneNumberField,
                child: Text(
                  'Add Phone Number',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
