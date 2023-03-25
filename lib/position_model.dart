import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PositionModel extends ChangeNotifier {
  late ScaffoldMessengerState _scaffoldState;

  Position? _currentPosition;
  bool hasPermission = false;

  PositionModel(scaffoldKey) {
    _scaffoldState = scaffoldKey.currentState;

    _handleLocationPermission(_onPermissionDenied).then((bool gotPermission) {
      hasPermission = gotPermission;
      notifyListeners();

      _getCurrentPosition();
    });
  }

  double get lat => _currentPosition!.latitude;
  double get lng => _currentPosition!.longitude;
  Position? get currentPosition => _currentPosition;

  Future<bool> _handleLocationPermission(Function(String) onFailure) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onFailure('Lokalizacja urządzenia jest wyłączona. Włącz ją.');
      return false;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        onFailure("Dostęp do lokalizacji został odmówiony");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      onFailure(
          "Dostęp do lokalizacji został odmówiony, przywróć go ręcznie w ustawieniach urządzenia.");
      return false;
    }

    return true;
  }

  Future<void> _getCurrentPosition() async {
    if (!hasPermission) return;

    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    notifyListeners();
  }

  void _onPermissionDenied(String text) {
    _scaffoldState.showSnackBar(SnackBar(content: Text(text)));
  }
}
