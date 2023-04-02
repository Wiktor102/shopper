import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopper/empty.dart';

import "./recipes_model.dart";
import 'create_recipe.dart';
import 'lists_model.dart';
import 'recipe_details.dart';

enum RecipesTabs { recipes, custom, favorites }

class TemporaryRecipe {
  int trueIndex;
  Recipe recipe;
  TemporaryRecipe({required this.recipe, required this.trueIndex});
}

class Recipes extends StatelessWidget {
  final Function(int) changeTab;

  const Recipes(this.changeTab, {super.key});

  void createListFromRecipe(Recipe recipe, BuildContext context) {
    final listsProvider = Provider.of<GroceryListModel>(context, listen: false);
    GroceryList list = GroceryList.readFromRecipe(recipe);
    listsProvider.currentListIndex = listsProvider.addList(list);
    changeTab(1);
  }

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
        body: TabBarView(children: [
          RecipesList(
            currentTab: RecipesTabs.recipes,
            createListFromRecipe: createListFromRecipe,
          ),
          RecipesList(
            currentTab: RecipesTabs.custom,
            createListFromRecipe: createListFromRecipe,
          ),
          RecipesList(
            currentTab: RecipesTabs.favorites,
            createListFromRecipe: createListFromRecipe,
          )
        ]),
      ),
    );
  }
}

class RecipesList extends StatelessWidget {
  final RecipesTabs currentTab;
  final Function(Recipe, BuildContext) createListFromRecipe;

  const RecipesList({
    super.key,
    this.currentTab = RecipesTabs.recipes,
    required this.createListFromRecipe,
  });

  void showDetails(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetails(index, createListFromRecipe),
      ),
    );
  }

  void createCustomRecipe(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateRecipe(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesModel>(context);
    List<TemporaryRecipe> recipes = []; //lista która pokazuje sie na ekranie

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

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
          if (element.custom) continue;
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
                      onPressed: () => {
                        createListFromRecipe(
                            recipes.elementAt(index).recipe, context)
                      },
                      icon: const Icon(Icons.playlist_add),
                    ),
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
          : Empty(
              currentTab == RecipesTabs.custom
                  ? "Nie utworzono jeszcze żadnego przepisu"
                  : currentTab == RecipesTabs.favorites
                      ? "Nie polubiono żadnego przepisu"
                      : "Brak przepisów",
            ),
      floatingActionButton: currentTab == RecipesTabs.custom
          ? FloatingActionButton(
              onPressed: () => createCustomRecipe(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
