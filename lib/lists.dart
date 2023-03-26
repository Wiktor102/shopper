import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "./lists_model.dart";

class GroceryLists extends StatefulWidget {
  const GroceryLists({super.key});

  @override
  State<GroceryLists> createState() => _GroceryListsState();
}

class _GroceryListsState extends State<GroceryLists> {
  late TextEditingController controller;
  final ChangeNotifier<GroceryList> currentGroceryList =
      ChangeNotifier<GroceryList>(GroceryList("Value",
          {ListItemObject("cuz", false), ListItemObject("yesnt", true)}));
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

  void promptForListTask(GroceryListModel provider) async {
    String? taskTitle = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Wprowadź obiekt do listy"),
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
    if (taskTitle == null || taskTitle == "") return;
    currentGroceryList.items.add(ListItemObject(taskTitle, false));
  }

  void promptForListName(GroceryListModel provider) async {
    String? listTitle = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Wprowadź nazwę nowej listy"),
        content: TextField(
          autofocus: true,
          controller: controller,
          // Żeby działało zatwierdzanie przyciskiem na klawiaturze
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
      ),
    );

    if (listTitle == null || listTitle == "") return;
    provider.newList(listTitle, {});
  }

  void onPromptClosed() {
    Navigator.of(context).pop(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroceryListModel>(context);
    final grocerySet = provider.set;

    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            itemCount: currentGroceryList.items.length,
            itemBuilder: (BuildContext context, index) {
              bool checked = currentGroceryList.items.elementAt(index).done;
              return ListTile(
                title: Text(currentGroceryList.items.elementAt(index).item,
                    style: TextStyle(
                        decoration: checked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none)),
                trailing: IconButton(
                  onPressed: () {
                    provider.deleteList(index);
                  },
                  icon: const Icon(Icons.delete),
                ),
              );
            },
          ),
        ],
      ),
      //ten guzik słuzy do przypisywania itemów do listy
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          promptForListTask(provider),
          ChangeNotifier(),
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
