import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:losser_bar/Pages/controllers/reserve_table_controller.dart';
import 'package:losser_bar/Pages/services/reserve_table_service.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ReserveTablePage extends StatefulWidget {
  @override
  _ReserveTablePageState createState() => _ReserveTablePageState();
}

class _ReserveTablePageState extends State<ReserveTablePage> {
  late ReserveTableHistoryController reservetablehistorycontroller =
      ReserveTableHistoryController(ReserveTableFirebaseService());
  bool isLoading = true;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<String> tableLabels = ['VIP', 'ZoneA', 'ZoneB'];
  final List<int> tablePrices = [2000, 1400, 600];
  Map<String, int> tablePricesMap = {};
  int? selectedTablePrice;
  String selectedTableLabel = 'VIP';
  String userId = '';
  bool checkIn = false;

  @override
  void initState() {
    super.initState();
    reservetablehistorycontroller =
        ReserveTableHistoryController(ReserveTableFirebaseService());
    tablePricesMap = Map.fromIterables(tableLabels, tablePrices);
    selectedTablePrice = tablePricesMap[tableLabels.first];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text('สำรองโต๊ะ'),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TableCalendar(
              calendarStyle: CalendarStyle(
                selectedTextStyle: const TextStyle(fontSize: 16),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurple[800],
                  shape: BoxShape.circle,
                ),
                todayTextStyle:
                    const TextStyle(color: Colors.black, fontSize: 16),
                todayDecoration: BoxDecoration(
                  color: Colors.deepPurple[300],
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                weekendStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (selectedDay.isBefore(DateTime.now())) {
                  // Optionally, you can show a message to the user that past dates cannot be selected.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                      'Past dates cannot be selected.',
                      style: TextStyle(color: Colors.black),
                    )),
                  );
                  return; // Exit the callback if the selected day is in the past.
                }

                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` here as well
                });
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Please select type of Table",
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      3, // Set to 3 or any other number that fits your design
                  childAspectRatio:
                      3 / 1, // Adjust the aspect ratio to control the size
                ),
                itemCount: tableLabels.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedTableLabel == tableLabels[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedTableLabel = tableLabels[index];
                        selectedTablePrice = tablePricesMap[selectedTableLabel];
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      margin: EdgeInsets.all(4),
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
                          tableLabels[index],
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
              ),
            ),
            SizedBox(height: 10),

            SizedBox(height: 10),
            // GridView.builder and other UI elements...
            if (selectedTablePrice != null)
              Text('Price: THB ${selectedTablePrice.toString()}',
                  style: TextStyle(color: Colors.black)),
            ElevatedButton(
              onPressed: _confirmReserving,
              child: Text("Confirm Reserving"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReserving() async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select a day before reserving.',
                style: TextStyle(color: Colors.black))),
      );
      return; // Exit the function if no day is selected
    }

    final userId =
        Provider.of<MemberUserModel>(context, listen: false).memberUser?.id ??
            'defaultUserId';
    final userNickName = Provider.of<MemberUserModel>(context, listen: false)
            .memberUser
            ?.nicknameUser ??
        'defaultNickname';

    final newReservation = ReserveTable(
      selectedTableLabel: selectedTableLabel,
      selectedTablePrice: selectedTablePrice ?? 0,
      formattedSelectedDay: _selectedDay!,
      // Assuming formattedSelectedDay is a String
      userId: userId,
      nicknameUser: userNickName,
      checkIn: checkIn,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[600],
          title: Text('Confirm Reserving',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please confirm your reservation'),
              SizedBox(height: 20),
              Image.asset('images/promtpay.jpeg'),
            ],
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
                  // Use the controller to add the reservation
                  await reservetablehistorycontroller
                      .addReserveTable(newReservation);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reservation successful'),
                    ),
                  );
                  // ignore: use_build_context_synchronously
                  Provider.of<ReserveTableProvider>(context, listen: false)
                      .clearbookingtable();
                  // Close the dialog and return to the previous screen with bookingDetails and QR payment image path
                  Navigator.pop(context); // Close the dialog
                  Navigator.of(context).pushReplacementNamed('/home');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to reserve table: $e')));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
