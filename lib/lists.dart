import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "./lists_model.dart";

enum TaskOptions { edit, delete }

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

  Future<String?> promptForString(
      GroceryListModel provider, String dialog) async {
    String? result = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(dialog),
              content: TextField(
                autofocus: true,
                controller: controller,
                onSubmitted: (value) {
                  onPromptClosed();
                  controller.clear();
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
                    controller.clear();
                  },
                  child: const Text("Potwierdź"),
                )
              ],
            ));
    return result;
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
      body: Stack(
        children: [
          //wyświetla poszczególne rzeczy z listy
          Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(left: 50.0, right: 50.0),
              // ignore: sort_child_properties_last
              child: DropdownButton<GroceryList>(
                value: provider.getCurrentList(),
                items: provider.grocerySet
                    .map<DropdownMenuItem<GroceryList>>((GroceryList value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value.name),
                  );
                }).toList(),
                onChanged: (GroceryList? value) {
                  setState(() {
                    if (value == null) return;
                    provider.changeListTo(value);
                  });
                },
                alignment: Alignment.topCenter,
              ),
              height: 50),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              alignment: Alignment.topRight,
              height: 50,
              width: 150,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => {
                            promptForString(provider, "Podaj nazwę listy")
                                .then((String? value) => {
                                      if (value != null || value != "")
                                        {
                                          provider.newList(value!,
                                              {TaskObject("necesary", true)}),
                                          provider.deleteTask(
                                              0, provider.grocerySet.length - 1)
                                        }
                                    })
                          },
                      icon: const Icon(Icons.format_list_bulleted_add)),
                  IconButton(
                      onPressed: () => {
                            promptForString(provider, "Zmień nazwę listy")
                                .then((String? value) => {
                                      if (value != null || value != "")
                                        {
                                          provider.renameList(
                                              value!, provider.currentListIndex)
                                        }
                                    })
                          },
                      icon: const Icon(Icons.edit_note_sharp)),
                  IconButton(
                      onPressed: () => {}, icon: const Icon(Icons.more_horiz))
                ],
              ),
            ),
          ),
          Container(
              margin: const EdgeInsets.only(top: 50),
              alignment: Alignment.center,
              child: provider.getCurrentList().items.isNotEmpty
                  ? ListView.builder(
                      itemCount: provider.getCurrentList().items.length,
                      itemBuilder: (BuildContext context, index) {
                        bool checked = provider
                            .getCurrentList()
                            .items
                            .elementAt(index)
                            .done;
                        return ListTile(
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
                              PopupMenuButton<TaskOptions>(
                                  initialValue: null,
                                  onSelected: (TaskOptions value) {
                                    switch (value) {
                                      case TaskOptions.edit:
                                        promptForString(provider,
                                                "Zmień nazwę produktu")
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
                                      ])
                            ],
                          ),
                        );
                      },
                    )
                  : const Text("Brak Obiektów na liście"))
        ],
      ),
      // ten guzik słuzy do przypisywania itemów do listy
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          promptForString(provider, "Zmień nazwę produktu")
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
