import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:losser_bar/Pages/controllers/reserve_table_controller.dart';
import 'package:losser_bar/Pages/services/reserve_table_service.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';
import 'package:provider/provider.dart';

class ReserveTablePage extends StatefulWidget {
  @override
  _ReserveTablePageState createState() => _ReserveTablePageState();
}

class _ReserveTablePageState extends State<ReserveTablePage> {
  late ReserveTableHistoryController reservetablehistorycontroller =
      ReserveTableHistoryController(ReserveTableFirebaseService());
  bool isLoading = true;

  DateTime? selectedDay;
  Map<String, int> tablePricesMap = {};

  String userId = '';
  bool checkIn = false;
  int? quantityTable;
  String? selectedTableId;
  String? selectedTableLabel;
  double? selectedTablePrice;
  int seatQuantity = 1;
  List<TableCatalog> tableCatalogs = [];
  int? selectedTableSeat;
  double? totalPrices;

  @override
  void initState() {
    super.initState();
    reservetablehistorycontroller =
        ReserveTableHistoryController(ReserveTableFirebaseService());
    _loadTableCatalog();
  }

  void _loadTableCatalog() async {
    try {
      // Fetch tables from Firebase
      tableCatalogs = await reservetablehistorycontroller.fetchTableCatalog();
      // Set the fetched tables into the provider
      Provider.of<ReserveTableProvider>(context, listen: false)
          .setTables(tableCatalogs);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading data: $e');
    }
  }

  void updateTotalPrice() {
    if (selectedTablePrice != null) {
      totalPrices = selectedTablePrice! * seatQuantity;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    int quantity = Provider.of<ReserveTableProvider>(context).seatQuantity;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text('Reserve Table'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/qrtable');
            },
            icon: Icon(Icons.add_alert),
            color: Theme.of(context).colorScheme.surface,
          ),
        ],
      ),
      body: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            const SizedBox(
              width: 10,
            ),
            const Text(
              'Today',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: DatePicker(
                DateTime.now(),
                height: 100,
                width: 80,
                dayTextStyle: TextStyle(fontSize: 16),
                initialSelectedDate: DateTime.now(),
                selectionColor: Colors.blueGrey,
                selectedTextColor: Colors.white,
                inactiveDates:
                    Provider.of<ReserveTableProvider>(context, listen: true)
                        .inactiveDates,
                onDateChange: (date) {
                  selectedDay =
                      Provider.of<ReserveTableProvider>(context, listen: false)
                          .selectedDate = date;
                  print(date);
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Consumer<ReserveTableProvider>(
                builder: (context, provider, child) {
                  List<Map<String, dynamic>> allLabels = [];
                  provider.tables.forEach((table) {
                    table.tableLables.forEach((label) {
                      // Include the table ID with each label for identification
                      var newLabel = Map<String, dynamic>.from(label);
                      newLabel['id'] = table.id;
                      allLabels.add(newLabel);
                    });
                  });

                  // Fetch the currently selected table ID from the provider
                  String? currentSelectedLabel = selectedTableLabel;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2,
                    ),
                    // Use this if inside another scrollable
                    shrinkWrap: true,
                    // Use this to handle physics when nested
                    physics: ClampingScrollPhysics(),

                    itemCount: allLabels.length,
                    itemBuilder: (context, index) {
                      final labelMap = allLabels[index];
                      // bool isSelected = selectedTableLabel == labelMap['label'];
                      bool isSelected =
                          currentSelectedLabel == labelMap['label'];
                      bool isAvailable = labelMap['totaloftable'] >
                          0; // Check if the table is available

                      return InkWell(
                        onTap: isAvailable
                            ? () {
                                setState(
                                  () {
                                    selectedTableLabel = labelMap['label'];
                                    selectedTablePrice =
                                        labelMap['tablePrices']?.toDouble();
                                    selectedTableId = labelMap['id'];
                                    quantityTable = provider.quantityTable = 1;

                                    var selectedTable =
                                        provider.tables.firstWhere(
                                      (table) => table.id == labelMap['id'],
                                    );
                                    provider.selectedTable = selectedTable;
                                    provider.setSelectedTableSeat(
                                        labelMap['seats']);
                                  },
                                );

                                print('Selected ID: ${labelMap['id']}');
                                print('Selected Label: ${labelMap['label']}');
                                print('Selected Price: $selectedTablePrice');
                                print(
                                    'Selected Seats: ${provider.selectedTableSeat}');
                                print(
                                    'Quantity Table: ${provider.quantityTable}');
                              }
                            : null, // Disable tap if the table is not available
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.blueGrey : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isAvailable
                                ? (isSelected
                                    ? Colors.blueGrey.withOpacity(0.7)
                                    : Colors.transparent)
                                : Colors.red[300],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('${labelMap['label']}'),
                              Text('Price: ${labelMap['tablePrices']} THB'),
                              Text(
                                  'Available Tables: ${labelMap['totaloftable']}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            if (selectedTableLabel != null &&
                Provider.of<ReserveTableProvider>(context).seatQuantity > 0 &&
                selectedTablePrice != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Please select the number of seats.",
                    style: TextStyle(color: Colors.black),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.black, size: 30),
                        onPressed: Provider.of<ReserveTableProvider>(context)
                                    .seatQuantity >
                                1
                            ? () {
                                Provider.of<ReserveTableProvider>(context,
                                        listen: false)
                                    .decrementSeatQuantity();
                                setState(() {});
                              }
                            : null,
                      ),
                      Text(
                        "${Provider.of<ReserveTableProvider>(context).seatQuantity}",
                        style: TextStyle(color: Colors.black, fontSize: 25),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.black, size: 30),
                        onPressed: Provider.of<ReserveTableProvider>(context)
                                    .seatQuantity <
                                Provider.of<ReserveTableProvider>(context)
                                    .maxSeats
                            ? () {
                                Provider.of<ReserveTableProvider>(context,
                                        listen: false)
                                    .incrementSeatQuantity();
                                setState(() {});
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Price: THB ${(selectedTablePrice! * quantity).toStringAsFixed(2)}',
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _confirmReserving,
                child: Text("Confirm Reserving"),
              ),
            ],
          ],
        );
      }),
    );
  }

  void _confirmReserving() async {
    final reserveProvider =
        Provider.of<ReserveTableProvider>(context, listen: false);
    final selectedTableId = reserveProvider.selectedTableId;

    if (selectedDay == null ||
        selectedTableId == null ||
        selectedTableLabel == null ||
        selectedTablePrice == null) {
      print(selectedDay);
      print(quantityTable);
      print(selectedTableId);
      print(selectedTableLabel);
      print(selectedTablePrice);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a day and a table before reserving.',
              style: TextStyle(color: Colors.red)),
        ),
      );
      return; // Exit the function if no day or table is selected
    }

    final seatQuantity = reserveProvider.seatQuantity;
    final totalPrices = selectedTablePrice! * seatQuantity;

    final userId =
        Provider.of<MemberUserModel>(context, listen: false).memberUser?.id ??
            'defaultUserId';
    final userNickName = Provider.of<MemberUserModel>(context, listen: false)
            .memberUser
            ?.nicknameUser ??
        'defaultNickname';
    final phoneNumber = Provider.of<MemberUserModel>(context, listen: false)
        .memberUser!
        .phoneUser;

    String formatSelectedDay =
        DateFormat('dd/MM/yyyy 20:00:00 a').format(selectedDay!);

    final newReservation = ReserveTable(
      selectedTableId: selectedTableId,
      quantityTable: quantityTable!,
      selectedTableLabel: selectedTableLabel!,
      totalPrices: totalPrices,
      formattedSelectedDay: selectedDay!,
      userId: userId,
      nicknameUser: userNickName,
      checkIn: checkIn,
      selectedSeats: seatQuantity,
      userPhone: phoneNumber,
      payable: true,
      paymentTime: DateTime.now(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[600]!,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          title: Text('Confirm Reserving'),
          content: QRCodeGenerate(
            promptPayId: "0987487348",
            amount: totalPrices,
            isShowAmountDetail: true,
            promptPayDetailCustom: Text("สิทธิวิชญ์ พิสิฐภูวโภคิน"),
            amountDetailCustom: Text('${totalPrices} THB'),
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
                  // Start a Firestore transaction
                  FirebaseFirestore.instance.runTransaction(
                    (Transaction transaction) async {
                      DocumentReference tableRef = FirebaseFirestore.instance
                          .collection('table_catalog')
                          .doc(selectedTableId);

                      DocumentSnapshot snapshot =
                          await transaction.get(tableRef);
                      if (!snapshot.exists) {
                        throw Exception('Table data not available');
                      }

                      Map<String, dynamic> data =
                          snapshot.data() as Map<String, dynamic>;
                      List<dynamic> tableLables = data['tableLables'];
                      List<Map<String, dynamic>> updatedLabels = [];
                      for (var label in tableLables) {
                        Map<String, dynamic> currentLabel =
                            Map<String, dynamic>.from(label);

                        if (currentLabel['label'] == selectedTableLabel) {
                          int newTotalOfTable =
                              (currentLabel['totaloftable'] as int) - 1;
                          int newNumberOfChairs =
                              (currentLabel['numberofchairs'] as int) -
                                  seatQuantity;

                          updatedLabels.add({
                            'label': currentLabel['label'],
                            'numberofchairs': newNumberOfChairs,
                            'seats': currentLabel['seats'],
                            'tablePrices': currentLabel['tablePrices'],
                            'totaloftable': newTotalOfTable,
                          });
                        } else {
                          updatedLabels.add(currentLabel);
                        }
                      }

                      transaction
                          .update(tableRef, {'tableLables': updatedLabels});

                      // Use the controller to add the reservation
                      await reservetablehistorycontroller
                          .addReserveTable(newReservation);
                    },
                  );

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Reservation successful'),
                    backgroundColor: Colors.green,
                  ));

                  // ignore: use_build_context_synchronously
                  Provider.of<ReserveTableProvider>(context, listen: false)
                      .clearbookingtable();

                  Navigator.pop(context); // Close the dialog
                  Navigator.of(context).pushReplacementNamed('/home');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to reserve table: $e'),
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
