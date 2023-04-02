import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "./recipes_model.dart";
import 'bullet_list.dart';

class Recipes extends StatelessWidget {
  const Recipes({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
                  Icon(Icons.local_library),
                  Padding(
                      padding: EdgeInsets.only(left: 10), child: Text("Własne"))
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
        body: const TabBarView(children: [
          RecipesList(),
          RecipesList(custom: true),
          RecipesList(favorites: true)
        ]),
      ),
    );
  }
}

class RecipesList extends StatelessWidget {
  final bool favorites;
  final bool custom;

  const RecipesList({
    super.key,
    this.favorites = false,
    this.custom = false,
  });

  void showDetails(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetails(index),
      ),
    );
  }

  void createCustomRecipe(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateRecipe(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesModel>(context);
    if (custom) {
      // filtruj listę przepisów by pokazać wyłączne własne
    } else {
      // filtruj listę przepisów by nie pokazać własnych przepisów
    }

    if (favorites) {
      // filtruj listę przepisów po atrybucie favorite
      // albo w modelu stworzyć metodę, która zwróci tylko ulubione
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: provider.recipes.length,
        itemBuilder: (_, index) => ListTile(
          onTap: () => showDetails(context, index),
          title: Text(provider.recipes[index].name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.playlist_add)),
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
      ),
      floatingActionButton: custom
          ? FloatingActionButton(
              onPressed: () => createCustomRecipe(context),
              child: const Icon(Icons.add),
            )
          : null,
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

class CreateRecipe extends StatelessWidget {
  const CreateRecipe({super.key});

  void save(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stwórz przepis")),
      body: const Text("Tu się będzie tworzyć przepisy"),
      floatingActionButton: FloatingActionButton(
        onPressed: () => save(context),
        child: const Icon(Icons.check),
      ),
    );
  }
}
