import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
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
  final tagsController = TextEditingController();

  final GlobalKey categoriesHeaderKey = GlobalKey();

  Set<String> tagList = {};

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

    if (tagList.isEmpty) {
      tagList.add("Inne");
    }

    Recipe newRecipe = Recipe(
      id: int.parse('2137${provider.numberOfCustomRecipes}69'),
      name: title,
      ingredients: ingredients,
      steps: steps,
      custom: true,
      tags: tagList.toList(),
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
      tagList = Set<String>.from(recipe.tags.toSet());

      if (tagList.contains("Inne")) {
        tagList.remove("Inne");
      }
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
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Tytuł",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {
                      title = value;
                    }),
                  ),
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
                Padding(
                  key: categoriesHeaderKey,
                  padding: const EdgeInsets.only(top: 20),
                  child:
                      const Text("Kategorie:", style: TextStyle(fontSize: 22)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: CategoryInput(
                      tagList: tagList,
                      controller: tagsController,
                      setState: setState,
                      headerKey: categoriesHeaderKey),
                ),
              ],
            ),
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

class CategoryInput extends StatefulWidget {
  const CategoryInput({
    super.key,
    required this.tagList,
    required this.controller,
    required this.setState,
    required this.headerKey,
  });

  final Function setState;
  final Set<String> tagList;

  final GlobalKey headerKey;
  final TextEditingController controller;

  @override
  State<CategoryInput> createState() => _CategoryInputState();
}

class _CategoryInputState extends State<CategoryInput> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _autocompleteKey = GlobalKey();
  final GlobalKey<TagsState> tagsKey = GlobalKey<TagsState>();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) return;
      Scrollable.ensureVisible(widget.headerKey.currentContext as BuildContext);
    });
  }

  void onInputChanged(String newInput) {
    if (!newInput.contains(",")) return;
    String newItem = newInput.split(",")[0];

    addTag(newItem);
  }

  void addTag(String tag) {
    if (tag == "") return;
    widget.setState(() {
      widget.tagList.add(tag);
    });

    widget.controller.text = "";
  }

  bool removeTag(String tag) {
    widget.setState(() {
      widget.tagList.remove(tag);
    });

    return true;
  }

  Iterable<String> getTagOptions(
      TextEditingValue textValue, RecipesModel provider) {
    if (textValue.text.isEmpty) {
      return provider.allCategories.where((v) => !widget.tagList.contains(v));
    }

    return provider.allCategories.where((v) =>
        v.toLowerCase().contains(textValue.text.toLowerCase()) &&
        !widget.tagList.contains(v));
  }

  Widget buildTagOptions(BuildContext context,
      AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: SizedBox(
          height: 200,
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final option = options.elementAt(index);
              return GestureDetector(
                onTap: () {
                  onSelected(option);
                },
                child: ListTile(
                  title: Text(option),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //* Nie podobało mi się jak ten napis wyglądał, ale można go dodać
        // if (tagList.isEmpty)
        //   const Opacity(
        //       opacity: 0.75, child: Text("Brak przypisanych kategorii")),
        Tags(
          key: tagsKey,
          itemCount: widget.tagList.length,
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          itemBuilder: (index) {
            return ItemTags(
              index: index,
              title: widget.tagList.elementAt(index),
              activeColor: Colors.green,
              elevation: 0,
              removeButton: ItemTagsRemoveButton(
                // backgroundColor: Colors.transparent,
                onRemoved: () => removeTag(widget.tagList.elementAt(index)),
              ),
            );
          },
        ),
        RawAutocomplete<String>(
          key: _autocompleteKey,
          focusNode: _focusNode,
          textEditingController: widget.controller,
          onSelected: addTag,
          optionsBuilder: (tv) => getTagOptions(tv, provider),
          fieldViewBuilder: (_, editController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: editController,
              focusNode: focusNode,
              onSubmitted: addTag,
              onChanged: onInputChanged,
              decoration: const InputDecoration(
                hintText: 'Oddzielaj przecinkiem',
              ),
            );
          },
          optionsViewBuilder: buildTagOptions,
        ),
        const Padding(padding: EdgeInsets.only(bottom: 500)),
      ],
    );
  }
}
