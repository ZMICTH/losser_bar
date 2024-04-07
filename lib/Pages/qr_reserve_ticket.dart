import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/reserve_ticket_model.dart';
import 'package:losser_bar/Pages/controllers/reserve_ticket_controller.dart';
import 'package:losser_bar/Pages/services/reserve_ticket_service.dart';
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

      // Fetch all reservations (adjust this method to actually fetch data)
      List<BookingTicket> fetchedReservations =
          await ticketconcertcontroller.fetchReservationTicket();

      // Now, filter these reservations for the current user before setting them in the provider
      Provider.of<ReservationTicketProvider>(context, listen: false)
          .setAllReservationTicket(fetchedReservations
              .where((reservation) => reservation.userId == userId)
              .toList());
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text("QR Reservation Tickets"),
      ),
      body: reservations == null || reservations.isEmpty
          ? Center(child: Text('No reservations made.'))
          : ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final bookingTicket = reservations[index];
                String formattedDate =
                    DateFormat('dd/MM/yyyy').format(bookingTicket.eventDate);

                return InkWell(
                  onTap: () {
                    Map<String, dynamic> reservationDetails = {
                      'userId': bookingTicket.userId,
                      'name': bookingTicket.nicknameUser,
                      'eventName': bookingTicket.eventName,
                      'selectedTableLabel': bookingTicket.selectedTableLabel,
                      'eventDate': bookingTicket.eventDate.toIso8601String(),
                      'ticketQuantity': bookingTicket.ticketQuantity,
                      'payable': bookingTicket.payable,
                      'checkIn': bookingTicket.checkIn,
                    };
                    // Convert the reservation details to a JSON string
                    String reservationDetailsString =
                        jsonEncode(reservationDetails);
                    _showQRCodePopup(context, reservationDetailsString);
                  },
                  child: Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.event_seat,
                        color: Colors.black,
                      ),
                      title: Text(
                        '${bookingTicket.selectedTableLabel} Table',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      trailing: Text(
                        formattedDate,
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

  void _showQRCodePopup(BuildContext context, String reservationDetailsString) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'โปรดแสดง QR Code ต่อเจ้าหน้าที่',
            style: TextStyle(color: Colors.black),
          ),
          content: SizedBox(
            width: 250.0,
            height: 400.0, // Increased height to accommodate additional details
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImageView(
                  data: reservationDetailsString,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                SizedBox(height: 20),
                // Text(
                //   'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(reservationDetails['selectedDay']))}',
                //   style: const TextStyle(fontSize: 16.0),
                // ),
                // Text(
                //   'Table: ${reservationDetails['selectedTableLabel']}',
                //   style: const TextStyle(fontSize: 16.0),
                // ),
                // Text(
                //   'Price: \$${reservationDetails['selectedTablePrice']}',
                //   style: const TextStyle(fontSize: 16.0),
                // ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
