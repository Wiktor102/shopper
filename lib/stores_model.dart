import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:collection/collection.dart';

import "./position_model.dart";
import "./favorite_stores_model.dart";

class StoresModel extends ChangeNotifier {
  List<Store> nearbyStores = [];
  bool loading = true;

  final PositionModel _positionProvider;
  final FavoriteStoresModel _favoritesProvider;

  StoresModel(this._positionProvider, this._favoritesProvider) {
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
        "radius": "3000"
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

class Store {
  final String id;
  final String name;
  final String? address;
  final String? phoneNumber;
  final String? website;
  final LatLng location;
  final List<dynamic> types;

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
      location: LatLng(json["location"]["lat"], json["location"]["lng"]),
      types: json["types"] as List<dynamic>,
    );
  }
}
