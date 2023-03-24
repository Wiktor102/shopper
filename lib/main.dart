import 'package:flutter/material.dart';
import "package:flutter/scheduler.dart";
import 'package:provider/provider.dart';

import "./bottom_nav.dart";
import "./lists.dart";

import "./lists_model.dart";

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => GroceryListModel()),
    ],
    child: const App(),
  ));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int tabIndex = 1;
  List titles = ["Przepisy", "Listy zakupowe", "Najbliższe sklepy"];
  List screens = const [Text("zakładka 1"), GroceryLists(), Text("zakładka 3")];

  changeTab(int i) {
    setState(() => tabIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopper',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: SchedulerBinding.instance.window.platformBrightness,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text(titles[tabIndex])),
        body: screens[tabIndex],
        bottomNavigationBar:
            BottomNav(tabIndex: tabIndex, changeTab: changeTab),
      ),
    );
  }
}
