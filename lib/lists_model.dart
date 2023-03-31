import 'package:flutter/material.dart';

//komenda pozwalająca usuwać obiekt z listy
Set<dynamic> deleteFromSetIndex(Set<dynamic> set, int index) {
  Set<dynamic> result = {};
  List<dynamic> list = set.toList();
  list.removeAt(index);
  result = list.toSet();
  return result;
}

class GroceryListModel extends ChangeNotifier {
  Set<GroceryList> _set = {};
  int currentListIndex = 0;

  Set<GroceryList> get grocerySet => _set;

  void newList(String name, Set<TaskObject> items) {
    GroceryList newList = GroceryList(name, items);
    _set.add(newList);
    notifyListeners();
  }

  void renameList(String name, int index) {
    _set.elementAt(index).name = name;
    notifyListeners();
  }

  void deleteList(int index) {
    Set<dynamic> updatedSet = deleteFromSetIndex(_set, index);
    _set = updatedSet.cast<GroceryList>();
    notifyListeners();
  }

  void deleteCurrentList() {
    deleteList(currentListIndex);
    currentListIndex = 0;
    notifyListeners();
  }

  void deleteChecked(int listIndex) {
    final list = _set.elementAt(listIndex).items;
    for (int i = 0; i < list.length; i++) {
      if (!list.elementAt(i).checked) continue;
      deleteTask(i, listIndex);
      deleteChecked(listIndex);
    }
  }

  void deleteTask(int index, int listIndex) {
    Set<dynamic> updatedSet =
        deleteFromSetIndex(_set.elementAt(listIndex).items, index);
    _set.elementAt(listIndex).items = updatedSet.cast<TaskObject>();
    notifyListeners();
  }

  bool getTaskStatus(int taskIndex) {
    return _set.elementAt(currentListIndex).items.elementAt(taskIndex).checked;
  }

  GroceryList getCurrentList() {
    return grocerySet.elementAt(currentListIndex);
  }

  void changeListTo(GroceryList element) {
    currentListIndex = _set.toList().indexOf(element);
    notifyListeners();
  }

  void setTaskStatus(int taskIndex, bool value) {
    _set.elementAt(currentListIndex).items.elementAt(taskIndex).checked = value;
    notifyListeners();
  }

  void renameTask(int index, String name) {
    _set.elementAt(currentListIndex).items.elementAt(index).item = name;
    notifyListeners();
  }

  void addTaskToCurrentList(TaskObject listItem) {
    _set.elementAt(currentListIndex).items.add(listItem);
    notifyListeners();
  }
}

//objekt który pozwala stwierdzić czy rzecz była juz wykonana
class TaskObject {
  String item;
  bool checked;

  void replace(TaskObject taskObject) {
    item = taskObject.item;
    checked = taskObject.checked;
  }

  TaskObject(this.item, this.checked);
}

class GroceryList {
  String name;
  Set<TaskObject> items;

  GroceryList(this.name, this.items);
}
