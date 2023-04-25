import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import "./settings_model.dart";

part "recipes_model.g.dart";

class RecipesModel extends ChangeNotifier {
  final List<Recipe> _recipes = [];
  List<Recipe> _customRecipes = [];
  List<int> _favoriteIds = [];
  bool loading = true;

  Set<String> _categories = {}; // Kategorie przepisów gotowych
  Set<String> _unselectedCategories = {};
  Set<String> _customCategories = {}; // Kategorie przepisów własnych
  Set<String> _favoriteCategories = {}; // Kategorie przepisów polubionych
  final Set<String> _selectedCategories = {};

  List<Recipe> get recipes => _recipes;
  int get numberOfCustomRecipes => _customRecipes.length;

  Set<String> get customCategories => _customCategories;
  Set<String> get favoriteCategories => _favoriteCategories;
  Set<String> get selectedCategories => _selectedCategories;
  Set<String> get unselectedCategories => _unselectedCategories;
  Set<String> get allCategories => _categories;

  set unselectedCategories(Set<String> newUnselected) {
    _unselectedCategories = sortCategories(newUnselected);
    notifyListeners();
  }

  Future<void> readJSON() async {
    final jsonString = await rootBundle.loadString('assets/recipes.json');
    final decoded = jsonDecode(jsonString);

    for (final recipe in decoded) {
      final List<dynamic>? products = recipe['products'] is String
          ? [recipe['products']]
          : recipe['products'];
      final List<String> ingredients = [];
      if (products != null) {
        for (String value in products) {
          ingredients.add(value);
        }
      }

      if (recipe['steps'] is String) {
        recipe['steps'] = [recipe['steps']];
      }

      final List<dynamic>? stepsDynamic = recipe['steps'];
      final List<String> steps = [];
      if (stepsDynamic != null) {
        for (String value in stepsDynamic) {
          steps.add(value);
        }
      }

      recipe["categories"] =
          recipe["categories"].map((c) => c.replaceAll("_", " "));

      _recipes.add(
        Recipe(
          id: recipe['id'] as int,
          name: recipe['title'] as String,
          ingredients: ingredients.isNotEmpty ? ingredients : ["null"],
          steps: steps.isNotEmpty ? steps : ["null"],
          tags: recipe["categories"].toList(),
        ),
      );
    }

    _categories = getCategories(_recipes);
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    final box = await Hive.openBox("favoriteRecipes");
    final savedFav = box.get("favorite");
    if (savedFav == null) return;

    _favoriteIds = savedFav;
    for (Recipe recipe in _recipes) {
      if (!_favoriteIds.contains(recipe.id)) continue;
      recipe.favorite = true;
    }
  }

  RecipesModel() {
    Hive.openBox("customRecipes").then((Box box) {
      _customRecipes = box.values.toList().cast<Recipe>();
      _customCategories = getCategories(_customRecipes);
      _recipes.addAll(_customRecipes);
      notifyListeners();
    });

    readJSON().then((_) async {
      await loadFavorites();
      _favoriteCategories = getCategories(_getFavoriteRecipes());

      loading = false;
      notifyListeners();
    });
  }

  Set<String> getCategories(List<Recipe> myRecipes) {
    Set<String> mySet = {};

    for (Recipe r in myRecipes) {
      for (String category in r.tags) {
        mySet.add(category);
      }
    }

    return sortCategories(mySet);
  }

  Set<String> sortCategories(Set<String> mySet) {
    List<String> sorted = mySet.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    mySet = Set<String>.from(sorted);

    if (mySet.contains("Inne")) {
      mySet.remove("Inne");
      mySet.add("Inne");
    }

    return mySet;
  }

  List<Recipe> _getFavoriteRecipes() {
    return _recipes.where((r) => r.favorite).toList();
  }

  void toggleFavorites(int index) {
    _recipes[index].favorite = !_recipes[index].favorite ? true : false;

    if (_favoriteIds.contains(_recipes[index].id)) {
      _favoriteIds.remove(_recipes[index].id);
    } else {
      _favoriteIds.add(_recipes[index].id);
    }

    _favoriteCategories = getCategories(_getFavoriteRecipes());
    Hive.box("favoriteRecipes").put("favorite", _favoriteIds);
    notifyListeners();
  }

  void addCustomRecipe(Recipe recipe) {
    _customCategories.addAll(Set<String>.from(recipe.tags));
    _customRecipes.add(recipe);
    _recipes.add(recipe);

    Hive.box("customRecipes").put(recipe.id, recipe);
    notifyListeners();
  }

  void removeCustomRecipe(int recipeId) {
    final Recipe toDelete =
        _recipes.where((r) => r.id == recipeId).elementAt(0);
    _customCategories.removeAll(Set<String>.from(toDelete.tags));

    _recipes.removeWhere((r) => r.id == recipeId);
    _customRecipes.removeWhere((r) => r.id == recipeId);

    Hive.box("customRecipes").delete(recipeId);
    notifyListeners();
  }

  void updateCustomRecipe(int recipeId, Recipe recipe) {
    recipe.id = recipeId;
    _recipes[_recipes.indexWhere((r) => r.id == recipeId)] = recipe;
    _customRecipes[_customRecipes.indexWhere((r) => r.id == recipeId)] = recipe;
    _customCategories = getCategories(_customRecipes);

    Hive.box("customRecipes").put(recipeId, recipe);
    notifyListeners();
  }

  void selectCategory(String name) {
    _selectedCategories.add(name);
    _unselectedCategories.remove(name);
    notifyListeners();
  }

  void unselectCategory(String name) {
    _selectedCategories.remove(name);
    _unselectedCategories.add(name);
    _unselectedCategories = sortCategories(_unselectedCategories);
    notifyListeners();
  }

  void unselectAllCategories() {
    _unselectedCategories.addAll(_selectedCategories);
    _selectedCategories.clear();
    notifyListeners();
  }

  List<String> getUnselectedCategories() {
    return [..._categories]
      ..removeWhere((element) => _selectedCategories.contains(element));
  }
}

@HiveType(typeId: 3)
class Recipe {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> ingredients;

  @HiveField(3)
  List<String> steps;

  @HiveField(4)
  bool favorite;

  @HiveField(5)
  bool custom;

  @HiveField(7)
  List<dynamic> tags;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.steps,
    this.tags = const [],
    this.favorite = false,
    this.custom = false,
  });
}
