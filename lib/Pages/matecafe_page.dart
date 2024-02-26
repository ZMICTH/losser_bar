import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/Model/mate_model.dart';
import 'package:losser_bar/Pages/controllers/mate_controller.dart';
import 'package:losser_bar/Pages/services/mate_service.dart';
import 'package:provider/provider.dart';

class MateCafePage extends StatefulWidget {
  @override
  State<MateCafePage> createState() => _MateCafePageState();
}

class _MateCafePageState extends State<MateCafePage> {
  late MateCatalogController matecatalogcontroller =
      MateCatalogController(MateCatalogFirebaseService());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    matecatalogcontroller = MateCatalogController(MateCatalogFirebaseService());
    _loadMateCatalogs();
  }

  Future<void> _loadMateCatalogs() async {
    setState(() => isLoading = true); // Ensure loading state is true
    try {
      var mateCatalogs = await matecatalogcontroller.fetchMateCatalog();
      Provider.of<MateCafeModel>(context, listen: false)
          .setMateCatalogs(mateCatalogs); // Use the correct method name here
    } catch (e) {
      print('Error fetching MateCatalog: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var detailproductModel = Provider.of<MateCafeModel>(context);
    var matescafe = detailproductModel.matescafe;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: const Text('Mates Cafe'),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text('Hello....')),
        //       );
        //     },
        //     icon: const Icon(Icons.add_alert),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: matescafe
                  .length, // Make sure matescafe is a List<MateCatalog>
              itemBuilder: (context, index) {
                final matecafe =
                    matescafe[index]; // Ensure matescafe is List<MateCatalog>
                return InkWell(
                  onTap: () => _navigateAndDisplayBooking(context, matecafe),
                  child: buildMateCard(context, matecafe),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateAndDisplayBooking(BuildContext context, MateCatalog matecafe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(
            mate: matecafe,
            mateCatalogController: matecatalogcontroller), // Modify this line
      ),
    ).then((result) {
      if (result != null) {
        Map<String, dynamic> bookingDetails = result['bookingDetails'];
        _showBookingConfirmation(context, bookingDetails);
      }
    });
  }

  Widget buildMateCard(BuildContext context, MateCatalog matecafe) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(
                  matecafe.mateimagePath,
                  width: 180,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 10),
                Expanded(child: buildMateDetails(context, matecafe)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMateDetails(BuildContext context, MateCatalog matecafe) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Name: " + matecafe.nameMate + " (${matecafe.genderMate})",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onBackground),
        ),
        SizedBox(height: 4),
        Text(
          "Description: " + matecafe.description,
          style: TextStyle(
              fontSize: 14, color: Theme.of(context).colorScheme.onBackground),
        ),
        SizedBox(height: 4),
        Text(
          "Age: " + matecafe.ageMate,
          style: TextStyle(
              fontSize: 14, color: Theme.of(context).colorScheme.onBackground),
        ),
        SizedBox(height: 4),
        Text(
          "Shape: " + matecafe.shapeMate,
          style: TextStyle(
              fontSize: 14, color: Theme.of(context).colorScheme.onBackground),
        ),
        SizedBox(height: 4),
        Text(
          "Weight: " + matecafe.weightMate + " kg",
          style: TextStyle(
              fontSize: 14, color: Theme.of(context).colorScheme.onBackground),
        ),
        SizedBox(height: 4),
        Text(
          "Height: " + matecafe.heightMate + " cm",
          style: TextStyle(
              fontSize: 14, color: Theme.of(context).colorScheme.onBackground),
        ),
        SizedBox(height: 4),
        Text(
          "Price: " + "${matecafe.pricePerHour}" + ' per ' + 'Hour',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onBackground),
        ),
      ],
    );
  }

  void _showBookingConfirmation(
      BuildContext context, Map<String, dynamic> bookingDetails) {
    // Display a confirmation dialog or navigate to a new screen
    // Include the booking details and the QR payment image
  }
}

class BookingScreen extends StatefulWidget {
  final MateCatalog mate;
  final MateCatalogController mateCatalogController; // Add this line

  BookingScreen(
      {Key? key, required this.mate, required this.mateCatalogController})
      : super(key: key); // Modify this line

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Default booking duration
  String userId = '';
  final List<String> timeSlots = [
    '6:00 PM - 7:00 PM',
    '7:00 PM - 8:00 PM',
    '8:00 PM - 9:00 PM',
    '9:00 PM - 10:00 PM',
    '10:00 PM - 11:00 PM',
  ];

  Set<String> selectedTimeSlots = Set();

  int getTotalPrice() {
    int pricePerHour =
        widget.mate.pricePerHour; // Ensure this is price per hour
    int numberOfHours = selectedTimeSlots.length; // Number of selected slots
    return pricePerHour * numberOfHours;
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = getTotalPrice();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text(widget.mate.nameMate),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 8,
              ),
              Container(
                height: 400,
                width: 300,
                child: Image.network(
                  widget.mate.mateimagePath,
                  width: 200,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                widget.mate.nameMate,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              Text(
                widget.mate.description,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                        3 / 1, // Adjust the aspect ratio to control the size
                  ),
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    bool isSelected =
                        selectedTimeSlots.contains(timeSlots[index]);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedTimeSlots.remove(timeSlots[index]);
                          } else {
                            selectedTimeSlots.add(timeSlots[index]);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4), // Reduced padding
                        margin: EdgeInsets.all(
                            4), // Margin to space out the containers
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: isSelected
                                  ? Colors.blueGrey[700]!
                                  : Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected
                              ? Colors.blueGrey[700]!.withOpacity(0.3)
                              : Colors
                                  .transparent, // Background color to highlight selection
                        ),
                        child: Center(
                          child: Text(
                            timeSlots[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.blueGrey[700]!
                                  : Colors.black,
                              fontSize: 14, // Reduced font size
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  shrinkWrap: true,
                ),
              ),
              // SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'Total Price: $totalPrice',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _confirmBooking,
                child: const Text("Confirm Booking"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmBooking() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[600]!,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          title: Text('Confirm Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please confirm your booking'),
              SizedBox(height: 20),
              Image.asset('images/promtpay.jpeg'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Success',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                try {
                  // Create a map with the necessary booking details
                  Map<String, dynamic> bookingDetails = {
                    'id': widget.mate.id,
                    'name': widget.mate.nameMate,
                    'totalprice': getTotalPrice(),
                    'hoursbooking': selectedTimeSlots.length,
                    'selectedTimeSlots': selectedTimeSlots.toList(),
                  };

                  final userId =
                      Provider.of<MemberUserModel>(context, listen: false)
                              .memberUser
                              ?.id ??
                          'defaultUserId';
                  final userNickName =
                      Provider.of<MemberUserModel>(context, listen: false)
                              .memberUser
                              ?.nicknameUser ??
                          'defaultNickname';

                  final bookingMateHistory = BillBookingMate(
                    tableNo: "1",
                    bookingMate: bookingDetails,
                    userId: userId,
                    nicknameUser: userNickName,
                    billingtime: DateTime.now(),
                  );

                  await widget.mateCatalogController
                      .addBookingMate(bookingMateHistory);
                  print("Upload successful");

                  // Include the QR payment image path
                  print(bookingDetails);
                  Provider.of<MateCafeModel>(context, listen: false)
                      .clearbookingmate();
                  // Close the dialog and return to the previous screen with bookingDetails and QR payment image path
                  Navigator.pop(context); // Close the dialog
                  Navigator.of(context).pushReplacementNamed('/home');
                } catch (e, d) {
                  // Handle error
                  print(d);
                  print('Error occurred: qr code $e');
                  // Optionally, show a snackbar or dialog with the error message
                }
              },
            ),
          ],
        );
      },
    );
  }
}
