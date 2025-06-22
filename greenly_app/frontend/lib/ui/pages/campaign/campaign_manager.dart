import 'package:flutter/foundation.dart';

class CampaignManager extends ChangeNotifier {
  int? _campaignId;

  int? get campaignId => _campaignId;

  void setCampaignId(int id) {
    _campaignId = id;
    notifyListeners();
  }

  void reset() {
    _campaignId = null;
    notifyListeners();
  }
}
