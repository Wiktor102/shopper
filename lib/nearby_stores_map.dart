import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import "./position_model.dart";
import "./stores_model.dart";

class NearbyStoresMap extends StatelessWidget {
  const NearbyStoresMap({
    super.key,
    required MapController mapController,
  }) : _mapController = mapController;

  final MapController _mapController;

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PositionModel>(context);
    final storesProvider = Provider.of<StoresModel>(context);

    if (posProvider.currentPosition == null || storesProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<Marker> markerList = storesProvider.nearbyStores
        .map((Store store) => Marker(
              point: LatLng(store.location.latitude, store.location.longitude),
              builder: (context) =>
                  const Image(image: AssetImage('assets/pinGreen.png')),
            ))
        .toList();

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(posProvider.lat, posProvider.lng),
          minZoom: 2,
          zoom: 13,
          maxZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(markers: markerList),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.moveAndRotate(
            LatLng(posProvider.lat, posProvider.lng),
            13,
            0,
          );
        },
        child: const Icon(Icons.near_me),
      ),
    );
  }
}
