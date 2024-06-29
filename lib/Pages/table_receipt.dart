import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:losser_bar/Pages/controllers/pdf_table_gen.dart';
import 'package:losser_bar/Pages/controllers/reserve_table_controller.dart';
import 'package:losser_bar/Pages/services/reserve_table_service.dart';
import 'package:provider/provider.dart';

class TableReceiptPage extends StatefulWidget {
  @override
  State<TableReceiptPage> createState() => _TableReceiptPageState();
}

class _TableReceiptPageState extends State<TableReceiptPage> {
  late ReserveTableHistoryController reservetablehistorycontroller =
      ReserveTableHistoryController(ReserveTableFirebaseService());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    reservetablehistorycontroller =
        ReserveTableHistoryController(ReserveTableFirebaseService());
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => isLoading = true);
    try {
      final userId =
          FirebaseAuth.instance.currentUser?.uid; // Get current user's ID
      if (userId == null) throw Exception('User not logged in');

      // Fetch all reservations created by the user
      List<ReserveTableHistory> fetchedReservations =
          await reservetablehistorycontroller.fetchReserveTableHistory();

      // Update the provider with all reservations
      Provider.of<ReserveTableProvider>(context, listen: false).setReserveTable(
          fetchedReservations
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
    final reserveTableProvider = Provider.of<ReserveTableProvider>(context);
    List<ReserveTableHistory>? reservations =
        reserveTableProvider.allReserveTable;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: const Text('Table Booking History'),
      ),
      body: reservations == null || reservations.isEmpty
          ? const Center(child: Text('No Order History'))
          : ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final tables = reservations[index];
                // Format the billingTime using DateFormat
                final formattedSelectDate = DateFormat('yyyy-MM-dd')
                    .format(tables.formattedSelectedDay);
                return InkWell(
                  child: Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.receipt_long, color: Colors.black),
                      title: Text(
                        'Booking Date: $formattedSelectDate',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Selected Table: ${tables.selectedTableLabel}\nTotal Price: ${tables.totalPrices.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                TableDetailPage(table: tables),
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

class TableDetailPage extends StatelessWidget {
  final ReserveTableHistory table;

  TableDetailPage({Key? key, required this.table}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedPaymentTime =
        DateFormat('yyyy-MM-dd – kk:mm').format(table.paymentTime);

    String formattedBookingDate =
        DateFormat('yyyy-MM-dd').format(table.formattedSelectedDay);

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
              Text('Concert: ${table.selectedTableLabel}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Payment Time: $formattedPaymentTime',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Booking Date: $formattedBookingDate',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Total Price: ${table.totalPrices.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final pdfGenerator = PdfTableGenerator(table);
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
