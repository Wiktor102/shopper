import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "./lists_model.dart";
import 'empty.dart';

enum TaskOptions { edit, delete }

enum MoreListOption { delete_list, delete_checked_tasks }

class GroceryLists extends StatefulWidget {
  const GroceryLists({super.key});

  @override
  State<GroceryLists> createState() => _GroceryListsState();
}

class _GroceryListsState extends State<GroceryLists> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<bool> promptForBoolean(String dialog) async {
    bool result = false;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(dialog),
              actions: [
                TextButton(
                  onPressed: () {
                    controller.clear();
                    onPromptClosed();
                  },
                  child: const Text("Anuluj"),
                ),
                TextButton(
                  onPressed: () {
                    onPromptClosed();
                    result = true;
                    controller.clear();
                  },
                  child: const Text("Potwierdź"),
                )
              ],
            ));
    return result;
  }

  Future<String?> promptForString(String dialog, String? value) async {
    TextEditingController controller = TextEditingController();
    if (value != null) controller.text += value;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(dialog),
              content: TextField(
                autofocus: true,
                controller: controller,
                onSubmitted: (value) {
                  onPromptClosed();
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    controller.clear();
                    onPromptClosed();
                  },
                  child: const Text("Anuluj"),
                ),
                TextButton(
                  onPressed: () {
                    onPromptClosed();
                  },
                  child: const Text("Potwierdź"),
                )
              ],
            ));
    if (controller.text.isNotEmpty && controller.text != "")
      return controller.text;
    controller.clear();
    return null; // return an empty string if result is null
  }

  void onPromptClosed() {
    Navigator.of(context).pop(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroceryListModel>(context);
    if (provider.grocerySet.isEmpty) {
      provider.newList("Nowa Lista", {TaskObject("necesary", false)});
      provider.deleteTask(0, 0);
    }

    return Scaffold(
      body: Column(
        children: [
          //wyświetla poszczególne rzeczy z listy
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: DropdownButton<GroceryList>(
                      isExpanded: true,
                      value: provider.getCurrentList(),
                      items: provider.grocerySet
                          .map<DropdownMenuItem<GroceryList>>(
                              (GroceryList value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value.name),
                        );
                      }).toList(),
                      onChanged: (GroceryList? value) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            if (value == null) return;
                            provider.changeListTo(value);
                          });
                        });
                      },
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          String? value =
                              await promptForString("Podaj nazwę listy", null);

                          if (value != null || value != "") {
                            provider.newList(
                              value!,
                              {TaskObject("necesary", true)},
                            );
                            int newListIndex = provider.grocerySet.length - 1;
                            provider.deleteTask(
                              0,
                              newListIndex,
                            );
                            provider.currentListIndex = newListIndex;
                          }
                        },
                        icon: const Icon(Icons.format_list_bulleted_add)),
                    IconButton(
                        onPressed: () async {
                          String? value = await promptForString(
                              "Zmień nazwę listy",
                              provider.getCurrentList().name);

                          if (value != null || value != "") {
                            provider.renameList(
                              value!,
                              provider.currentListIndex,
                            );
                          }
                        },
                        icon: const Icon(Icons.edit_note_sharp)),
                    PopupMenuButton<MoreListOption>(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuItem<MoreListOption>>[
                        const PopupMenuItem(
                          value: MoreListOption.delete_list,
                          child: Text(
                            "Usuń listę",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        const PopupMenuItem(
                            value: MoreListOption.delete_checked_tasks,
                            child: Text(
                              "Usuń zaznaczone",
                              style: TextStyle(color: Colors.red),
                            )),
                      ],
                      onSelected: (MoreListOption value) {
                        switch (value) {
                          case MoreListOption.delete_checked_tasks:
                            promptForBoolean(
                                    "Czy chcesz usunąć zaznaczone obiekty")
                                .then((value) => {
                                      if (value == true)
                                        provider.deleteChecked(
                                            provider.currentListIndex)
                                    });
                            break;
                          case MoreListOption.delete_list:
                            print(provider.currentListIndex);
                            promptForBoolean("Czy chcesz usunąć listę").then(
                                (value) =>
                                    value ? provider.deleteCurrentList() : 0);
                            break;
                          default:
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          provider.getCurrentList().items.isNotEmpty
              ? Expanded(
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: true,
                    shrinkWrap: true,
                    itemCount: provider.getCurrentList().items.length,
                    itemBuilder: (BuildContext context, index) {
                      bool checked = provider
                          .getCurrentList()
                          .items
                          .elementAt(index)
                          .checked;
                      return ListTile(
                        key: ValueKey(index),
                        title: Text(
                            provider
                                .getCurrentList()
                                .items
                                .elementAt(index)
                                .item,
                            style: TextStyle(
                                decoration: checked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: provider.getTaskStatus(index),
                              onChanged: (bool? value) => {
                                if (value != null)
                                  provider.setTaskStatus(index, (value))
                              },
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 30),
                              child: PopupMenuButton<TaskOptions>(
                                  initialValue: null,
                                  onSelected: (TaskOptions value) {
                                    switch (value) {
                                      case TaskOptions.edit:
                                        promptForString(
                                                "Zmień nazwę produktu",
                                                provider
                                                    .getCurrentList()
                                                    .items
                                                    .elementAt(index)
                                                    .item)
                                            .then((String? value) => {
                                                  if (value != null ||
                                                      value != "")
                                                    provider.renameTask(
                                                        index, value!)
                                                });
                                        break;
                                      case TaskOptions.delete:
                                        provider.deleteTask(
                                            index, provider.currentListIndex);
                                        break;
                                      default:
                                    }
                                  },
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<TaskOptions>>[
                                        const PopupMenuItem(
                                          value: TaskOptions.edit,
                                          child: Text("Edytuj nazwe"),
                                        ),
                                        const PopupMenuItem(
                                          value: TaskOptions.delete,
                                          child: Text(
                                            "Usuń",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ]),
                            )
                          ],
                        ),
                      );
                    },
                    onReorder: (int oldIndex, int newIndex) {
                      final list = provider.getCurrentList().items.toList();
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = list.removeAt(oldIndex);
                      list.insert(newIndex, item);
                      provider.grocerySet
                          .elementAt(provider.currentListIndex)
                          .items = list.toSet();
                    },
                  ),
                )
              : const Expanded(child: Empty("Brak produktów na liście"))
        ],
      ),
      // ten guzik słuzy do przypisywania itemów do listy
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          promptForString("Napisz nazwę produktu", null)
              .then((String? value) => {
                    if (value != null || value != "")
                      provider.addTaskToCurrentList(TaskObject(value!, false))
                  });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
