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
          const StoreDistanceTile(),
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
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void onValueChange(int val, SettingsModel settingsProvider) {
    final bool isFormValid = formKey.currentState!.validate();

    if (!isFormValid) {
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
      subtitle: const Text("500 m - 10 000 m"),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.4,
        ),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.always,
          child: TextFormField(
            controller: textController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(suffixText: "m"),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (String? value) {
              if (value == null || value == "") return "Min. 500 m";
              int val = int.parse(value);

              if (val > 10000) {
                return "Max. 10 000 m";
              }

              if (val < 500) {
                return "Min. 500 m";
              }

              return null;
            },
            onChanged: (String val) =>
                onValueChange(int.parse(val), settingsProvider),
          ),
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

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpansionTile(
      title: Text("O aplikacji"),
      leading: Icon(Icons.info),
      children: [
        Padding(
          padding: EdgeInsets.only(left: 59),
          child: ExpansionTile(
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
            trailing: Text("v1.3"),
          ),
        )
      ],
    );
  }
}
