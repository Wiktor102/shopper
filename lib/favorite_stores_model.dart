import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import "./stores_model.dart";

class FavoriteStoresModel extends ChangeNotifier {
  Map<String, Store> _favorites = {};
  Map<String, Store> get favorites => _favorites;

  FavoriteStoresModel() {
    Hive.openBox("favorite_stores").then((_) {
      Box box = Hive.box("favorite_stores");
      _favorites = box.toMap().cast<String, Store>();
    });
  }

  @override
  void dispose() {
    Hive.box("favorite_stores").close();
    super.dispose();
  }

  bool isFavorite(String id) {
    return _favorites.containsKey(id);
  }

  Store? getFavoriteStoreById(String id) {
    return _favorites[id];
  }

  void addToFavorites(Store store) {
    _favorites.addAll({store.id: store});
    Hive.box("favorite_stores").put(store.id, store);
    notifyListeners();
  }

  void removeFromFavorites(String id) {
    _favorites.remove(id);
    Hive.box("favorite_stores").delete(id);
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
