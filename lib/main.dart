import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/test_dropdown.dart';
import 'package:losser_bar/Pages/cart_page.dart';
import 'package:losser_bar/Pages/matecafe_page.dart';
import 'package:losser_bar/Pages/Profile.dart';
import 'package:losser_bar/Pages/home_page.dart';
import 'package:losser_bar/Pages/login.dart';
import 'package:provider/provider.dart';
import 'Pages/donation_page.dart';
import 'Pages/product_model_page.dart';
import 'Pages/order_food_page.dart';
import 'Pages/request_song_page.dart';
import 'Pages/reserve_table_page.dart';
import 'Pages/reserve_ticket_page.dart';
import 'Pages/shown_your_profile_page.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => ProductModel(),
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Losser bar app',
      theme: ThemeData(
          colorScheme: ColorScheme(
              brightness: Brightness.light,
              primary: Colors.blueGrey[700]!,
              onPrimary: Colors.blueGrey[900]!,
              secondary: Color(0xFF0077ED),
              onSecondary: Colors.teal[800]!,
              error: Color(0xFFF32424),
              onError: Color.fromARGB(255, 231, 100, 13),
              background: Color.fromARGB(255, 255, 255, 255),
              onBackground: Color(0xFF000000),
              surface: Color(0xFFFFFFFF),
              onSurface: Colors.grey[300]!),
          textTheme: TextTheme(
              bodyMedium: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              bodySmall: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.normal)),
          useMaterial3: true),

      //register sub class
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginPage(),
        '/profile': (context) => ProfilePage(),
        '/home': (context) => Homepage(),
        '/1': (context) => ReserveTablePage(),
        '/2': (context) => ReserveTicketPage(),
        '/3': (context) => OrderFoodPage(),
        '/4': (context) => RequestSongPage(),
        '/5': (context) => ShownProfilePage(),
        '/6': (context) => DonationPage(),
        '/7': (context) => MateCafePage(),
        '/cart': (context) => CartPage(),
        // '/test': (context) => MyForm(),
      },
    );
  }
}
