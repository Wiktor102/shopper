import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import "./position_model.dart";

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
