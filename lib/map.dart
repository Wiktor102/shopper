import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import "./position_model.dart";

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

class NearbyStoresList extends StatelessWidget {
  const NearbyStoresList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PositionModel>(context);

    if (provider.currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return const Icon(Icons.directions_transit);
  }
}

class NearbyStoresMap extends StatelessWidget {
  const NearbyStoresMap({
    super.key,
    required MapController mapController,
  }) : _mapController = mapController;

  final MapController _mapController;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PositionModel>(context);

    if (provider.currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(provider.lat, provider.lng),
          minZoom: 2,
          zoom: 13,
          maxZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.moveAndRotate(
            LatLng(provider.lat, provider.lng),
            13,
            0,
          );
        },
        child: const Icon(Icons.near_me),
      ),
    );
  }
}
