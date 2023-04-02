import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "./recipes_model.dart";
import 'bullet_list.dart';

enum RecipesTabs { recipes, custom, favorites }

class TemporaryRecipe {
  int trueIndex;
  Recipe recipe;
  TemporaryRecipe({required this.recipe, required this.trueIndex});
}

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
          RecipesList(
            currentTab: RecipesTabs.recipes,
          ),
          RecipesList(
            currentTab: RecipesTabs.custom,
          ),
          RecipesList(currentTab: RecipesTabs.favorites)
        ]),
      ),
    );
  }
}

class RecipesList extends StatelessWidget {
  // final bool favorites;
  // final bool custom;
  final RecipesTabs currentTab;
  const RecipesList({super.key, this.currentTab = RecipesTabs.recipes});

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
    List<TemporaryRecipe> recipes = []; //lista która pokazuje sie na ekranie

    switch (currentTab) {
      case RecipesTabs.custom:
        for (int i = 0; i < provider.recipes.length; i++) {
          final element = provider.recipes.elementAt(i);
          if (!element.custom) continue;
          recipes.add(TemporaryRecipe(recipe: element, trueIndex: i));
        }
        break;
      case RecipesTabs.favorites:
        for (int i = 0; i < provider.recipes.length; i++) {
          final element = provider.recipes.elementAt(i);
          if (!element.favorite) continue;
          recipes.add(TemporaryRecipe(recipe: element, trueIndex: i));
        }
        break;
      default:
        for (int i = 0; i < provider.recipes.length; i++) {
          final element = provider.recipes.elementAt(i);
          recipes.add(TemporaryRecipe(recipe: element, trueIndex: i));
        }
    }
    return Scaffold(
      body: recipes.isNotEmpty
          ? ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (_, index) => ListTile(
                onTap: () => showDetails(context, index),
                title: Text(recipes[index].recipe.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.playlist_add)),
                    IconButton(
                      onPressed: () => provider
                          .toggleFavorites(recipes.elementAt(index).trueIndex),
                      icon: Icon(
                        Icons.favorite,
                        color:
                            recipes[index].recipe.favorite ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Align(
              alignment: Alignment.center,
              child: Text(
                currentTab == RecipesTabs.custom
                    ? "Nie utworzono jeszcze żadnego przepisu"
                    : currentTab == RecipesTabs.favorites
                        ? "Nie polubiono żadnego przepisu"
                        : "Brak przepisów",
                textAlign: TextAlign.center,
              )),
      floatingActionButton: currentTab == RecipesTabs.custom
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
