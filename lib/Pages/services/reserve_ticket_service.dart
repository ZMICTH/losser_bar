import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:losser_bar/Pages/Model/reserve_ticket_model.dart';

abstract class TicketConcertService {
  Future<List<TicketConcertModel>> getAllTicketConcertModel();

  addReserveTicket(BookingTicket BookingTicketConcert) {}

  Future<List<BookingTicket>> getAllReservationTicket();
}

class TicketConcertFirebaseService implements TicketConcertService {
  @override
  Future<List<TicketConcertModel>> getAllTicketConcertModel() async {
    print("getTicketCatalog is called");
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('ticket_concert_catalog')
        .get();
    print("TicketCatalog count: ${qs.docs.length}");
    AllTicketConcertModel allTicketConcertModel =
        AllTicketConcertModel.fromSnapshot(qs);
    print(allTicketConcertModel.allTicketConcertModel);
    return allTicketConcertModel.allTicketConcertModel;
  }

  @override
  void addReserveTicket(BookingTicket BookingTicketConcert) async {
    try {
      await FirebaseFirestore.instance.collection('reservation_ticket').add({
        'userId': BookingTicketConcert.userId,
        'ticketId': BookingTicketConcert.ticketId,
        'nicknameUser': BookingTicketConcert.nicknameUser,
        'eventName': BookingTicketConcert.eventName,
        'selectedTableLabel': BookingTicketConcert.selectedTableLabel,
        'eventDate': BookingTicketConcert.eventDate,
        'totalPayment': BookingTicketConcert.totalPayment,
        'ticketQuantity': BookingTicketConcert.ticketQuantity,
        'payable': BookingTicketConcert.payable,
        'checkIn': BookingTicketConcert.checkIn,
        'paymentTime': BookingTicketConcert.paymentTime,
        'sharedWith': BookingTicketConcert.sharedWith,
        'partnerId': BookingTicketConcert.partnerId,
      });
      print(BookingTicketConcert.toJson());
      print("Reservation uploaded successfully");
    } catch (e) {
      print('Error adding Reservation: $e');
    }
  }

  @override
  Future<List<BookingTicket>> getAllReservationTicket() async {
    print("getAllReservationTicket is called");
    QuerySnapshot qs =
        await FirebaseFirestore.instance.collection('reservation_ticket').get();
    print("ReservationTicket count: ${qs.docs.length}");
    AllReservationTicketModel allReservationTicketModel =
        AllReservationTicketModel.fromSnapshot(qs);
    print(allReservationTicketModel.allReservationTicketModel);
    return allReservationTicketModel.allReservationTicketModel;
  }
}
