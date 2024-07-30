import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/bill_order_model.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/Model/mate_model.dart';
import 'package:losser_bar/Pages/Model/payorder_model.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:losser_bar/Pages/Model/reserve_ticket_model.dart';
import 'package:losser_bar/Pages/all_qr.dart';
import 'package:losser_bar/Pages/all_receipt.dart';
import 'package:losser_bar/Pages/controllers/cart_if_eventdate.dart';
import 'package:losser_bar/Pages/provider/partner_model.dart';
import 'package:losser_bar/Pages/table_receipt.dart';
import 'package:losser_bar/Pages/ticket_receipt.dart';
import 'package:losser_bar/Pages/provider/product_model_page.dart';
import 'package:losser_bar/Pages/Order_receipt.dart';
import 'package:losser_bar/Pages/cart_page.dart';
import 'package:losser_bar/Pages/food_and_beverage_screen.dart';
import 'package:losser_bar/Pages/Profile.dart';
import 'package:losser_bar/Pages/home_page.dart';
import 'package:losser_bar/Pages/loginscreen.dart';
import 'package:losser_bar/Pages/matecafe_page.dart';
import 'package:losser_bar/Pages/payment_page.dart';
import 'package:losser_bar/Pages/qr_reserve_table.dart';
import 'package:losser_bar/Pages/qr_reserve_ticket.dart';

import 'package:losser_bar/firebase_options.dart';
import 'package:losser_bar/newhome.dart';
import 'package:provider/provider.dart';
import 'Pages/donation_page.dart';
import 'Pages/request_song_page.dart';
import 'Pages/reserve_table_page.dart';
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
      ChangeNotifierProvider(
        create: (context) => TicketcatalogProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => ReservationTicketProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => BillOrderProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => SelectedPartnerProvider(),
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme(
              brightness: Brightness.light,
              primary: Color(0xFF455A64)!,
              onPrimary: Colors.blueGrey[900]!,
              secondary: const Color(0xFF0077ED),
              onSecondary: Colors.teal[800]!,
              error: const Color(0xFFF32424),
              onError: const Color.fromARGB(255, 231, 100, 13),
              background: const Color.fromARGB(255, 231, 230, 230),
              onBackground: const Color(0xFF000000),
              surface: Colors.blueGrey[200]!,
              onSurface: Colors.blueGrey[400]!),
          textTheme: const TextTheme(
              bodyMedium: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              bodySmall: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.normal)),
          useMaterial3: true),

      //register sub class
      initialRoute: '/newhome',
      routes: {
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfilePage(),
        '/home': (context) => Homepage(),
        '/newhome': (context) => NewHomePage(),
        '/1': (context) => ReserveTablePage(),
        // '/2': (context) => ReserveTicketPage(),
        '/3': (context) => FoodandBeverageScreen(),
        '/4': (context) => RequestSongPage(),
        '/5': (context) => ShownProfilePage(),
        '/6': (context) => DonationPage(),
        '/7': (context) => MateCafePage(),
        '/cart': (context) => CartPage(),
        '/allReceipt': (context) => AllReceiptPage(),
        '/orderReceipt': (context) => OrderHistoryPage(),
        '/ticketReceipt': (context) => TicketReceiptPage(),
        '/tableReceipt': (context) => TableReceiptPage(),
        '/payment': (context) => PaymentScreen(),
        '/allqr': (context) => AllQRCodePage(),
        '/qrtable': (context) => const QrReservations(),
        '/qrticket': (context) => const QrReservationTickets(),
        '/cartevent': (context) => CartEventPage(),
      },
    );
  }
}
