import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "./recipes_model.dart";
import 'bullet_list.dart';

class Recipes extends StatelessWidget {
  const Recipes({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.menu_book),
                  Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text("Przepisy"))
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.favorite),
                  Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text("Ulubione"))
                ],
              ),
            ),
          ],
        ),
        body: const TabBarView(
            children: [RecipesList(), RecipesList(favorites: true)]),
      ),
    );
  }
}

class RecipesList extends StatelessWidget {
  final bool favorites;

  const RecipesList({super.key, this.favorites = false});

  void showDetails(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetails(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesModel>(context);

    if (favorites) {
      // filtruj listę przepisów po atrybucie favorite
      // albo w modelu stworzyć metodę, która zwróci tylko ulubione
    }

    return ListView.builder(
      itemCount: provider.recipes.length,
      itemBuilder: (_, index) => ListTile(
        onTap: () => showDetails(context, index),
        title: Text(provider.recipes[index].name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.playlist_add)),
            IconButton(
              onPressed: () => provider.toggleFavorites(index),
              icon: Icon(
                Icons.favorite,
                color: provider.recipes[index].favorite ? Colors.red : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeDetails extends StatelessWidget {
  final int index;
  const RecipeDetails(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesModel>(context);
    final recipe = provider.recipes[index];

    List<Text> steps = recipe.steps.map((s) => Text(s)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.playlist_add)),
          IconButton(
            onPressed: () => provider.toggleFavorites(index),
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
    );
  }
}
