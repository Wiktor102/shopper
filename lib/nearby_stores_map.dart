import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

import "./position_model.dart";
import "./stores_model.dart";
import './favorite_stores_model.dart';

import "./nearby_stores.dart";

class NearbyStoresMap extends StatelessWidget {
  final MapController mapController;
  final MarkersController markersController;
  final GlobalKey markerLayerKey = GlobalKey();
  final Function(String) showStoreDetails;

  NearbyStoresMap(
    this.showStoreDetails, {
    super.key,
    required this.mapController,
    required this.markersController,
  });

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PositionModel>(context);
    final storesProvider = Provider.of<StoresModel>(context);

    if (posProvider.currentPosition == null || storesProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<MarkerWithMetadata> markerList = storesProvider.nearbyStores
        .map((Store store) => MarkerWithMetadata(
              point: LatLng(store.location.latitude, store.location.longitude),
              builder: (context) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: const Image(image: AssetImage('assets/pinGreen.png')),
                onTap: () {
                  mapController.move(
                    LatLng(store.lat, store.lng),
                    mapController.zoom,
                  );

                  final MarkerWithMetadata marker =
                      markersController.markerList.firstWhere(
                    (element) => element.metadata["id"] == store.id,
                  );

                  final List<MarkerWithMetadata> markersToHide =
                      markersController.markerList
                          .where(
                            (element) => element.metadata["id"] != store.id,
                          )
                          .toList();

                  markersController.popupController
                      .hidePopupsOnlyFor(markersToHide);
                  markersController.popupController.togglePopup(marker);
                },
              ),
              anchorPos: AnchorPos.align(AnchorAlign.top),
              metadata: {"id": store.id},
            ))
        .toList();

    markersController.markerList = markerList;

    PopupMarkerLayerWidget popupMarkerLayer = PopupMarkerLayerWidget(
      key: markerLayerKey,
      options: PopupMarkerLayerOptions(
        popupController: markersController.popupController,
        markers: markerList,
        markerRotateAlignment:
            PopupMarkerLayerOptions.rotationAlignmentFor(AnchorAlign.top),
        popupBuilder: (_, dynamic marker) =>
            MarkerPopup(marker, showStoreDetails),
      ),
    );

    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
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
          popupMarkerLayer,
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mapController.moveAndRotate(
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

class MarkerWithMetadata extends Marker {
  final Map<String, dynamic> metadata;

  MarkerWithMetadata({
    required super.point,
    required super.builder,
    super.key,
    super.width = 30.0,
    super.height = 30.0,
    super.rotate,
    super.rotateOrigin,
    super.rotateAlignment,
    super.anchorPos,
    this.metadata = const {},
  });
}

class MarkerPopup extends StatelessWidget {
  final MarkerWithMetadata marker;
  final Function(String) showStoreDetails;

  const MarkerPopup(this.marker, this.showStoreDetails, {super.key});

  @override
  Widget build(BuildContext context) {
    final storesProvider = Provider.of<StoresModel>(context);
    final favoritesProvider = Provider.of<FavoriteStoresModel>(context);
    final Store storeData = storesProvider.getStoreById(marker.metadata["id"]);

    return Card(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              iconSize: 35,
              onPressed: () {
                favoritesProvider.toggleFavorite(storeData);
              },
              icon: Icon(
                Icons.favorite,
                color: favoritesProvider.isFavorite(storeData.id)
                    ? Colors.red
                    : null,
              ),
            ),
          ),
          _cardDescription(storeData),
        ],
      ),
    );
  }

  Widget _cardDescription(Store storeData) {
    return InkWell(
      onTap: () => showStoreDetails(storeData.id),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _getCardTitle(storeData.name),
              const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
              Text(
                "Adres: ${storeData.address}",
                style: const TextStyle(fontSize: 12.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCardTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
      ),
    );
  }
}
