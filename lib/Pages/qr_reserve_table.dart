import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:losser_bar/Pages/controllers/reserve_table_controller.dart';
import 'package:losser_bar/Pages/services/reserve_table_service.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrReservations extends StatefulWidget {
  const QrReservations({Key? key}) : super(key: key);

  @override
  State<QrReservations> createState() => _QrReservationsState();
}

class _QrReservationsState extends State<QrReservations> {
  late ReserveTableHistoryController reservetablehistorycontroller =
      ReserveTableHistoryController(ReserveTableFirebaseService());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    reservetablehistorycontroller =
        ReserveTableHistoryController(ReserveTableFirebaseService());
    _loadReservationHistory();
  }

  Future<void> _loadReservationHistory() async {
    setState(() => isLoading = true); // Ensure loading state is true
    try {
      final userId =
          FirebaseAuth.instance.currentUser?.uid; // Get current user's ID
      if (userId == null) throw Exception('User not logged in');

      // Fetch all reservations created by the user
      List<ReserveTableHistory> fetchedReservations =
          await reservetablehistorycontroller.fetchReserveTableHistory();
      List<ReserveTableHistory> userReservations = fetchedReservations
          .where((reservation) => reservation.userId == userId)
          .toList();

      QuerySnapshot sharedReservationsSnapshot = await FirebaseFirestore
          .instance
          .collection('reservation_table')
          .where('sharedWith', arrayContains: userId)
          .get();
      List<ReserveTableHistory> sharedReservations = sharedReservationsSnapshot
          .docs
          .map((doc) =>
              ReserveTableHistory.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Combine both sets of reservations
      List<ReserveTableHistory> allReservations = [
        ...userReservations,
        ...sharedReservations,
      ];

      // Update the provider with all reservations
      Provider.of<ReserveTableProvider>(context, listen: false)
          .setReserveTable(allReservations);
    } catch (e) {
      print('Error fetching Reservations: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reserveTableProvider = Provider.of<ReserveTableProvider>(context);
    List<ReserveTableHistory>? reservations =
        reserveTableProvider.allReserveTable;

    // Sort the reservations by formattedSelectedDay
    var sortedReservations = reserveTableProvider.allReserveTable;
    sortedReservations.sort(
        (b, a) => a.formattedSelectedDay.compareTo(b.formattedSelectedDay));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text('Reservations History'),
      ),
      body: reservations == null || reservations.isEmpty
          ? Center(child: Text('No reservations made.'))
          : ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                String formatSelectedDay = DateFormat('dd/MM/yyyy')
                    .format(reservation.formattedSelectedDay);
                String formatbookingTime = DateFormat('dd/MM/yyyy hh:mm:ss a')
                    .format(reservation.paymentTime);

                return InkWell(
                  onTap: () {
                    DateTime expiryTime = DateTime(
                        reservation.formattedSelectedDay.year,
                        reservation.formattedSelectedDay.month,
                        reservation.formattedSelectedDay.day,
                        20);
                    if (DateTime.now().isAfter(expiryTime)) {
                      _showExpiredDialog(context);
                    } else {
                      Map<String, dynamic> reservationDetails = {
                        'id': reservation.id,
                        // 'userId': reservation.userId,
                        // 'name': reservation.nicknameUser,
                        // 'userPhone': reservation.userPhone,
                        // 'selectedTableLabel': reservation.selectedTableLabel,
                        // 'selectedSeats': reservation.selectedSeats,
                        // 'selectedDay':
                        //     reservation.formattedSelectedDay.toIso8601String(),
                        // 'checkIn': reservation.checkIn,
                        // 'payable': reservation.payable,
                        // 'totalPrices': reservation.totalPrices,
                        // 'paymentTime':
                        //     reservation.paymentTime.toIso8601String(),
                        // 'sharedCount': reservation.sharedCount,
                        // 'sharedWith': reservation.sharedWith,
                      };
                      String reservationDetailsString =
                          jsonEncode(reservationDetails);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QRCodeDisplayPage(
                            reservationDetailsString: reservationDetailsString,
                            reservationDay: reservation.formattedSelectedDay,
                            reservationId: reservation.id,
                            seatsQuantity: reservation.selectedSeats,
                          ),
                        ),
                      );
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.event_seat,
                        color: Colors.black,
                      ),
                      title: Text(
                        '${reservation.selectedTableLabel} - ${reservation.selectedSeats} seats',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      subtitle: reservation.userId !=
                              FirebaseAuth.instance.currentUser?.uid
                          ? Text('Share from ${reservation.nicknameUser}',
                              style: TextStyle(
                                color: Colors.black54,
                              ))
                          : null,
                      trailing: Text(
                        formatSelectedDay,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showExpiredDialog(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'QR Code Expired',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Text('The QR code has expired. Please request a new one.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class QRCodeDisplayPage extends StatefulWidget {
  final String reservationDetailsString;
  final DateTime reservationDay;
  final String reservationId;
  final int seatsQuantity;

  QRCodeDisplayPage({
    Key? key,
    required this.reservationDetailsString,
    required this.reservationDay,
    required this.reservationId,
    required this.seatsQuantity,
  }) : super(key: key);

  @override
  _QRCodeDisplayPageState createState() => _QRCodeDisplayPageState();
}

class _QRCodeDisplayPageState extends State<QRCodeDisplayPage> {
  Timer? _timer;
  Duration? _timeLeft;
  bool _isDependenciesInitialized = false;
  int sharedCount = 0;

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    super.initState();
    _loadSharedCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDependenciesInitialized) {
      _calculateTimeLeft();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _calculateTimeLeft();
      });
      _isDependenciesInitialized = true;
    }
  }

  Future<void> _loadSharedCount() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('reservation_table')
        .doc(widget.reservationId)
        .get();

    if (doc.exists && doc.data() != null) {
      setState(() {
        sharedCount = doc.get('sharedCount') ?? 0;
      });
    }
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final expiryTime = DateTime(widget.reservationDay.year,
        widget.reservationDay.month, widget.reservationDay.day, 20);
    final duration = expiryTime.difference(now);

    if (duration.inSeconds <= 0) {
      _timer?.cancel();
    } else {
      setState(() {
        _timeLeft = duration;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _showShareDialog() async {
    final TextEditingController userIdController = TextEditingController();
    bool isValid = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Share QR Code',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userIdController,
                decoration: InputDecoration(
                  labelText: 'Enter friend\'s user ID',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isValid)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Cannot share more than ${widget.seatsQuantity - 1} times',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
            ),
            TextButton(
              onPressed: () async {
                if (sharedCount < widget.seatsQuantity - 1) {
                  setState(() {
                    sharedCount++;
                  });

                  // Save friend's user ID and increment shared count in Firebase
                  await FirebaseFirestore.instance
                      .collection('reservation_table')
                      .doc(widget.reservationId)
                      .update({
                    'sharedCount': FieldValue.increment(1),
                    'sharedWith':
                        FieldValue.arrayUnion([userIdController.text]),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('QR code shared successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.of(context).pop();
                } else {
                  setState(() {
                    isValid = false;
                  });
                }
              },
              child: Text('Share',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text('QR Code Display'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '1. Doors open at 5:00 PM onwards.\n'
                '2. Please present your QR-Code booking number to the staff on the day and time of the event.\n'
                '3. We reserve the right to change any terms and conditions without prior notice.\n'
                '4. Tickets are non-transferable.\n'
                '5. Please bring your ID card along with your booking number. Entry will be denied without ID verification.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              QrImageView(
                data: widget.reservationDetailsString,
                version: QrVersions.auto,
                size: 200.0,
              ),
              SizedBox(height: 20),
              Text(_timeLeft != null
                  ? 'Expires in: ${formatDuration(_timeLeft!)}'
                  : 'QR Code Expired'),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  _showShareDialog();
                },
                child: Text(
                  'Share QR',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
