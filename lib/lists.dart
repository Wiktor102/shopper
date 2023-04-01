import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
      //   SchedulerBinding.instance.addPostFrameCallback((_) {
      provider.newList("Nowa Lista", {TaskObject("necesary", false)});
      provider.deleteTask(0, 0);
      //   });
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
                      items: provider.getDropdownItems(),
                      onChanged: provider.grocerySet.isEmpty
                          ? null
                          : (GroceryList? value) {
                              SchedulerBinding.instance
                                  .addPostFrameCallback((_) {
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
                          String? value = await promptForString(
                              provider, "Podaj nazwę listy");

                          if (value != null || value != "") {
                            provider.newList(
                              value!,
                              {TaskObject("necesary", true)},
                            );

                            provider.deleteTask(
                              0,
                              provider.grocerySet.length - 1,
                            );
                          }
                        },
                        icon: const Icon(Icons.format_list_bulleted_add)),
                    IconButton(
                        onPressed: () async {
                          String? value = await promptForString(
                            provider,
                            "Zmień nazwę listy",
                          );

                          if (value != null || value != "") {
                            provider.renameList(
                              value!,
                              provider.currentListIndex,
                            );
                          }
                        },
                        icon: const Icon(Icons.edit_note_sharp)),
                    IconButton(
                        onPressed: () => {}, icon: const Icon(Icons.more_horiz))
                  ],
                ),
              ],
            ),
          ),
          Container(
              child: provider.getCurrentList().items.isNotEmpty
                  ? ReorderableListView.builder(
                      buildDefaultDragHandles: true,
                      shrinkWrap: true,
                      itemCount: provider.getCurrentList().items.length,
                      itemBuilder: (BuildContext context, index) {
                        bool checked = provider
                            .getCurrentList()
                            .items
                            .elementAt(index)
                            .done;
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
                                              style:
                                                  TextStyle(color: Colors.red),
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
