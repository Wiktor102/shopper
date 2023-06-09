import 'dart:ffi';

import 'package:Shopper/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "./lists_model.dart";
import 'empty.dart';
import 'utils/prompt_for_boolean.dart';

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
    final settings = Provider.of<SettingsModel>(context);

    if (provider.grocerySet.isEmpty) {
      provider.newList("Nowa Lista", {TaskObject("necesary", false)});
      provider.deleteTask(0, 0);
    }

    return Scaffold(
      body: Column(
        children: [
          //wyświetla poszczególne rzeczy z listy
          DecoratedBox(
            decoration: BoxDecoration(
              color: settings.brightness == Brightness.light
                  ? const Color(0xFFb5f2b0)
                  : const Color(0XFF005212),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: DropdownButton<GroceryList>(
                        selectedItemBuilder: (BuildContext context) {
                          return provider.grocerySet.map((GroceryList value) {
                            return Container(
                              alignment: Alignment.centerLeft,
                              constraints: const BoxConstraints(minWidth: 100),
                              child: Text(
                                value.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                            );
                          }).toList();
                        },
                        isExpanded: true,
                        isDense: true,
                        value: provider.getCurrentList(),
                        items: provider.grocerySet
                            .map<DropdownMenuItem<GroceryList>>(
                                (GroceryList value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(
                              value.name,
                              style: provider.getCurrentList().hashCode ==
                                      value.hashCode
                                  ? const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0XFF008F1F),
                                    )
                                  : const TextStyle(
                                      fontWeight: FontWeight.w300),
                            ),
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
                            String? value = await promptForString(
                                "Podaj nazwę listy", null);

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
                                "Wpisz nową nazwę listy",
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
                                context,
                                "Czy chcesz usunąć zaznaczone obiekty",
                              ).then((value) => {
                                    if (value == true)
                                      provider.deleteChecked(
                                          provider.currentListIndex)
                                  });
                              break;
                            case MoreListOption.delete_list:
                              promptForBoolean(
                                context,
                                "Czy chcesz usunąć listę",
                              ).then((value) =>
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
                            PopupMenuButton<TaskOptions>(
                                initialValue: null,
                                onSelected: (TaskOptions value) {
                                  switch (value) {
                                    case TaskOptions.edit:
                                      promptForString(
                                              "Wpisz nową nazwę produktu",
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
                                        child: Text("Zmień nazwę"),
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
              : Expanded(
                  child: Empty("Brak produktów na liście", 'assets/empty.png'))
        ],
      ),
      // ten guzik słuzy do przypisywania itemów do listy
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          promptForString("Wpisz nazwę produktu", null)
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
