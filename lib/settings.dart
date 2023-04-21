import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import "./settings_model.dart";

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ustawienia"),
      ),
      body: ListView(
        children: [
          ThemeTile(settingsProvider: settingsProvider),
          RecipesSortTile(settingsProvider: settingsProvider),
          //const StoreDistanceTile(),
          const AboutApp(),
        ],
      ),
    );
  }
}

class StoreDistanceTile extends StatefulWidget {
  const StoreDistanceTile({
    super.key,
  });

  @override
  State<StoreDistanceTile> createState() => _StoreDistanceTileState();
}

class _StoreDistanceTileState extends State<StoreDistanceTile> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
  }

  void onValueChange(int val, SettingsModel settingsProvider) {
    if (val > 10000) {
      val = 10000;
    } else if (val < 500) {
      val = 500;
    }

    settingsProvider.storeDistance = val;
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsModel>(context);
    textController =
        TextEditingController(text: settingsProvider.storeDistance.toString());

    return Form(
      child: DecoratedBox(
        decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(width: 3, color: Colors.black45))),
        child: Column(
          children: [
            const ListTile(
              title: Text("Odległość sklepów"),
              subtitle: Text("500 m - 10 000 m"),
            ),
            Container(
              transform: Matrix4.translationValues(0.0, -10.0, 0.0),
              child: Slider(
                min: 500,
                max: 10000,
                divisions: 95,
                label: settingsProvider.storeDistance.toString(),
                value: settingsProvider.storeDistance.toDouble(),
                onChanged: (double val) =>
                    onValueChange(val.floor(), settingsProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeTile extends StatelessWidget {
  const ThemeTile({
    super.key,
    required this.settingsProvider,
  });

  final SettingsModel settingsProvider;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Motyw"),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.4,
        ),
        child: DropdownButton(
          isExpanded: true,
          value: settingsProvider.theme,
          onChanged: (String? newTheme) {
            settingsProvider.theme = newTheme as String;
          },
          items: const [
            DropdownMenuItem(
              value: "auto",
              child: Text("Automatyczny"),
            ),
            DropdownMenuItem(
              value: "light",
              child: Text("Jasny"),
            ),
            DropdownMenuItem(
              value: "dark",
              child: Text("Ciemny"),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipesSortTile extends StatelessWidget {
  const RecipesSortTile({
    super.key,
    required this.settingsProvider,
  });

  final SettingsModel settingsProvider;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Sortowanie przepisów"),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.4,
        ),
        child: DropdownButton(
          isExpanded: true,
          value: settingsProvider.recipesSort,
          onChanged: (RecipesSort? newSetting) {
            settingsProvider.recipesSort = newSetting as RecipesSort;
          },
          items: const [
            DropdownMenuItem(
              value: RecipesSort.alphabetically,
              child: Text("Alfabetycznie"),
            ),
            DropdownMenuItem(
              value: RecipesSort.byCategory,
              child: Text("Wg kategorii"),
            ),
            DropdownMenuItem(
              value: RecipesSort.none,
              child: Text("Bez sortowania"),
            )
          ],
        ),
      ),
    );
  }
}

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpansionTile(
      initiallyExpanded: true,
      title: Text("O aplikacji"),
      leading: Icon(Icons.info),
      children: [
        Padding(
          padding: EdgeInsets.only(left: 59),
          child: ExpansionTile(
            initiallyExpanded: true,
            title: Text("Autorzy"),
            children: [
              ListTile(title: Text("Wiktor Golicz")),
              ListTile(title: Text("Mikołaj Gaweł-Kucab")),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 59),
          child: ExpansionTile(
            initiallyExpanded: true,
            title: Text("Źródła"),
            children: [
              ListTile(title: Text("wikikuchnia.org")),
              ListTile(title: Text("truewayapi.com")),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 59),
          child: ListTile(
            title: Text("Wersja"),
            trailing: Text("v1.4"),
          ),
        )
      ],
    );
  }
}
