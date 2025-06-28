import 'package:flutter/foundation.dart';
import 'package:greenly_app/services/campaign_service.dart';

class CampaignManager extends ChangeNotifier {
  final CampaignService _campaignService = CampaignService();
  int? _campaignId;
  Map<int, bool> _participationStatus = {}; // Initialize as empty map

  int? get campaignId => _campaignId;
  Map<int, bool> get participationStatus => _participationStatus;

  void setCampaignId(int id) {
    _campaignId = id;
    notifyListeners();
  }

  void reset() {
    _campaignId = null;
    _participationStatus.clear(); // Clear participation status
    notifyListeners();
  }

  void updateParticipationStatus(Map<int, bool> statusMap) {
    _participationStatus = statusMap; // Overwrite with new status
    notifyListeners();
  }

  Future<bool> getParticipationStatus(int campaignId) async {
    try {
      final isJoined =
          await _campaignService.getParticipationStatus(campaignId);
      _participationStatus[campaignId] = isJoined; // Update status immediately
      notifyListeners();
      print(
          '🔄 Updated participation status for campaign $campaignId: $isJoined');
      return isJoined;
    } catch (e) {
      print('⚠️ Error in getParticipationStatus: $e');
      return false;
    }
  }

  Future<bool> joinCampaign(int campaignId) async {
    try {
      final success = await _campaignService.joinCampaign(campaignId);
      if (success) {
        _participationStatus[campaignId] = true; // Update status on success
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('⚠️ Error in joinCampaign: $e');
      return false;
    }
  }

  Future<bool> leaveCampaign(int campaignId) async {
    try {
      final success = await _campaignService.leaveCampaign(campaignId);
      if (success) {
        _participationStatus[campaignId] = false; // Update status on success
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('⚠️ Error in leaveCampaign: $e');
      return false;
    }
  }
}
