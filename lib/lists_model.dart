import 'package:flutter/material.dart';
import 'recipes_model.dart';
import 'package:hive/hive.dart';

part 'lists_model.g.dart';

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

  GroceryListModel() {
    Box box = Hive.box<GroceryList>("groceryLists");
    _set = box.values.toSet().cast<GroceryList>();
  }

  @override
  void dispose() {
    Hive.box<GroceryList>("groceryLists").close();
    super.dispose();
  }

  void saveUpdatedList(int index) {
    Hive.box<GroceryList>("groceryLists").putAt(index, _set.elementAt(index));
  }

  int addList(GroceryList list) {
    _set.add(list);
    return _set.length - 1;
  }

  void newList(String name, Set<TaskObject> items) {
    GroceryList newList = GroceryList(name, items);
    _set.add(newList);
    Hive.box<GroceryList>("groceryLists").add(newList);
    notifyListeners();
  }

  void renameList(String name, int index) {
    _set.elementAt(index).name = name;
    saveUpdatedList(index);
    notifyListeners();
  }

  void deleteList(int index) {
    Set<dynamic> updatedSet = deleteFromSetIndex(_set, index);
    _set = updatedSet.cast<GroceryList>();
    Hive.box<GroceryList>("groceryLists").delete(index);
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

    saveUpdatedList(listIndex);
  }

  void deleteTask(int index, int listIndex) {
    Set<dynamic> updatedSet =
        deleteFromSetIndex(_set.elementAt(listIndex).items, index);
    _set.elementAt(listIndex).items = updatedSet.cast<TaskObject>();
    saveUpdatedList(listIndex);
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
    saveUpdatedList(currentListIndex);
    notifyListeners();
  }

  void renameTask(int index, String name) {
    _set.elementAt(currentListIndex).items.elementAt(index).item = name;
    saveUpdatedList(currentListIndex);
    notifyListeners();
  }

  void addTaskToCurrentList(TaskObject listItem) {
    _set.elementAt(currentListIndex).items.add(listItem);
    saveUpdatedList(currentListIndex);
    notifyListeners();
  }

  List<DropdownMenuItem<GroceryList>> getDropdownItems() {
    Iterable<DropdownMenuItem<GroceryList>> menuItems =
        grocerySet.map((GroceryList value) {
      return DropdownMenuItem(
        value: value,
        child: Text(value.name),
      );
    });

    return menuItems.toList();
  }
}

//objekt który pozwala stwierdzić czy rzecz była juz wykonana
@HiveType(typeId: 1)
class TaskObject {
  @HiveField(0)
  String item;

  @HiveField(1)
  bool checked;

  void replace(TaskObject taskObject) {
    item = taskObject.item;
    checked = taskObject.checked;
  }

  TaskObject(this.item, this.checked);
}

@HiveType(typeId: 2)
class GroceryList {
  @HiveField(0)
  String name;

  @HiveField(1)
  Set<TaskObject> items;
  static GroceryList readFromRecipe(Recipe recipe) {
    final Set<TaskObject> objects = {};
    for (String value in recipe.ingredients) {
      objects.add(TaskObject(value, false));
    }
    return GroceryList(recipe.name, objects);
  }

  GroceryList(this.name, this.items);
}
