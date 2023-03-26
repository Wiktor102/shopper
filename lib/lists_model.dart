import 'package:flutter/material.dart';

class GroceryListModel extends ChangeNotifier {
  final Set<GroceryList> _set = {};

  Set<GroceryList> get set => _set;
  void newList(String name, Set<ListItemObject> items) {
    GroceryList newList = GroceryList(name, items);
    _set.add(newList);
    notifyListeners();
  }

  void deleteList(int index) {
    _set.remove(index);
    notifyListeners();
  }
}

//objekt który pozwala stwierdzić czy rzecz była juz wykonana
class ListItemObject {
  String item;
  bool done;
  //przełącza między trybami zaznaczenia obiektu na liście
  void toggle() {
    done = !done ? done : !done;
  }

  ListItemObject(this.item, this.done);
}

class GroceryList {
  String name;
  Set<ListItemObject> items;

  GroceryList(this.name, this.items);
}
