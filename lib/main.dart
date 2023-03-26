import 'package:flutter/material.dart';
import "package:flutter/scheduler.dart";
import 'package:provider/provider.dart';

import "./bottom_nav.dart";
import "./nearby_stores.dart";
import "./position_model.dart";
import "./stores_model.dart";
import './favorite_stores_model.dart';

final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

GlobalKey<ScaffoldMessengerState> getScaffoldKey() {
  return _scaffoldKey;
}

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PositionModel(_scaffoldKey)),
      ChangeNotifierProvider(create: (_) => FavoriteStoresModel()),
      ChangeNotifierProxyProvider<PositionModel, StoresModel>(
        create: (BuildContext context) => StoresModel(
            Provider.of<PositionModel>(context, listen: false),
            Provider.of<FavoriteStoresModel>(context, listen: false)),
        update: (BuildContext context, PositionModel pos,
                StoresModel? storesModel) =>
            StoresModel(
                pos, Provider.of<FavoriteStoresModel>(context, listen: false)),
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
      scaffoldMessengerKey: _scaffoldKey,
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
