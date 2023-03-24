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
    final groceryLists = provider.lists;

    return Scaffold(
      body: ListView.builder(
        itemCount: groceryLists.length,
        itemBuilder: (BuildContext context, index) {
          return ListTile(
            title: Text(groceryLists[index].name),
            trailing: IconButton(
              onPressed: () {
                provider.deleteList(index);
              },
              icon: const Icon(Icons.delete),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => promptForListName(provider),
        child: const Icon(Icons.add),
      ),
    );
  }
}
