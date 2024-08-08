import 'package:flutter/material.dart';

class AllQRCodePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('All QR Code'),
        foregroundColor: Theme.of(context).colorScheme.surface,
        titleTextStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       //Move between page
        //       Navigator.pushNamed(context, '/profile');
        //     },
        //     icon: const Icon(Icons.account_circle_sharp),
        //     iconSize: 40,
        //     color: Theme.of(context).colorScheme.onSurface,
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              _buildGridMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridMenu() {
    // List of menu items, each with an icon and label
    List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.receipt_long_outlined,
        'label': 'QR Ticket concert',
        'route': '/qrticket',
      },
      {
        'icon': Icons.receipt_long_outlined,
        'label': 'QR Table',
        'route': '/qrtable',
      },
    ];

    return GridView.builder(
      itemCount: menuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                const SizedBox(height: 8), // Spacing between icon and label
                Text(
                  item['label'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[100],
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      // Prevents the GridView from scrolling, use it inside a SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(),
      // Set a fixed height to avoid runtime errors, calculate based on your content
      shrinkWrap: true,
    );
  }
}
