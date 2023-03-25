import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "./stores_model.dart";
import "./favorite_stores_model.dart";

class NearbyStoresList extends StatelessWidget {
  final bool favorites;

  const NearbyStoresList({
    super.key,
    this.favorites = false,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoriteStoresModel>(context);
    List<Store> storeList;

    if (favorites) {
      storeList = favoritesProvider.favorites.values.toList();
    } else {
      final provider = Provider.of<StoresModel>(context);

      if (provider.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      storeList = provider.nearbyStores;
    }

    return ListView.builder(
      itemCount: storeList.length,
      itemBuilder: (BuildContext context, int index) => ListTile(
        title: Text(storeList[index].name),
        trailing: IconButton(
          onPressed: () {
            favoritesProvider.toggleFavorite(storeList[index]);
          },
          icon: const Icon(Icons.favorite),
          color: favoritesProvider.isFavorite(storeList[index].id)
              ? Colors.red
              : null,
        ),
      ),
    );
  }
}
