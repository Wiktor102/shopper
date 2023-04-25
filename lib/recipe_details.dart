import 'package:Shopper/create_recipe.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bullet_list.dart';
import 'recipes_model.dart';
import 'utils/prompt_for_boolean.dart';

class RecipeDetails extends StatelessWidget {
  final int index;
  final Function(Recipe, BuildContext) createListFromRecipe;

  const RecipeDetails(this.index, this.createListFromRecipe, {super.key});

  void editCustomRecipe(BuildContext context, Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateRecipe(recipe: recipe),
      ),
    );
  }

  void deleteCustomRecipe(BuildContext context, Recipe recipe) async {
    final bool res = await promptForBoolean(
      context,
      "Usunąć ten przepis?",
      text: "Tej czynności nie można cofnąć.",
    );

    if (!res) return;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final provider = Provider.of<RecipesModel>(context, listen: false);
      provider.removeCustomRecipe(recipe.id);
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesModel>(context);
    final recipe = provider.recipes[index];

    List<Text> steps = recipe.steps.map((s) => Text(s)).toList();
    String tags = recipe.tags.join(", ");

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            onPressed: () => provider.toggleFavorites(index),
            icon: Icon(
              Icons.favorite,
              color: provider.recipes[index].favorite ? Colors.red : null,
            ),
          ),
          if (recipe.custom)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == "edit") editCustomRecipe(context, recipe);
                if (value == "delete") deleteCustomRecipe(context, recipe);
              },
              itemBuilder: (BuildContext context) => <PopupMenuItem>[
                PopupMenuItem(
                  value: "edit",
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(Icons.edit),
                      ),
                      Text("Edytuj"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "delete",
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(Icons.delete, color: Colors.red),
                      ),
                      Text(
                        "Usuń",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            )
        ],
      ),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Potrzebne składniki:",
                  style: TextStyle(fontSize: 22),
                ),
                BulletList(recipe.ingredients),
                const Text(
                  "Sposób przyrządzenia:",
                  style: TextStyle(fontSize: 22),
                ),
                ...steps,
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Tagi: "),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                        ),
                        child: Opacity(
                          opacity: 0.75,
                          child: Text(
                            tags,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
          createListFromRecipe(recipe, context);
        },
        child: const Icon(Icons.playlist_add),
      ),
    );
  }
}
