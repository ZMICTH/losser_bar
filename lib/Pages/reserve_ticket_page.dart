import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:losser_bar/Pages/Model/reserve_ticket_model.dart';
import 'package:losser_bar/Pages/controllers/reserve_table_controller.dart';
import 'package:losser_bar/Pages/controllers/reserve_ticket_controller.dart';
import 'package:losser_bar/Pages/provider/partner_model.dart';
import 'package:losser_bar/Pages/services/reserve_table_service.dart';
import 'package:losser_bar/Pages/services/reserve_ticket_service.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';
import 'package:provider/provider.dart';

class ReserveTicketPage extends StatefulWidget {
  final String eventName;
  final DateTime eventDate;
  final String eventImage;
  final double ticketPrice;
  final String ticketId;
  final int numberOfTickets;

  const ReserveTicketPage({
    Key? key,
    required this.eventName,
    required this.eventDate,
    required this.eventImage,
    required this.ticketPrice,
    required this.ticketId,
    required this.numberOfTickets,
  }) : super(key: key);

  @override
  State<ReserveTicketPage> createState() => _ReserveTicketPageState();
}

class _ReserveTicketPageState extends State<ReserveTicketPage> {
  late ReserveTableHistoryController reservetablehistorycontroller =
      ReserveTableHistoryController(ReserveTableFirebaseService());
  late TicketConcertController ticketconcertcontroller =
      TicketConcertController(TicketConcertFirebaseService());

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    reservetablehistorycontroller =
        ReserveTableHistoryController(ReserveTableFirebaseService());
    _loadTableCatalog();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReservationTicketProvider>(context, listen: false).eventDate =
          widget.eventDate;
    });
  }

  void _loadTableCatalog() async {
    try {
      // Fetch tables from Firebase
      List<TableCatalog> allTables =
          await reservetablehistorycontroller.fetchTableCatalog();
      // Set the fetched tables into the provider
      Provider.of<ReservationTicketProvider>(context, listen: false)
          .setTables(allTables);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading data: $e');
    }
  }

  void _updateTotalPrice() {
    final provider =
        Provider.of<ReservationTicketProvider>(context, listen: false);
    provider.totalPrice = (provider.selectedTablePrice ?? 0) +
        (widget.ticketPrice * provider.ticketQuantity);
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,##0", "en_US");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final String formattedEventDate =
        DateFormat('EEEE, MMMM d, yyyy').format(widget.eventDate);

    final provider = Provider.of<ReservationTicketProvider>(context);
    List<Map<String, dynamic>> allLabels =
        provider.tables.expand((table) => table.tableLables).toList();
    // Create a NumberFormat instance for formatting
    final numberFormat = NumberFormat("#,##0", "en_US");

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Image.network(widget.eventImage),
            SizedBox(height: 10),
            Text(
              "Losser Bar",
              style: TextStyle(
                color: Colors.blueGrey[900],
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            Text(
              "Present",
              style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Divider(
              height: 5,
              indent: 10,
            ),
            Text(
              "${widget.eventName}",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.blueGrey[900],
                  fontWeight: FontWeight.bold),
            ),
            Divider(
              height: 5,
              indent: 10,
            ),
            SizedBox(height: 5),
            Text(
              "${formattedEventDate}",
              style: TextStyle(color: Colors.blueGrey[900], fontSize: 20),
            ),
            Text(
              "== ${widget.ticketPrice.toStringAsFixed(0)} THB per ticket ==",
              style: TextStyle(color: Colors.blueGrey[900], fontSize: 20),
            ),
            SizedBox(height: 5),
            Text(
              "There are ${widget.numberOfTickets} concert tickets left",
              style: TextStyle(color: Colors.blueGrey[900], fontSize: 20),
            ),
            Divider(
              height: 5,
              indent: 10,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Please select type of Table",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 5 / 2,
                ),
                itemCount: allLabels.length,
                itemBuilder: (context, index) {
                  var label = allLabels[index];
                  bool isSelected =
                      provider.selectedTableLabel == label['label'];
                  bool isAvailable = label['totaloftable'] > 0;
                  return InkWell(
                    onTap: isAvailable
                        ? () {
                            provider.setSelectedTable(provider.tables
                                .firstWhere((table) => table.tableLables
                                    .any((l) => l['label'] == label['label'])));
                            provider.setSelectedTableLabel(label['label'],
                                label['tablePrices'], label['seats']);
                            _updateTotalPrice();
                          }
                        : null,
                    child: Container(
                      // padding:
                      //     EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      // margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepPurple[800]!
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isAvailable
                            ? (isSelected
                                ? Colors.deepPurple[800]!.withOpacity(0.3)
                                : const Color.fromARGB(0, 32, 25, 25))
                            : Colors.red[300],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${label['label']} (${label['seats']} seats)',
                            style: TextStyle(
                              color: isAvailable
                                  ? (isSelected ? Colors.white : Colors.grey)
                                  : Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Price: ${numberFormat.format(label['tablePrices'])} THB',
                            style: TextStyle(
                              color: isAvailable
                                  ? (isSelected ? Colors.white : Colors.grey)
                                  : Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Available: ${label['totaloftable']}',
                            style: TextStyle(
                              color: isAvailable
                                  ? (isSelected ? Colors.white : Colors.grey)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                shrinkWrap: true,
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
                    if (provider.ticketQuantity > 1) {
                      provider.decrementTicketQuantity();
                      _updateTotalPrice();
                    }
                  },
                ),
                Text(
                  "${provider.ticketQuantity}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: provider.ticketQuantity <
                          (provider.selectedTableSeats ?? 0)
                      ? () {
                          provider.incrementTicketQuantity();
                          _updateTotalPrice();
                        }
                      : null,
                ),
              ],
            ),
            if (provider.selectedTablePrice != null)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Price',
                              style: const TextStyle(color: Colors.white)),
                          SizedBox(height: 4),
                          Text(
                              '${numberFormat.format(provider.totalPrice)} THB',
                              style: const TextStyle(color: Colors.white)),
                          SizedBox(height: 4),
                          Text('Total Ticket: ${provider.ticketQuantity}',
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _confirmReserving,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Confirm Reserving",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmReserving() async {
    final provider =
        Provider.of<ReservationTicketProvider>(context, listen: false);
    final userId =
        Provider.of<MemberUserModel>(context, listen: false).memberUser?.id ??
            'defaultUserId';
    final userNickName = Provider.of<MemberUserModel>(context, listen: false)
            .memberUser
            ?.nicknameUser ??
        'defaultNickname';
    final userPhone = Provider.of<MemberUserModel>(context, listen: false)
            .memberUser
            ?.phoneUser ??
        'defaultNickname';
    final ticketDocRef = FirebaseFirestore.instance
        .collection('ticket_concert_catalog')
        .doc(widget.ticketId);
    final tableDocRef = FirebaseFirestore.instance
        .collection('table_catalog')
        .doc(provider.selectedTableId);
    final totalPrice = provider.totalPrice;
    final partnerId =
        Provider.of<SelectedPartnerProvider>(context, listen: false)
            .selectedPartnerId;

    // Proceed to create the reservation
    final newReservation = BookingTicket(
      userId: userId,
      ticketId: widget.ticketId,
      nicknameUser: userNickName,
      eventName: widget.eventName,
      selectedTableLabel: provider.selectedTableLabel!,
      eventDate: widget.eventDate,
      partnerId: partnerId!,
      totalPayment: totalPrice,
      ticketQuantity: provider.ticketQuantity,
      paymentTime: DateTime.now(),
      payable: true,
      checkIn: false,
      sharedWith: [userId],
      userPhone: userPhone,
    );
    print(newReservation);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[600]!,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          title: Text('Confirm Reserving'),
          content: QRCodeGenerate(
            promptPayId: "0987487348",
            amount: totalPrice,
            isShowAmountDetail: true,
            promptPayDetailCustom: Text("สิทธิวิชญ์ พิสิฐภูวโภคิน"),
            amountDetailCustom: Text('$totalPrice THB'),
            width: 400,
            height: 400,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  FirebaseFirestore.instance.runTransaction(
                    (transaction) async {
                      DocumentSnapshot ticketSnapshot =
                          await transaction.get(ticketDocRef);
                      if (!ticketSnapshot.exists) {
                        throw Exception("Concert ticket does not exist!");
                      }

                      DocumentSnapshot tableSnapshot =
                          await transaction.get(tableDocRef);
                      if (!tableSnapshot.exists) {
                        throw Exception('Table data not available');
                      }

                      // Calculate the new number of tickets
                      int currentTickets =
                          ticketSnapshot.get('numberOfTickets');
                      if (currentTickets < provider.ticketQuantity) {
                        throw Exception("Not enough tickets available!");
                      }
                      int updatedTickets =
                          currentTickets - provider.ticketQuantity;

                      // Update the ticket document
                      transaction.update(
                          ticketDocRef, {'numberOfTickets': updatedTickets});

                      Map<String, dynamic> data =
                          tableSnapshot.data() as Map<String, dynamic>;
                      List<dynamic> tableLabels = data['tableLables'];
                      List<Map<String, dynamic>> updatedLabels = [];
                      for (var label in tableLabels) {
                        Map<String, dynamic> currentLabel =
                            Map<String, dynamic>.from(label);

                        if (currentLabel['label'] ==
                            provider.selectedTableLabel) {
                          int newTotalOfTable =
                              (currentLabel['totaloftable'] as int) - 1;

                          updatedLabels.add({
                            'label': currentLabel['label'],
                            'numberofchairs': currentLabel['numberofchairs'],
                            'seats': currentLabel['seats'],
                            'tablePrices': currentLabel['tablePrices'],
                            'totaloftable': newTotalOfTable,
                          });
                        } else {
                          updatedLabels.add(currentLabel);
                        }
                      }

                      // Update the table document
                      transaction
                          .update(tableDocRef, {'tableLables': updatedLabels});

                      // Assuming you have a method to add the reservation in your controller
                      await ticketconcertcontroller
                          .addReserveTicket(newReservation);
                    },
                  );

                  // Show success message before navigation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Reservation successful',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Clear the booking ticket after successful reservation
                  provider.clearBookingTable();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/home');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to reserve ticket: $e',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
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
