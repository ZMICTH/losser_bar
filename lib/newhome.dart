import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/provider/partner_model.dart';
import 'package:provider/provider.dart';

class NewHomePage extends StatefulWidget {
  @override
  _NewHomePageState createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  // Method to refresh the page
  // void _refreshPage() {
  //   setState(() {
  //     // Add your refresh logic here. This example simply triggers a rebuild.
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('Home page'),
        foregroundColor: Theme.of(context).colorScheme.surface,
        titleTextStyle: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.surface),
        actions: [
          IconButton(
            onPressed: () {
              // Move between page
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.account_circle_sharp),
            iconSize: 40,
            color: Theme.of(context).colorScheme.background,
          ),
        ],
      ),
      body: _buildGridMenu(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _refreshPage,
      //   child: Icon(Icons.refresh),
      // ),
    );
  }

  Widget _buildGridMenu() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('partner')
          .where('role', isEqualTo: 'partner')
          .where('userStatus', isEqualTo: "active")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available'));
        }

        var partners = snapshot.data!.docs;
        // Print each document's data
        for (var partner in partners) {
          print(partner.data());
        }

        return GridView.builder(
          padding: EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // Number of columns
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 3 / 2, // Adjust this ratio to control card height
          ),
          itemCount: partners.length,
          itemBuilder: (context, index) {
            var partner = partners[index];
            var partnerData = partner.data() as Map<String, dynamic>;
            return Card(
              color: Colors.blueGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                onTap: () {
                  Provider.of<SelectedPartnerProvider>(context, listen: false)
                      .selectPartner(partner.id, partnerData['partnerName']);
                  Navigator.pushNamed(context, '/home');
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Image.asset(
                            'images/sim.png',
                            width: 100,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  partner['partnerName'],
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                // Text(
                                //   partner['partnerName'],
                                //   style: TextStyle(
                                //     fontSize: 16,
                                //     fontWeight: FontWeight.bold,
                                //     color: Colors.white,
                                //   ),
                                //   textAlign: TextAlign.center,
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
