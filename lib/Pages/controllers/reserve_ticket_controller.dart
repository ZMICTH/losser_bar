import 'dart:async';

import 'package:losser_bar/Pages/Model/reserve_ticket_model.dart';
import 'package:losser_bar/Pages/services/reserve_ticket_service.dart';

class TicketConcertController {
  List<TicketConcertModel> allTicketConcertModel = List.empty();
  final TicketConcertService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  TicketConcertController(this.service);

  Future<List<TicketConcertModel>> fetchTicketConcertModel() async {
    print("fetchFoodAndBeverageProduct was: ${allTicketConcertModel}");
    onSyncController.add(true);
    allTicketConcertModel = await service.getAllTicketConcertModel();
    onSyncController.add(false);
    return allTicketConcertModel;
  }

  Future<void> addReserveTicket(BookingTicket BookingTicketConcert) async {
    onSyncController.add(true);
    await service.addReserveTicket(BookingTicketConcert);
    onSyncController.add(false);
  }
}
