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
          // const StoreDistanceTile()
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
    // textController = TextEditingController();
  }

  void onValueChange(
    int val,
    SettingsModel settingsProvider,
    BuildContext context,
  ) {
    void resetText() {
      textController.text = settingsProvider.storeDistance.toString();
    }

    void showSnackbar(String text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }

    if (val > 10000) {
      showSnackbar("Wartość musi być mniejsza od 10 000 m");
      resetText();
      return;
    }

    if (val < 500) {
      showSnackbar("Wartość musi być większa od 500 m");
      resetText();
      return;
    }

    settingsProvider.storeDistance = val;
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsModel>(context);
    textController =
        TextEditingController(text: settingsProvider.storeDistance.toString());

    return ListTile(
      title: const Text("Odległość sklepów"),
      subtitle: const Text("Max. 10 000 m"),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.4,
        ),
        child: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: "m"),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (String val) =>
              onValueChange(int.parse(val), settingsProvider, context),
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
