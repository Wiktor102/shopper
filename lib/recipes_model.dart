import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RecipesModel extends ChangeNotifier {
  final List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;
  void readJSON() async {
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
          name: recipe['title'] as String,
          ingredients: ingredients.isNotEmpty ? ingredients : ["null"],
          steps: steps.isNotEmpty ? steps : ["null"],
        ),
      );
    }

    notifyListeners();
  }

  RecipesModel() {
    readJSON();
  }

  void toggleFavorites(int index) {
    _recipes[index].favorite = !_recipes[index].favorite ? true : false;
    notifyListeners();
  }
}

class Recipe {
  String name;
  List<String> ingredients;
  List<String> steps;
  bool favorite;
  bool custom;

  Recipe(
      {required this.name,
      required this.ingredients,
      required this.steps,
      this.favorite = false,
      this.custom = false});
}
