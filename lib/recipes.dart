import 'dart:convert';

import 'package:Shopper/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'empty.dart';

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

  void createCustomRecipe(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateRecipe(recipe: null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesModel>(context);
    final settings = Provider.of<SettingsModel>(context);
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

          bool hasCategory = element.tags
              .any((tag) => provider.selectedCategories.contains(tag));

          if (provider.selectedCategories.isNotEmpty && !hasCategory) continue;
          recipes.add(TemporaryRecipe(recipe: element, trueIndex: i));
        }
    }

    if (settings.recipesSort == RecipesSort.alphabetically) {
      recipes.sort((a, b) =>
          a.recipe.name.toLowerCase().compareTo(b.recipe.name.toLowerCase()));
    } else if (settings.recipesSort == RecipesSort.byCategory) {
      recipes.sort((a, b) {
        if (a.recipe.tags.isEmpty && b.recipe.tags.isEmpty) return 0;
        if (a.recipe.tags.isEmpty) return 1;
        if (b.recipe.tags.isEmpty) return -1;

        int compareResult = a.recipe.tags[0]
            .toLowerCase()
            .compareTo(b.recipe.tags[0].toLowerCase());

        if (compareResult == 0) {
          return a.recipe.name
              .toLowerCase()
              .compareTo(b.recipe.name.toLowerCase());
        }

        return compareResult;
      });
    }

    return Scaffold(
      body: recipes.isNotEmpty
          ? Column(
              children: [
                currentTab == RecipesTabs.recipes
                    ? const CategoryBar()
                    : const Text(""),
                Expanded(
                  child: ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (_, index) => RecipeListItem(
                        recipes.elementAt(index),
                        currentTab,
                        createListFromRecipe),
                  ),
                ),
              ],
            )
          : Empty(
              currentTab == RecipesTabs.custom
                  ? "Nie utworzono jeszcze żadnego przepisu"
                  : currentTab == RecipesTabs.favorites
                      ? "Nie polubiono żadnego przepisu"
                      : "Brak przepisów",
              currentTab == RecipesTabs.recipes
                  ? 'assets/empty.png'
                  : currentTab == RecipesTabs.favorites
                      ? 'assets/favRecipes.png'
                      : 'assets/customRecipes.png'),
      floatingActionButton: currentTab == RecipesTabs.custom
          ? FloatingActionButton(
              onPressed: () => createCustomRecipe(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class RecipeListItem extends StatelessWidget {
  final TemporaryRecipe recipe;
  final RecipesTabs currentTab;
  final Function(Recipe, BuildContext) createListFromRecipe;

  const RecipeListItem(this.recipe, this.currentTab, this.createListFromRecipe,
      {super.key});

  Future<bool> promptForBoolean(context, String dialog) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialog),
        actions: [
          TextButton(
            onPressed: () {
              result = false;
              Navigator.of(context).pop();
            },
            child: const Text("Anuluj"),
          ),
          TextButton(
            onPressed: () {
              result = true;
              Navigator.of(context).pop();
            },
            child: const Text("Potwierdź"),
          )
        ],
      ),
    );

    return result;
  }

  void showDetails(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetails(index, createListFromRecipe),
      ),
    );
  }

  // custom
  void createCustomRecipe(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateRecipe(recipe: null),
      ),
    );
  }

  void editCustomRecipe(BuildContext context, Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateRecipe(recipe: recipe),
      ),
    );
  }

  void deleteCustomRecipe(int recipeId, RecipesModel provider) {
    provider.removeCustomRecipe(recipeId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesModel>(context);
    return ListTile(
      onTap: () => showDetails(context, recipe.trueIndex),
      title: Text(recipe.recipe.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => {createListFromRecipe(recipe.recipe, context)},
            icon: const Icon(Icons.playlist_add),
          ),
          IconButton(
            onPressed: () => provider.toggleFavorites(recipe.trueIndex),
            icon: Icon(
              Icons.favorite,
              color: recipe.recipe.favorite ? Colors.red : null,
            ),
          ),
          if (currentTab == RecipesTabs.custom)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == "edit") {
                  editCustomRecipe(
                    context,
                    recipe.recipe,
                  );
                }

                if (value == "delete") {
                  final bool res = await promptForBoolean(
                      context, "Czy na pewno chcesz usunąć ten przepis?");
                  if (!res) return;
                  deleteCustomRecipe(
                    recipe.recipe.id,
                    provider,
                  );
                }
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
    );
  }
}

class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesModel>(context);
    final Map<int, String> unselected =
        provider.getUnselectedCategories().asMap();
    final Map<int, String> selected = provider.selectedCategories.asMap();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...selected
              .map((i, element) =>
                  MapEntry(i, CategoryBarItem(element, i, true)))
              .values,
          ...unselected
              .map((i, element) =>
                  MapEntry(i, CategoryBarItem(element, i, false)))
              .values,
        ],
      ),
    );
  }
}

class CategoryBarItem extends StatelessWidget {
  final String title;
  final int index;
  final bool selected;

  const CategoryBarItem(this.title, this.index, this.selected, {super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesModel>(context);

    return Container(
      decoration: BoxDecoration(
        color: selected ? Colors.green : null,
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(100.0),
        onTap: () {
          if (!selected) provider.selectCategory(index);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          child: Center(
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(color: selected ? Colors.white : null),
                ),
                if (selected)
                  IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => provider.unselectCategory(index),
                    icon: const Icon(Icons.close),
                    color: selected ? Colors.white : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
