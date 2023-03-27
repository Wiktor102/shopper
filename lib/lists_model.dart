import 'package:flutter/material.dart';

class GroceryListModel extends ChangeNotifier {
  final Set<GroceryList> _set = {};

//* Możesz to usunąć jak skończysz testowanie -> tak się deklaruje konstruktor we flutterze
  GroceryListModel() {
    final newList = GroceryList("Value", {
      ListItemObject("cuz", false),
      ListItemObject("yesnt", true),
    });

    _set.add(newList);
    notifyListeners();
  }

  Set<GroceryList> get grocerySet =>
      _set; //* nazwy kolidowały -> "set" jest zastrzerzonym słowem (chyba)

  void newList(String name, Set<ListItemObject> items) {
    GroceryList newList = GroceryList(name, items);
    _set.add(newList);
    notifyListeners();
  }

  void deleteList(int index) {
    _set.remove(
        index); //! to nie zadziała -> metoda remove nie bierze indexu jako argument tylko wartość a jako że wartością jest obiekt to chyba w ogóle nie zadziała?
    notifyListeners();
  }

  void addItemToList(int index, ListItemObject listItem) {
    final currentGroceryList = _set.elementAt(index);
    currentGroceryList.items.add(listItem);
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
