import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PositionModel extends ChangeNotifier {
  Position? _currentPosition;
  bool hasPermission = false;

  PositionModel() {
    _handleLocationPermission().then((bool gotPermission) {
      hasPermission = gotPermission;
      notifyListeners();

      _getCurrentPosition();
    });
  }

  double get lat => _currentPosition!.latitude;
  double get lng => _currentPosition!.longitude;
  Position? get currentPosition => _currentPosition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //       content: Text(
      //           'Location services are disabled. Please enable the services')));
      return false;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //       content: Text(
      //           'Location permissions are permanently denied, we cannot request permissions.')));
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
}
