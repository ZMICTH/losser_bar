import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/Model/reserve_ticket_model.dart';
import 'package:losser_bar/Pages/controllers/reserve_ticket_controller.dart';
import 'package:losser_bar/Pages/services/reserve_ticket_service.dart';
import 'package:provider/provider.dart';

class ReserveTicketPage extends StatefulWidget {
  final String eventName;
  final DateTime eventDate;
  final String eventImage;
  final double ticketPrice;
  final String ticketId;

  ReserveTicketPage({
    Key? key,
    required this.eventName,
    required this.eventDate,
    required this.eventImage,
    required this.ticketPrice,
    required this.ticketId,
  }) : super(key: key);

  @override
  State<ReserveTicketPage> createState() => _ReserveTicketPageState();
}

class _ReserveTicketPageState extends State<ReserveTicketPage> {
  late TicketConcertController ticketconcertcontroller =
      TicketConcertController(TicketConcertFirebaseService());
  bool isLoading = true;
  final List<String> tableLabels = ['VIP', 'ZoneA', 'ZoneB'];

  final List<int> tablePrices = [2000, 1400, 600];

  Map<String, int> tablePricesMap = {};
  bool checkIn = false;
  String selectedTableLabel = 'VIP';
  int? selectedTablePrice;
  double totalPrice = 0.0;
  int ticketQuantity = 1; // Default to 1

  @override
  void initState() {
    super.initState();
    tablePricesMap = Map.fromIterables(tableLabels, tablePrices);
    selectedTablePrice = tablePricesMap[tableLabels.first];
    updateTotalPrice(); // Initialize totalPrice with the initial table price plus the ticket price
  }

  void updateTotalPrice() {
    totalPrice =
        (selectedTablePrice ?? 0) + widget.ticketPrice * ticketQuantity;
  }

  @override
  Widget build(BuildContext context) {
    final String formattedEventDate =
        DateFormat('EEEE, MMMM d, yyyy').format(widget.eventDate);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text(widget.eventName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Image.network(widget.eventImage),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.eventName,
                style: const TextStyle(color: Colors.black, fontSize: 24),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                formattedEventDate,
                style: const TextStyle(color: Colors.black),
              ),
              // Add more details or widgets as needed
              const Text(
                "Please select type of Table",
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns in the grid
                    crossAxisSpacing: 10, // Horizontal space between items
                    mainAxisSpacing: 10, // Vertical space between items
                    childAspectRatio: 3 / 1,
                  ),
                  itemCount: tableLabels.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedTableLabel == tableLabels[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedTableLabel = tableLabels[index];
                          selectedTablePrice =
                              tablePricesMap[selectedTableLabel];
                          // Update totalPrice to reflect the new table selection
                          totalPrice =
                              (selectedTablePrice ?? 0) + widget.ticketPrice;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: isSelected
                                  ? Colors.deepPurple[800]!
                                  : Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected
                              ? Colors.deepPurple[800]!.withOpacity(0.3)
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            '${tableLabels[index]} - THB ${tablePrices[index]}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.deepPurple[800]!
                                  : Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  shrinkWrap: true,
                  // To prevent GridView from scrolling inside a SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove,
                      color: Colors.black,
                      size: 30,
                    ),
                    onPressed: () {
                      if (ticketQuantity > 1) {
                        // Prevent going below 1
                        setState(() {
                          ticketQuantity--;
                          updateTotalPrice();
                        });
                      }
                    },
                  ),
                  Text(
                    "$ticketQuantity",
                    style: const TextStyle(
                      color: Colors.black, // Set text color to black
                      fontSize: 25, // Set font size to 20
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 30,
                    ),
                    onPressed: () {
                      if (ticketQuantity < 4) {
                        // Ensure ticketQuantity does not exceed 4
                        setState(() {
                          ticketQuantity++;
                          updateTotalPrice();
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),
              // GridView.builder and other UI elements...
              if (selectedTablePrice != null)
                Column(
                  children: [
                    Text('Table Price: THB ${selectedTablePrice.toString()}',
                        style: const TextStyle(color: Colors.black)),
                    Text(
                        'Ticket Price: THB ${widget.ticketPrice.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black)),
                    Text('Total Price: THB ${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black)),
                  ],
                ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: _confirmReserving,
                child: const Text("Confirm Reserving"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmReserving() async {
    // Assuming the existence of a user model and a way to get the current user's ID and nickname
    final userId =
        Provider.of<MemberUserModel>(context, listen: false).memberUser?.id ??
            'defaultUserId';
    final userNickName = Provider.of<MemberUserModel>(context, listen: false)
            .memberUser
            ?.nicknameUser ??
        'defaultNickname';

    final docRef = FirebaseFirestore.instance
        .collection('ticket_concert_catalog')
        .doc(widget.ticketId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[600],
          title: const Text('Confirm Reserving',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please confirm your reservation details:'),
              // Display reservation details for user confirmation
              const SizedBox(height: 20),
              Image.asset(
                  'images/promtpay.jpeg'), // Assuming you want to show a payment QR or image
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                Navigator.of(context)
                    .pop(); // Close the dialog immediately on confirm
                try {
                  FirebaseFirestore.instance
                      .runTransaction((transaction) async {
                    // Get the current document
                    DocumentSnapshot snapshot = await transaction.get(docRef);

                    if (!snapshot.exists) {
                      throw Exception("Concert ticket does not exist!");
                    }

                    // Calculate the new number of tickets
                    int currentTickets = snapshot.get('numberOfTickets');
                    if (currentTickets < ticketQuantity) {
                      throw Exception("Not enough tickets available!");
                    }
                    int updatedTickets = currentTickets - ticketQuantity;

                    // Update the document
                    transaction
                        .update(docRef, {'numberOfTickets': updatedTickets});

                    // Proceed to create the reservation
                    final newReservation = BookingTicket(
                      userId: userId,
                      ticketId: widget.ticketId,
                      nicknameUser: userNickName,
                      eventName: widget.eventName,
                      selectedTableLabel: selectedTableLabel,
                      eventDate: widget.eventDate,
                      totalPayment: totalPrice,
                      ticketQuantity: ticketQuantity,
                      payable: true,
                      checkIn: false,
                    );

                    // Assuming you have a method to add the reservation in your controller
                    await ticketconcertcontroller
                        .addReserveTicket(newReservation);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reservation successful')),
                  );
                  // If you're clearing selections or resetting state, do it here

                  Navigator.pop(context); // Close the dialog
                  Navigator.of(context).pushReplacementNamed(
                      '/home'); // Navigate user away on successful reservation
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to reserve ticket: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
