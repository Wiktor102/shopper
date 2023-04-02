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
    _getNearbyStores(_positionProvider).then((_) => _checkFavorites());
  }

  Store getStoreById(String id) {
    return nearbyStores.firstWhere((Store store) => store.id == id);
  }

  // Below code updates out-of-date favorites
  void _checkFavorites() {
    for (Store store in nearbyStores) {
      Store? fromFav = _favoritesProvider.getFavoriteStoreById(store.id);

      if (fromFav == null) continue;
      if (!(const DeepCollectionEquality().equals(store, fromFav))) {
        _favoritesProvider.updateFavorite(store);
      }
    }
  }

  Future<dynamic> _getNearbyStores(PositionModel _positionProvider) async {
    double lat = _positionProvider.lat;
    double lng = _positionProvider.lng;

    Uri uri = Uri(
      scheme: 'https',
      host: 'trueway-places.p.rapidapi.com',
      path: 'FindPlacesNearby',
      queryParameters: {
        "location": "$lat,$lng",
        "type": "grocery_store",
        "radius": settingsProvider.storeDistance.toString()
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
      loading = false;
      notifyListeners();
    } else {
      loading = false;
      print(response.reasonPhrase);
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
