import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class RecipesModel extends ChangeNotifier {
  final List<Recipe> _recipes = [];
  List<int> _favoriteIds = [];

  List<Recipe> get recipes => _recipes;
  Future<void> readJSON() async {
    final jsonString = await rootBundle.loadString('assets/recipes.json');
    final decoded = jsonDecode(jsonString);

    for (final recipe in decoded) {
      final List<dynamic>? products = recipe['products'];
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

      _recipes.add(
        Recipe(
          id: recipe['id'] as int,
          name: recipe['title'] as String,
          ingredients: ingredients.isNotEmpty ? ingredients : ["null"],
          steps: steps.isNotEmpty ? steps : ["null"],
        ),
      );
    }

    notifyListeners();
  }

  RecipesModel() {
    readJSON().then((_) async {
      final box = await Hive.openBox("favoriteRecipes");
      final savedFav = box.get("favorite");
      if (savedFav == null) return;

      _favoriteIds = savedFav;
      for (Recipe recipe in _recipes) {
        if (!_favoriteIds.contains(recipe.id)) continue;
        recipe.favorite = true;
      }

      notifyListeners();
    });
  }

  void toggleFavorites(int index) {
    _recipes[index].favorite = !_recipes[index].favorite ? true : false;

    if (_favoriteIds.contains(_recipes[index].id)) {
      _favoriteIds.remove(_recipes[index].id);
    } else {
      _favoriteIds.add(_recipes[index].id);
    }

    Hive.box("favoriteRecipes").put("favorite", _favoriteIds);
    notifyListeners();
  }
}

class Recipe {
  int id;
  String name;
  List<String> ingredients;
  List<String> steps;
  bool favorite;
  bool custom;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.steps,
    this.favorite = false,
    this.custom = false,
  });
}
