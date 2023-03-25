import 'package:flutter/material.dart';
import "package:flutter/scheduler.dart";
import 'package:provider/provider.dart';

import "./bottom_nav.dart";
import "./nearby_stores.dart";
import "./position_model.dart";
import "./stores_model.dart";

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PositionModel()),
      ChangeNotifierProxyProvider<PositionModel, StoresModel>(
        create: (BuildContext context) =>
            StoresModel(Provider.of<PositionModel>(context, listen: false)),
        update: (_, PositionModel pos, StoresModel? storesModel) =>
            StoresModel(pos),
      ),
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
  int tabIndex = 0;
  List titles = ["Przepisy", "Listy zakupowe", "Najbliższe sklepy"];
  List screens = const [Text("zakładka 1"), Text("zakładka 2"), NearbyStores()];

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
        appBar: AppBar(
          title: Text(titles[tabIndex]),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            )
          ],
        ),
        body: screens[tabIndex],
        bottomNavigationBar:
            BottomNav(tabIndex: tabIndex, changeTab: changeTab),
      ),
    );
  }
}
