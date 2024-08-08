import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/reserve_ticket_model.dart';
import 'package:losser_bar/Pages/controllers/reserve_ticket_controller.dart';
import 'package:losser_bar/Pages/services/reserve_ticket_service.dart';
import 'package:losser_bar/Pages/share_ticket.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrReservationTickets extends StatefulWidget {
  const QrReservationTickets({Key? key}) : super(key: key);

  @override
  State<QrReservationTickets> createState() => _QrReservationTicketsState();
}

class _QrReservationTicketsState extends State<QrReservationTickets> {
  late TicketConcertController ticketconcertcontroller =
      TicketConcertController(TicketConcertFirebaseService());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    ticketconcertcontroller =
        TicketConcertController(TicketConcertFirebaseService());
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => isLoading = true);
    try {
      final userId =
          FirebaseAuth.instance.currentUser?.uid; // Get current user's ID
      if (userId == null) throw Exception('User not logged in');

      // Fetch all reservations created by the user
      List<BookingTicket> fetchedReservations =
          await ticketconcertcontroller.fetchReservationTicket();

      // Filter reservations created by the user
      // List<BookingTicket> userReservations = fetchedReservations
      //     .where((reservation) => reservation.userId == userId)
      //     .toList();

      // Filter reservations where sharedWith contains the userId
      List<BookingTicket> sharedReservations = fetchedReservations
          .where((reservation) => reservation.sharedWith!.contains(userId))
          .toList();

      // Combine both sets of reservations
      List<BookingTicket> allReservations = [
        // ...userReservations,
        ...sharedReservations,
      ];

      // Update the provider with all reservations
      Provider.of<ReservationTicketProvider>(context, listen: false)
          .setAllReservationTicket(allReservations);
    } catch (e) {
      print('Error fetching Reservations: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reserveTicketProvider =
        Provider.of<ReservationTicketProvider>(context);
    List<BookingTicket>? reservations =
        reserveTicketProvider.allReservationTicket;

    // Sort the reservations by formattedSelectedDay
    var sortedReservations = reserveTicketProvider.allReservationTicket;
    sortedReservations.sort((b, a) => a.eventDate.compareTo(b.eventDate));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: const Text("QR Reservation Tickets"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reservations == null || reservations.isEmpty
              ? const Center(child: Text('No reservations made.'))
              : ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final bookingTicket = reservations[index];
                    String formattedDate = DateFormat('dd/MM/yyyy')
                        .format(bookingTicket.eventDate);

                    return InkWell(
                      onTap: () {
                        DateTime expiryTime = DateTime(
                          bookingTicket.eventDate.year,
                          bookingTicket.eventDate.month,
                          bookingTicket.eventDate.day,
                          20,
                        );
                        if (DateTime.now().isAfter(expiryTime)) {
                          _showExpiredDialog(context);
                        } else {
                          Map<String, dynamic> reservationDetails = {
                            'id': bookingTicket.id,
                            // 'userId': bookingTicket.userId,
                            // 'name': bookingTicket.nicknameUser,
                            // 'eventName': bookingTicket.eventName,
                            // 'selectedTableLabel':
                            //     bookingTicket.selectedTableLabel,
                            // 'ticketId': bookingTicket.ticketId,
                            // 'eventDate':
                            //     bookingTicket.eventDate.toIso8601String(),
                            // 'ticketQuantity': bookingTicket.ticketQuantity,
                            // 'payable': bookingTicket.payable,
                            // 'checkIn': bookingTicket.checkIn,
                            // 'sharedCount': bookingTicket.sharedCount,
                            // 'sharedWith': bookingTicket.sharedWith,
                          };
                          // Convert the reservation details to a JSON string
                          String reservationDetailsString =
                              jsonEncode(reservationDetails);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QRCodeDisplayPage(
                                reservationDetailsString:
                                    reservationDetailsString,
                                reservationDay: bookingTicket.eventDate,
                                reservationId: bookingTicket.id,
                                ticketQuantity: bookingTicket.ticketQuantity,
                                sharedWithIds: bookingTicket.sharedWith,
                              ),
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: const Icon(
                            Icons.event_seat,
                            color: Colors.black,
                          ),
                          title: Text(
                            '${bookingTicket.eventName} - ${bookingTicket.selectedTableLabel}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          subtitle: bookingTicket.userId !=
                                  FirebaseAuth.instance.currentUser?.uid
                              ? Text('Share from ${bookingTicket.nicknameUser}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ))
                              : null,
                          trailing: Text(
                            formattedDate,
                            style: const TextStyle(
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

  void _showExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'QR Code Expired',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content:
            const Text('The QR code has expired. Please request a new one.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
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
  final int ticketQuantity;
  final List<String>? sharedWithIds;

  QRCodeDisplayPage({
    Key? key,
    required this.reservationDetailsString,
    required this.reservationDay,
    required this.reservationId,
    required this.ticketQuantity,
    required this.sharedWithIds,
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDependenciesInitialized) {
      _calculateTimeLeft();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _calculateTimeLeft();
      });
      _isDependenciesInitialized = true;
    }
  }

  Future<void> _loadSharedCount() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('reservation_ticket')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: const Text('QR Code Display'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Doors open at 5:00 PM onwards.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    '2. Please present your QR-Code booking number to the staff on the day and time of the event.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    '3. We reserve the right to change any terms and conditions without prior notice.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    '4. Tickets are non-transferable.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    '5. Please bring your ID card along with your booking number. Entry will be denied without ID verification.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: widget.reservationDetailsString,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 20),
            Text(_timeLeft != null
                ? 'Expires in: ${formatDuration(_timeLeft!)}'
                : 'QR Code Expired'),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ShareQrTicketPage(
                      reservationId: widget.reservationId,
                      ticketQuantity: widget.ticketQuantity,
                      sharedWithIds: widget.sharedWithIds,
                    ),
                  ),
                );
              },
              child: Text(
                'Share QR',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
