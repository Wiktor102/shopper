import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import "./position_model.dart";

import "./nearby_stores_map.dart";
import "./nearby_stores_list.dart";

class NearbyStores extends StatefulWidget {
  const NearbyStores({super.key});

  @override
  State<NearbyStores> createState() => _NearbyStoresState();
}

class _NearbyStoresState extends State<NearbyStores> {
  Position? _currentPosition;
  final MapController _mapController = MapController();

  Future<dynamic> _getNearbyShops() async {
    double lat = _currentPosition!.latitude;
    double lng = _currentPosition!.longitude;

    Uri uri = Uri(
      scheme: 'https',
      host: 'trueway-places.p.rapidapi.com',
      path: 'FindPlacesNearby',
      queryParameters: {
        'location': '$lat,$lng',
        "type": "food",
        "radius": "3000"
      },
    );

    Map<String, String> headers = {
      'X-RapidAPI-Key': 'b76e842c5dmshaef6496a223d71fp15abb2jsn62961ea937f2',
      'X-RapidAPI-Host': 'trueway-places.p.rapidapi.com'
    };

    Response response = await get(uri, headers: headers);

    if (response.statusCode == 200) {
      dynamic body = jsonDecode(response.body);
      print(body);
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PositionModel>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.map),
                  Padding(
                      padding: EdgeInsets.only(left: 10), child: Text("Mapa"))
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.list),
                  Padding(
                      padding: EdgeInsets.only(left: 10), child: Text("Lista"))
                ],
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            NearbyStoresMap(mapController: _mapController),
            const NearbyStoresList(),
          ],
        ),
      ),
    );
  }
}
