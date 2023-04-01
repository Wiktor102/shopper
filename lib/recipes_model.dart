import 'package:flutter/material.dart';

class RecipesModel extends ChangeNotifier {
  final List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  RecipesModel() {
    // tutaj można wczytać dane z json-a (albo zawołać funkcję ładującą json-a)
    // na razie jakieś statyczne dane:
    List<String> st = [
      "1. Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
      "2. Nam at risus venenatis, efficitur orci nec, commodo risus. Nunc eget augue metus. Aliquam sollicitudin, felis porttitor."
    ];

    _recipes.add(Recipe(
        name: "Przepis 1", ingredients: ["coś", "I jeszcze coś"], steps: st));
    _recipes
        .add(Recipe(name: "Przepis 2", ingredients: ["coś innego"], steps: st));
    notifyListeners();
  }

  void toggleFavorites(int index) {
    // dodać albo usunąć z ulubionych przepis o podanym index-ie
    notifyListeners();
  }
}

class Recipe {
  final String name;
  final List<String> ingredients;
  final List<String> steps;
  bool favorite;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.steps,
    this.favorite = false,
  });
}
