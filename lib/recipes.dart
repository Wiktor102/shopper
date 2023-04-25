import 'dart:convert';

import 'package:Shopper/settings_model.dart';
import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'empty.dart';

import "./recipes_model.dart";
import 'create_recipe.dart';
import 'lists_model.dart';
import 'recipe_details.dart';

import 'utils/prompt_for_boolean.dart';

enum RecipesTabs { recipes, custom, favorites }

const List<String> alphabet = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  '#'
];

class TemporaryRecipe extends ISuspensionBean {
  int trueIndex;
  Recipe recipe;
  late String tag;

  TemporaryRecipe(BuildContext context,
      {required this.recipe, required this.trueIndex}) {
    final settings = Provider.of<SettingsModel>(context);
    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');

    if (settings.recipesSort != RecipesSort.alphabetically) {
      if (recipe.tags.isEmpty) {
        tag = 'Inne';
        return;
      }

      tag = recipe.tags[0];
      return;
    }

    if (validCharacters.hasMatch(recipe.name[0])) {
      tag = recipe.name[0].toUpperCase();
    } else {
      tag = "#";
    }
  }

  @override
  String getSuspensionTag() => tag;
}

class Recipes extends StatefulWidget {
  final Function(int) changeTab;

  const Recipes(this.changeTab, {super.key});

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) return;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final provider = Provider.of<RecipesModel>(context, listen: false);
        provider.unselectAllCategories();
      });
    });
  }

  void createListFromRecipe(Recipe recipe, BuildContext context) {
    final listsProvider = Provider.of<GroceryListModel>(context, listen: false);
    GroceryList list = GroceryList.readFromRecipe(recipe);
    listsProvider.currentListIndex = listsProvider.addList(list);
    widget.changeTab(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: tabController,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.menu_book),
                Padding(
                    padding: EdgeInsets.only(left: 10), child: Text("Przepisy"))
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
                    padding: EdgeInsets.only(left: 10), child: Text("Ulubione"))
              ],
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
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
        ],
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
    List<TemporaryRecipe> recipesForTags = [];
    List<TemporaryRecipe> recipes = []; //lista która pokazuje sie na ekranie

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    void sort() {
      final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
      if (settings.recipesSort == RecipesSort.none) return;
      if (settings.recipesSort == RecipesSort.alphabetically) {
        recipes.sort((a, b) {
          final bool aMatches = validCharacters.hasMatch(a.recipe.name[0]);
          final bool bMatches = validCharacters.hasMatch(b.recipe.name[0]);
          if (!aMatches) return 1;
          if (!bMatches) return -1;

          return a.recipe.name
              .toLowerCase()
              .compareTo(b.recipe.name.toLowerCase());
        });
        return;
      }

      if (settings.recipesSort == RecipesSort.byCategory) {
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
    }

    for (int i = 0; i < provider.recipes.length; i++) {
      final element = provider.recipes.elementAt(i);

      if (currentTab == RecipesTabs.custom) {
        if (!element.custom) continue;
      }

      if (currentTab == RecipesTabs.favorites) {
        if (!element.favorite) continue;
      }

      if (currentTab == RecipesTabs.recipes) {
        if (element.custom) continue;
      }

      bool hasCategory =
          element.tags.any((tag) => provider.selectedCategories.contains(tag));

      recipesForTags
          .add(TemporaryRecipe(context, recipe: element, trueIndex: i));
      if (provider.selectedCategories.isNotEmpty && !hasCategory) continue;

      recipes.add(TemporaryRecipe(context, recipe: element, trueIndex: i));
    }

    sort();
    SuspensionUtil.setShowSuspensionStatus(recipes);

    return Scaffold(
      body: recipes.isNotEmpty
          ? Column(
              children: [
                if (recipes.isNotEmpty) CategoryBar(currentTab),
                Expanded(
                  child: AzListView(
                    data: recipes,
                    itemCount: recipes.length,
                    indexBarData:
                        settings.recipesSort == RecipesSort.alphabetically
                            // ? recipes.map((r) => r.tag).toSet().toList()
                            ? alphabet
                            : [],
                    itemBuilder: (_, index) =>
                        _buildListItem(settings, recipes[index]),
                    indexBarOptions: const IndexBarOptions(
                      needRebuild: true,
                      indexHintAlignment: Alignment.centerRight,
                      indexHintOffset: Offset(15, -20),
                    ),
                    indexHintBuilder: _buildIndexHint,
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

  Widget _buildListItem(SettingsModel settings, TemporaryRecipe recipe) {
    return Column(
      children: [
        if (recipe.isShowSuspension && settings.recipesSort != RecipesSort.none)
          Container(
            alignment: Alignment.bottomLeft,
            color: settings.brightness == Brightness.light
                ? const Color(0xFFb5f2b0)
                : const Color(0XFF005212),
            // height: 35,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 3, top: 10),
              child: Text(recipe.tag, style: const TextStyle(fontSize: 16)),
            ),
          ),
        RecipeListItem(
          recipe,
          currentTab,
          createListFromRecipe,
        ),
      ],
    );
  }

  Widget _buildIndexHint(BuildContext context, String hint) {
    final settings = Provider.of<SettingsModel>(context);
    return Container(
      alignment: Alignment.center,
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: settings.brightness == Brightness.light
            ? const Color(0xFFb5f2b0)
            : const Color(0XFF005212),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(100),
          topLeft: Radius.circular(100),
          bottomLeft: Radius.circular(100),
        ),
      ),
      child: Text(
        hint,
        style: const TextStyle(fontSize: 30),
      ),
    );
  }
}

class RecipeListItem extends StatelessWidget {
  final TemporaryRecipe recipe;
  final RecipesTabs currentTab;
  final Function(Recipe, BuildContext) createListFromRecipe;

  const RecipeListItem(this.recipe, this.currentTab, this.createListFromRecipe,
      {super.key});

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
    final settings = Provider.of<SettingsModel>(context);

    return Padding(
      padding: settings.recipesSort == RecipesSort.alphabetically
          ? const EdgeInsets.only(right: 10)
          : const EdgeInsets.only(right: 0),
      child: ListTile(
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
                      context,
                      "Usunąć ten przepis?",
                      text: "Tej czynności nie można cofnąć.",
                    );
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
      ),
    );
  }
}

class CategoryBar extends StatefulWidget {
  final RecipesTabs tab;

  const CategoryBar(this.tab, {super.key});

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  late Set<String> unselected;
  late Set<String> selected;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final provider = Provider.of<RecipesModel>(context, listen: false);
      if (provider.selectedCategories.isEmpty) {
        switch (widget.tab) {
          case RecipesTabs.custom:
            provider.unselectedCategories = provider.customCategories;
            break;
          case RecipesTabs.favorites:
            provider.unselectedCategories = provider.favoriteCategories;
            break;
          default:
            provider.unselectedCategories = provider.allCategories;
        }
      }

      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesModel>(context);

    if (loading) {
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.unselectedCategories.isEmpty &&
        provider.selectedCategories.isEmpty) {
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))),
        child: const Center(child: Text("Brak kategorii")),
      );
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...provider.selectedCategories
              .map((element) => CategoryBarItem(element, true)),
          ...provider.unselectedCategories
              .map((element) => CategoryBarItem(element, false)),
        ],
      ),
    );
  }
}

class CategoryBarItem extends StatelessWidget {
  final String title;
  final bool selected;

  const CategoryBarItem(this.title, this.selected, {super.key});

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
          if (!selected) provider.selectCategory(title);
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
                    onPressed: () => provider.unselectCategory(title),
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
