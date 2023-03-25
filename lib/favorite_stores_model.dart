import 'package:flutter/material.dart';

import "./stores_model.dart";

class FavoriteStoresModel extends ChangeNotifier {
  final Map<String, Store> _favorites = {};

  Map<String, Store> get favorites => _favorites;

  bool isFavorite(String id) {
    return _favorites.containsKey(id);
  }

  Store? getFavoriteStoreById(String id) {
    return _favorites[id];
  }

  void addToFavorites(Store store) {
    _favorites.addAll({store.id: store});
    notifyListeners();
  }

  void removeFromFavorites(String id) {
    _favorites.remove(id);
    notifyListeners();
  }

  void toggleFavorite(Store store) {
    if (isFavorite(store.id)) {
      removeFromFavorites(store.id);
    } else {
      addToFavorites(store);
    }
  }

  void updateFavorite(Store store) {
    _favorites[store.id] = store;
    notifyListeners();
  }
}
