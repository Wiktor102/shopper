import 'package:flutter/material.dart';

class GroceryListModel extends ChangeNotifier {
  final List<GroceryList> _lists = [
    GroceryList("Lista 1", {}),
    GroceryList("Lista 2", {}),
    GroceryList("Lista 3", {})
  ];

  List<GroceryList> get lists => _lists;

  void newList(String name, Set<String> items) {
    GroceryList newList = GroceryList(name, items);
    _lists.add(newList);
    notifyListeners();
  }

  void deleteList(int index) {
    _lists.removeAt(index);
    notifyListeners();
  }
}

class GroceryList {
  String name;
  Set<String> items;

  GroceryList(this.name, this.items);
}
