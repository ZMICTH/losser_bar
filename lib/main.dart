import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/Model/mate_model.dart';
import 'package:losser_bar/Pages/Model/payorder_model.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:losser_bar/Pages/provider/product_model_page.dart';
import 'package:losser_bar/Pages/all_receipt_page.dart';

import 'package:losser_bar/Pages/cart_page.dart';
import 'package:losser_bar/Pages/food_and_beverage_screen.dart';

import 'package:losser_bar/Pages/Profile.dart';
import 'package:losser_bar/Pages/home_page.dart';
import 'package:losser_bar/Pages/loginscreen.dart';
import 'package:losser_bar/Pages/matecafe_page.dart';

import 'package:losser_bar/Pages/payment_page.dart';
import 'package:losser_bar/Pages/qr_reserve_table.dart';

import 'package:losser_bar/Pages/receipt_order_page.dart';
import 'package:losser_bar/firebase_options.dart';
import 'package:provider/provider.dart';
import 'Pages/donation_page.dart';
import 'Pages/request_song_page.dart';
import 'Pages/reserve_table_page.dart';
import 'Pages/reserve_ticket_page.dart';
import 'Pages/shown_your_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => ProductModel(),
      ),
      ChangeNotifierProvider(
        create: (context) => MemberUserModel(),
      ),
      ChangeNotifierProvider(
        create: (context) => MateCafeModel(),
      ),
      ChangeNotifierProvider(
        create: (context) => OrderHistoryProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => ReserveTableProvider(),
      ),
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
              background: Color.fromARGB(255, 231, 230, 230),
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
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfilePage(),
        '/home': (context) => Homepage(),
        '/1': (context) => ReserveTablePage(),
        '/2': (context) => ReserveTicketPage(),
        '/3': (context) => FoodandBeverageScreen(),
        '/4': (context) => RequestSongPage(),
        '/5': (context) => ShownProfilePage(),
        '/6': (context) => DonationPage(),
        '/7': (context) => MateCafePage(),
        '/cart': (context) => CartPage(),
        '/allreceipt': (context) => AllReceiptPage(),
        '/orderreceipt': (context) => ReceiptOrderPage(),
        '/payment': (context) => PaymentScreen(),
        '/qrtable': (context) => QrReservations(),
      },
    );
  }
}
