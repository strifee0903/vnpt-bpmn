import 'package:flutter/foundation.dart';

import '../../../services/campaign_service.dart';

class CampaignManager extends ChangeNotifier {
  final CampaignService _campaignService = CampaignService();
  int? _campaignId;
  Map<int, bool> _participationStatus =
      {}; // Lưu trạng thái tham gia của từng campaign
  int? get campaignId => _campaignId;
  Map<int, bool> get participationStatus => _participationStatus;

  void setCampaignId(int id) {
    _campaignId = id;
    notifyListeners();
  }

  void reset() {
    _campaignId = null;
    notifyListeners();
  }

  // Lấy trạng thái tham gia của campaign
  Future<bool> getParticipationStatus(int campaignId) async {
    if (_participationStatus.containsKey(campaignId)) {
      return _participationStatus[campaignId]!;
    }
    final isJoined = await _campaignService.getParticipationStatus(campaignId);
    _participationStatus[campaignId] = isJoined;
    notifyListeners();
    return isJoined;
  }

  // Tham gia campaign
  Future<bool> joinCampaign(int campaignId) async {
    final success = await _campaignService.joinCampaign(campaignId);
    if (success) {
      _participationStatus[campaignId] = true;
      notifyListeners();
    }
    return success;
  }

  // Rời campaign
  Future<bool> leaveCampaign(int campaignId) async {
    final success = await _campaignService.leaveCampaign(campaignId);
    if (success) {
      _participationStatus[campaignId] = false;
      notifyListeners();
    }
    return success;
  }
}
