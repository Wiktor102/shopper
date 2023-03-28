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

  void promptForListTask(GroceryListModel provider, int index) async {
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
    // currentGroceryList.items.add(ListItemObject(taskTitle, false)); //! to nie miało prawa działać -> bezpośrednio modyfikujesz listę
    // * tutaj poprawnie -. stworzyłem nową metodę w modelu
    provider.addItemToList(index, ListItemObject(taskTitle, true));
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

    //* zauważ, że to jest zbiór list a nie poszczególna lista!
    final grocerySet = provider.grocerySet;

    return Scaffold(
      body: Stack(
        children: [
          //* Zdecduj się czy ten Widgrt wyświetla listy czy poszczególne rzeczy z listy!???
          ListView.builder(
            itemCount: grocerySet.elementAt(0).items.length,
            itemBuilder: (BuildContext context, index) {
              bool checked =
                  grocerySet.elementAt(0).items.elementAt(index).done;
              return ListTile(
                title: Text(grocerySet.elementAt(0).items.elementAt(index).item,
                    style: TextStyle(
                        decoration: checked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none)),
                trailing: IconButton(
                  onPressed: () {
                    provider.deleteList(
                        index); //! opisałem ci przy definicji tej metody dlaczego to nie działa
                  },
                  icon: const Icon(Icons.delete),
                ),
              );
            },
          ),
        ],
      ),
      // ten guzik słuzy do przypisywania itemów do listy
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //* Tu nie powinno być przypadkiem dodawanie nowej listy a nie dodawanie rzeczy do istniejącej (promptForListName) ???
          promptForListTask(provider, 0); //* index na razie tymczasowo
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
