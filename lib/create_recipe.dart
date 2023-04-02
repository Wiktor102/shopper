import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "recipes_model.dart";

class CreateRecipe extends StatefulWidget {
  final Recipe? recipe;
  const CreateRecipe({super.key, this.recipe});

  @override
  State<CreateRecipe> createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  String title = "";
  List<String> ingredients = [""];
  List<String> steps = [];

  final titleController = TextEditingController();
  final stepsController = TextEditingController();
  final ingredientsControllers = [TextEditingController()];

  @override
  void initState() {
    if (widget.recipe != null) {
      loadRecipe(widget.recipe as Recipe);
    }
    super.initState();
  }

  @override
  void dispose() {
    for (TextEditingController controller in ingredientsControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void save(BuildContext context) {
    final provider = Provider.of<RecipesModel>(context, listen: false);

    Recipe newRecipe = Recipe(
      id: int.parse('2137${provider.numberOfCustomRecipes}69'),
      name: title,
      ingredients: ingredients,
      steps: steps,
      custom: true,
    );

    if (widget.recipe == null) {
      provider.addCustomRecipe(newRecipe);
    } else {
      provider.updateCustomRecipe(widget.recipe!.id, newRecipe);
    }

    Navigator.of(context).pop();
  }

  void loadRecipe(Recipe recipe) {
    setState(() {
      title = recipe.name;
      ingredients = recipe.ingredients;
      steps = recipe.steps;
    });

    titleController.text = recipe.name;
    stepsController.text = recipe.steps[0];

    int i = 0;
    for (String ingredient in recipe.ingredients) {
      if (ingredientsControllers.length - 1 < i) {
        ingredientsControllers.add(TextEditingController());
      }

      ingredientsControllers[i].text = ingredient;
      i++;
    }
  }

  void removeField(index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  void onInputChanged(String value, int index) {
    setState(() {
      ingredients[index] = value;
    });
  }

  void addNextField() {
    setState(() {
      ingredients.add("");
      ingredientsControllers.add(TextEditingController());
    });
  }

  void onStepsChanged(String value) {
    setState(() {
      steps = [value];
    });
  }

  Future<bool> promptForBoolean(context, String dialog, String text) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialog),
        content: Text(text),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(title: const Text("Stwórz przepis")),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ListView(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Tytuł",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {
                  title = value;
                }),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text("Składniki:", style: TextStyle(fontSize: 22)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: ingredients.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: ingredientsControllers[index],
                                  decoration: InputDecoration(
                                    labelText: "Składnik ${index + 1}",
                                    border: const OutlineInputBorder(),
                                  ),
                                  onChanged: (v) => onInputChanged(v, index),
                                ),
                              ),
                              index != 0
                                  ? IconButton(
                                      onPressed: () => removeField(index),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                    )
                                  : const Text("")
                            ],
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: addNextField,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Icon(Icons.add),
                                  ),
                                  Text("Dodaj składnik")
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child:
                    Text("Sposób wykonania:", style: TextStyle(fontSize: 22)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20),
                child: TextField(
                  controller: stepsController,
                  maxLines: null, //or null
                  decoration: InputDecoration(
                    hintText: "Jak wykonać $title?",
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(20.0),
                  ),
                  onChanged: onStepsChanged,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => save(context),
          child: const Icon(Icons.check),
        ),
      ),
      onWillPop: () async {
        String title = "Czy chcesz wyjść?";
        String text = widget.recipe != null
            ? "Zmiany nie zostaną zapisane!"
            : "Przepis nie zostanie zapisany!";
        return await promptForBoolean(context, title, text);
      },
    );
  }
}
