import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/reserve_ticket_model.dart';
import 'package:losser_bar/Pages/controllers/reserve_ticket_controller.dart';
import 'package:losser_bar/Pages/reserve_ticket_page.dart';
import 'package:losser_bar/Pages/services/reserve_ticket_service.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late TicketConcertController ticketconcertcontroller =
      TicketConcertController(TicketConcertFirebaseService());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    ticketconcertcontroller =
        TicketConcertController(TicketConcertFirebaseService());
    _loadTicketCatalogs();
  }

  Future<void> _loadTicketCatalogs() async {
    setState(() => isLoading = true); // Ensure loading state is true
    try {
      var tickets = await ticketconcertcontroller.fetchTicketConcertModel();
      Provider.of<ReserveTicketProvider>(context, listen: false)
          .setReserveTicket(
              tickets); // Adjust this based on your actual implementation
    } catch (e) {
      print('Error fetching TicketCatalog: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var detailproductModel = Provider.of<ReserveTicketProvider>(context);
    var ticketconcert = detailproductModel.allTicketConcert;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('Losser Bar  '),
        foregroundColor: Theme.of(context).colorScheme.surface,
        titleTextStyle: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.surface),
        actions: [
          IconButton(
            onPressed: () {
              //Move between page
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.account_circle_sharp),
            iconSize: 40,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                      height: 420, child: _buildTicketListView(ticketconcert)),
                  _buildGridMenu(),
                ],
              ),
            ),
    );
  }

  Widget _buildTicketListView(List<TicketConcertModel> ticketConcert) {
    return ListView.builder(
      itemCount: ticketConcert.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final ticket = ticketConcert[index];
        // Assuming ticket.eventDate is a DateTime object, format it to a readable string
        final String formattedDate =
            DateFormat('dd MMM yyyy').format(ticket.eventDate);

        // Check if the concert is sold out
        bool isSoldOut = ticket.numberOfTickets == 0;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: isSoldOut
              ? _buildSoldOutWidget(ticket)
              : InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReserveTicketPage(
                          eventName: ticket.eventName,
                          eventDate: ticket
                              .eventDate, // You might need to adjust the formatting
                          eventImage: ticket.imageEvent,
                          ticketPrice: ticket.ticketPrice,
                          ticketId: ticket.id,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 200, // Set a fixed width for each item
                    margin: EdgeInsets.only(right: 11),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(ticket.imageEvent,
                              fit: BoxFit.cover, width: 200, height: 350),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[600]!.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              formattedDate,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[100]!.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              ticket.eventName,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSoldOutWidget(TicketConcertModel ticket) {
    // Assuming ticket.eventDate is a DateTime object, format it to a readable string
    final String formattedDate =
        DateFormat('dd MMM yyyy').format(ticket.eventDate);

    return Container(
      width: 200, // Maintain the same width for consistency
      height: 350, // Optional: Adjust height as needed
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(ticket.imageEvent),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Semi-transparent overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // Text and details
          Align(
            alignment: Alignment.center,
            child: Text(
              'Tickets Sold Out',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Positioned date and event name at the top left corner
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueGrey[600]!.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                formattedDate,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueGrey[100]!.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ticket.eventName,
                style: TextStyle(color: Colors.black, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildTicketListView(List<TicketConcertModel> ticketConcert) {
  //   return ListView.builder(
  //     itemCount: ticketConcert.length,
  //     scrollDirection: Axis.horizontal,
  //     itemBuilder: (context, index) {
  //       final ticket = ticketConcert[index];
  //       // Assuming ticket.eventDate is a DateTime object, format it to a readable string
  //       final String formattedDate =
  //           DateFormat('dd MMM yyyy').format(ticket.eventDate);

  //       return Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: InkWell(
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => ReserveTicketPage(
  //                   eventName: ticket.eventName,
  //                   eventDate: ticket
  //                       .eventDate, // You might need to adjust the formatting
  //                   eventImage: ticket.imageEvent,
  //                   ticketPrice: ticket.ticketPrice,
  //                   ticketId: ticket.id,
  //                 ),
  //               ),
  //             );
  //           },
  //           child: Container(
  //             width: 200,
  //             // Set a fixed width for each item
  //             margin: EdgeInsets.only(right: 11),
  //             child: Stack(
  //               children: [
  //                 ClipRRect(
  //                   borderRadius: BorderRadius.circular(20),
  //                   child: Image.network(ticket.imageEvent,
  //                       fit: BoxFit.cover, width: 200, height: 350),
  //                 ),
  //                 Positioned(
  //                   top: 10,
  //                   left: 10,
  //                   child: Container(
  //                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                     decoration: BoxDecoration(
  //                       color: Colors.blueGrey[600]!.withOpacity(0.8),
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                     child: Text(
  //                       formattedDate,
  //                       style: TextStyle(color: Colors.white),
  //                     ),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   bottom: 10,
  //                   left: 10,
  //                   right: 10,
  //                   child: Container(
  //                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                     decoration: BoxDecoration(
  //                       color: Colors.blueGrey[100]!.withOpacity(0.8),
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                     child: Text(
  //                       ticket.eventName,
  //                       style: TextStyle(color: Colors.black, fontSize: 16),
  //                       textAlign: TextAlign.center,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildGridMenu() {
    // List of menu items, each with an icon and label
    List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.table_restaurant,
        'label': 'Reserve Table',
        'route': '/1', // Example route, adjust as necessary
      },
      {
        'icon': Icons.fastfood,
        'label': 'Food and Beverage',
        'route': '/3',
      },
      {
        'icon': Icons.account_box_rounded,
        'label': 'Your IG',
        'route': '/5',
      },
      {
        'icon': Icons.cleaning_services,
        'label': 'Mate Cafe',
        'route': '/7',
      },
      {
        'icon': Icons.receipt_long_outlined,
        'label': 'Order Receipt',
        'route': '/allreceipt',
      },
      // Add more items as needed
    ];

    return GridView.builder(
      itemCount: menuItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        crossAxisSpacing: 10, // Horizontal space between items
        mainAxisSpacing: 10, // Vertical space between items
      ),
      itemBuilder: (context, index) {
        var item = menuItems[index];
        return InkWell(
          onTap: () {
            // Navigate to the route associated with the grid item
            Navigator.pushNamed(context, item['route']);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item['icon'],
                  color: Colors.grey,
                  size: 40,
                ),
                SizedBox(height: 8), // Spacing between icon and label
                Text(
                  item['label'],
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
      // Prevents the GridView from scrolling, use it inside a SingleChildScrollView
      physics: NeverScrollableScrollPhysics(),
      // Set a fixed height to avoid runtime errors, calculate based on your content
      shrinkWrap: true,
    );
  }
}
