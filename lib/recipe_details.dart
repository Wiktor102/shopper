import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bullet_list.dart';
import 'recipes_model.dart';

class RecipeDetails extends StatelessWidget {
  final int index;
  final Function(Recipe, BuildContext) createListFromRecipe;

  const RecipeDetails(this.index, this.createListFromRecipe, {super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesModel>(context);
    final recipe = provider.recipes[index];

    List<Text> steps = recipe.steps.map((s) => Text(s)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              provider.toggleFavorites(index);
            },
            icon: Icon(
              Icons.favorite,
              color: provider.recipes[index].favorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Jeśli nie uda mi się dodać linków ze zdjęciami do json-a to usuniemy obrazek
          Image.network("https://picsum.photos/400/250"),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
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
                ...steps
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