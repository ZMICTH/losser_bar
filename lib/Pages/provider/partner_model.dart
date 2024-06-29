import 'package:flutter/material.dart';

class SelectedPartnerProvider with ChangeNotifier {
  String? _selectedPartnerId;

  String? get selectedPartnerId => _selectedPartnerId;

  void selectPartner(String partnerId) {
    _selectedPartnerId = partnerId;
    print("select ${partnerId}");
    notifyListeners();
  }
}
