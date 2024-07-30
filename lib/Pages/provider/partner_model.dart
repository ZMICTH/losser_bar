import 'package:flutter/material.dart';

class SelectedPartnerProvider with ChangeNotifier {
  String? _selectedPartnerId;

  String? _selectedPartnerName;

  String? get selectedPartnerId => _selectedPartnerId;
  String? get selectedPartnerName => _selectedPartnerName;

  void selectPartner(String partnerId, String partnerName) {
    _selectedPartnerId = partnerId;
    _selectedPartnerName = partnerName;
    print("Selected Partner: $partnerId, Name: $partnerName");
    notifyListeners();
  }
}
