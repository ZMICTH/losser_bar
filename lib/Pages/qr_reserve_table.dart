import 'dart:convert';

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
      var reservationHistories =
          await reservetablehistorycontroller.fetchReserveTableHistory();
      Provider.of<ReserveTableProvider>(context, listen: false).setReserveTable(
          reservationHistories
              .where((reservation) => reservation.userId == userId)
              .toList()); // Use the correct method name here
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
                String formattedDate = DateFormat('dd/MM/yyyy')
                    .format(reservation.formattedSelectedDay);

                return InkWell(
                  onTap: () {
                    Map<String, dynamic> reservationDetails = {
                      'userId': reservation.userId,
                      'name': reservation.nicknameUser,
                      'selectedTableLabel': reservation.selectedTableLabel,
                      'selectedTablePrice': reservation.selectedTablePrice,
                      'selectedDay':
                          reservation.formattedSelectedDay.toIso8601String(),
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
                        '${reservation.selectedTableLabel} Table',
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
