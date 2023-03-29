import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import "package:latlong2/latlong.dart";
import 'package:provider/provider.dart';
import 'dart:async';

import "./nearby_stores_map.dart";
import "./nearby_stores_list.dart";

import "./stores_model.dart";

class MarkersController {
  late List<MarkerWithMetadata> markerList;
  final PopupController popupController = PopupController();
}

class NearbyStores extends StatefulWidget {
  const NearbyStores({super.key});

  @override
  State<NearbyStores> createState() => _NearbyStoresState();
}

class _NearbyStoresState extends State<NearbyStores>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final MarkersController _markersController = MarkersController();
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: 1,
      length: 3,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StoresModel>(context);

    if (_tabController == null || provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Store> storeList = provider.nearbyStores;

    void showStoreOnMap(String storeId) {
      if (_tabController == null) return;
      if (!storeList.any((Store store) => store.id == storeId)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Jesteś zbyt daleko od wybranego sklepu by zobaczyć jego lokalizację na mapie.'),
        ));
        return;
      }

      Store storeData = provider.getStoreById(storeId);
      _tabController!.animation!.addStatusListener((_) {
        _mapController.move(LatLng(storeData.lat, storeData.lng), 15);

        final MarkerWithMetadata markerToOpen = _markersController.markerList
            .firstWhere((element) => element.metadata["id"] == storeId);
        _markersController.popupController.showPopupsOnlyFor([markerToOpen]);
      });

      _tabController!.animateTo(0, duration: const Duration(seconds: 1));

      //   Timer timer = Timer(const Duration(seconds: 1), () {
      //   });
    }

    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.map),
                Padding(padding: EdgeInsets.only(left: 10), child: Text("Mapa"))
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
                    padding: EdgeInsets.only(left: 10), child: Text("Ulubione"))
              ],
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NearbyStoresMap(
            mapController: _mapController,
            markersController: _markersController,
          ),
          NearbyStoresList(showStoreOnMap),
          NearbyStoresList(showStoreOnMap, favorites: true),
        ],
      ),
    );
  }
}
