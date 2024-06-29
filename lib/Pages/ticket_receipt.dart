import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/reserve_ticket_model.dart';
import 'package:losser_bar/Pages/controllers/pdf_ticket_gen.dart';
import 'package:losser_bar/Pages/controllers/reserve_ticket_controller.dart';
import 'package:losser_bar/Pages/services/reserve_ticket_service.dart';
import 'package:provider/provider.dart';

class TicketReceiptPage extends StatefulWidget {
  @override
  State<TicketReceiptPage> createState() => _TicketReceiptPageState();
}

class _TicketReceiptPageState extends State<TicketReceiptPage> {
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

      // Update the provider with all reservations
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

  String _getOrderNames(List<Map<String, dynamic>> orders) {
    return orders.map((order) => order['name'].toString()).join(', ');
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
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: const Text('Ticket Booking History'),
      ),
      body: reservations == null || reservations.isEmpty
          ? const Center(child: Text('No Order History'))
          : ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final ticket = reservations[index];
                // Format the billingTime using DateFormat
                final formattedBillingTime =
                    DateFormat('yyyy-MM-dd – kk:mm').format(ticket.paymentTime);
                return InkWell(
                  child: Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.receipt_long, color: Colors.black),
                      title: Text(
                        'Payment Time: $formattedBillingTime',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      subtitle: Text(
                        'Concert: ${ticket.eventName}\nTotal Price: ${ticket.totalPayment.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                TicketDetailPage(ticket: ticket),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class TicketDetailPage extends StatelessWidget {
  final BookingTicket ticket;

  TicketDetailPage({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedBillingTime =
        DateFormat('yyyy-MM-dd – kk:mm').format(ticket.paymentTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt Details'),
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Concert: ${ticket.eventName}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Payment Time: $formattedBillingTime',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Total Tickets: ${ticket.ticketQuantity}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Total Price: ${ticket.totalPayment.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final pdfGenerator = PdfTicketGenerator(ticket);
                  pdfGenerator.generatePdf();
                },
                child: Text('Generate PDF',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
