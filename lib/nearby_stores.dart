import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import "./nearby_stores_map.dart";
import "./nearby_stores_list.dart";

class NearbyStores extends StatefulWidget {
  const NearbyStores({super.key});

  @override
  State<NearbyStores> createState() => _NearbyStoresState();
}

class _NearbyStoresState extends State<NearbyStores> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.favorite),
                  Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text("Ulubione"))
                ],
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            NearbyStoresMap(mapController: _mapController),
            const NearbyStoresList(),
            const NearbyStoresList(favorites: true),
          ],
        ),
      ),
    );
  }
}
