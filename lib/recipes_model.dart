import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RecipesModel extends ChangeNotifier {
  final List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;
  void readJSON() {
    rootBundle.loadString('assets/recipes.json').then((value) {
      for (final recipe in jsonDecode(value)) {
        _recipes.add(Recipe(
            name: recipe['title'] as String,
            ingredients: ['steps', 'test'],
            steps: ['steps', 'imma speed']));
      }
      notifyListeners();
    });
  }

  RecipesModel() {
    readJSON();
    if (_recipes.isEmpty) {
      print("empty");
      return;
    }
    notifyListeners();
  }
  void toggleFavorites(int index) {
    // dodać albo usunąć z ulubionych przepis o podanym index-ie
    notifyListeners();
  }
}

class Recipe {
  String name;
  List<String> ingredients;
  List<String> steps;
  bool favorite;
  static Recipe fromJson(Map<String, dynamic> json) {
    return Recipe(
        name: json['title'], ingredients: ["a", "b"], steps: ["a", "n"]);
  }

  Recipe({
    required this.name,
    required this.ingredients,
    required this.steps,
    this.favorite = false,
  });
}
