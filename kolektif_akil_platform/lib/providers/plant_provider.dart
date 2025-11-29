import 'package:flutter/foundation.dart';
import '../models/virtual_plant.dart';
import '../services/firebase_service.dart';

class PlantProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  VirtualPlant? _plant;
  bool _isWatering = false;

  VirtualPlant? get plant => _plant;
  bool get isWatering => _isWatering;

  void loadPlant({String? groupId}) {
    _firebaseService.getVirtualPlant(groupId: groupId).listen((plant) {
      _plant = plant;
      notifyListeners();
    });
  }

  Future<void> waterPlant(String userId, {String? groupId}) async {
    if (_isWatering) return;

    _isWatering = true;
    notifyListeners();

    try {
      await _firebaseService.waterPlant(userId, groupId: groupId);
    } catch (e) {
      rethrow;
    } finally {
      _isWatering = false;
      notifyListeners();
    }
  }
}

