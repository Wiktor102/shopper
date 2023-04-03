import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:collection/collection.dart';
import 'package:phone_number/phone_number.dart';

import "./position_model.dart";
import "./favorite_stores_model.dart";
import "./settings_model.dart";

part "stores_model.g.dart";

const double threshold = 0.6; // W kilometrach

class StoresModel extends ChangeNotifier {
  List<Store> nearbyStores = [];
  bool loading = true;

  final PositionModel _positionProvider;
  final FavoriteStoresModel _favoritesProvider;
  final SettingsModel settingsProvider;

  StoresModel(
    this._positionProvider,
    this._favoritesProvider,
    this.settingsProvider,
  ) {
    if (_positionProvider.currentPosition == null) return;
    double lat = _positionProvider.lat;
    double lng = _positionProvider.lng;
    double? bestAccuracy;
    List<Store>? bestAccuracyList;
    int? bestRange;
    int desiredRange = settingsProvider.storeDistance;

    Hive.box("stores").toMap().forEach((k, v) {
      List<String> saveLocation = k.split(",");
      double saveLat = double.parse(saveLocation[0]);
      double saveLng = double.parse(saveLocation[1]);
      int range = int.parse(saveLocation[2]);
      double dist = distance(lat, lng, saveLat, saveLng);

      if ((bestAccuracy == null || dist < bestAccuracy!) &&
          bestRange == desiredRange) {
        bestAccuracy = dist;
        bestRange = range;
        bestAccuracyList = v.cast<Store>();
      }
    });

    if (bestAccuracy == null ||
        bestAccuracyList == null ||
        bestAccuracy! > threshold) {
      _getNearbyStores(_positionProvider).then((_) => _checkFavorites());
    } else {
      nearbyStores = bestAccuracyList!;
      loading = false;
    }
  }

  Store getStoreById(String id) {
    return nearbyStores.firstWhere((Store store) => store.id == id);
  }

  // Below code updates out-of-date favorites (Does it still make sense when caching?)
  void _checkFavorites() {
    for (Store store in nearbyStores) {
      Store? fromFav = _favoritesProvider.getFavoriteStoreById(store.id);

      if (fromFav == null) continue;
      if (!(const DeepCollectionEquality().equals(store, fromFav))) {
        _favoritesProvider.updateFavorite(store);
      }
    }
  }

  Future<void> _getNearbyStores(PositionModel _positionProvider) async {
    double lat = _positionProvider.lat;
    double lng = _positionProvider.lng;
    int storeDistanceSetting = settingsProvider.storeDistance;

    print("Super: $storeDistanceSetting");

    Uri uri = Uri(
      scheme: 'https',
      host: 'trueway-places.p.rapidapi.com',
      path: 'FindPlacesNearby',
      queryParameters: {
        "location": "$lat,$lng",
        "type": "grocery_store",
        "radius": storeDistanceSetting.toString()
      },
    );

    Map<String, String> headers = {
      'X-RapidAPI-Key': 'b76e842c5dmshaef6496a223d71fp15abb2jsn62961ea937f2',
      'X-RapidAPI-Host': 'trueway-places.p.rapidapi.com'
    };

    Response response = await get(uri, headers: headers);

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      List<dynamic> results = body["results"] as List<dynamic>;
      nearbyStores =
          results.map((dynamic result) => Store.fromJson(result)).toList();
      Hive.box("stores").put("$lat,$lng,$storeDistanceSetting", nearbyStores);
      loading = false;
      notifyListeners();
    } else {
      loading = false;
    }
  }
}

@HiveType(typeId: 0)
class Store {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? address;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String? website;

  @HiveField(7)
  final List<double> location;

  @HiveField(6)
  final List<dynamic> types;

  double get lat => location[0];
  double get lng => location[1];

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.website,
    required this.location,
    required this.types,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json["id"] as String,
      name: json["name"] as String,
      address: json["address"] as String?,
      phoneNumber: json["phone_number"] as String?,
      website: json["website"] as String?,
      location: [json["location"]["lat"], json["location"]["lng"]],
      types: json["types"] as List<dynamic>,
    );
  }

  Future<List<Map<String, dynamic>>> getDetails() async {
    List<Map<String, dynamic>> detailsList = [];

    detailsList.add({"title": "Nazwa", "icon": Icons.abc, "value": name});

    if (website != null) {
      detailsList.add({
        "title": "Strona internetowa",
        "icon": Icons.language,
        "value": website
      });
    }

    if (phoneNumber != null) {
      try {
        PhoneNumber parsedNumber =
            await PhoneNumberUtil().parse(phoneNumber as String);

        String formattedNumber = await PhoneNumberUtil()
            .format(phoneNumber as String, parsedNumber.regionCode);

        detailsList.add(
            {"title": "Telefon", "icon": Icons.call, "value": formattedNumber});
      } catch (e) {
        detailsList.add(
            {"title": "Telefon", "icon": Icons.call, "value": phoneNumber});
      }
    }

    if (address != null) {
      detailsList
          .add({"title": "Adres", "icon": Icons.signpost, "value": address});
    }

    return detailsList;
  }
}

class LatLngWithAdapter extends LatLng {
  LatLngWithAdapter(super.latitude, super.longitude);
}

double distance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371.0; // Earth's radius in kilometers
  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);
  double a = pow(sin(dLat / 2), 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);
  double c = 2 * asin(sqrt(a));
  return earthRadius * c;
}

// Helper function to convert degrees to radians
double _toRadians(double degrees) {
  return degrees * (pi / 180);
}
