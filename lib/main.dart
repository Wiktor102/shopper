import 'package:flutter/material.dart';
import "package:hive_flutter/hive_flutter.dart";
import 'package:provider/provider.dart';

import "./settings.dart";
import "./bottom_nav.dart";
import "./lists.dart";

import "./nearby_stores.dart";
import "./recipes.dart";

import "./lists_model.dart";
import "./stores_model.dart";
import "./settings_model.dart";
import "./position_model.dart";
import './favorite_stores_model.dart';
import "./recipes_model.dart";

final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

GlobalKey<ScaffoldMessengerState> getScaffoldKey() {
  return _scaffoldKey;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(StoreAdapter());
  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(TaskObjectAdapter());
  Hive.registerAdapter(GroceryListAdapter());

  if (!Hive.isBoxOpen("groceryLists")) {
    await Hive.openBox<GroceryList>("groceryLists");
  }

  if (!Hive.isBoxOpen("stores")) {
    await Hive.openBox("stores");
  }

  if (!Hive.isBoxOpen("lastOpenedList")) {
    await Hive.openBox("lastOpenedList");
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PositionModel(_scaffoldKey)),
      ChangeNotifierProvider(create: (_) => FavoriteStoresModel()),
      ChangeNotifierProvider(create: (_) => GroceryListModel()),
      ChangeNotifierProvider(create: (_) => SettingsModel()),
      ChangeNotifierProvider(create: (_) => RecipesModel()),
      ChangeNotifierProxyProvider2<PositionModel, SettingsModel, StoresModel>(
        create: (BuildContext context) => StoresModel(
          Provider.of<PositionModel>(context, listen: false),
          Provider.of<FavoriteStoresModel>(context, listen: false),
          Provider.of<SettingsModel>(context, listen: false),
        ),
        update: (
          BuildContext context,
          PositionModel pos,
          SettingsModel settings,
          StoresModel? storesModel,
        ) =>
            StoresModel(
          pos,
          Provider.of<FavoriteStoresModel>(context, listen: false),
          settings,
        ),
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
  int tabIndex = 1;
  List titles = ["Przepisy", "Listy zakupowe", "Najbliższe sklepy"];
  late List screens;

  changeTab(int i) {
    setState(() => tabIndex = i);
  }

  _AppState() {
    screens = [Recipes(changeTab), const GroceryLists(), const NearbyStores()];
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsModel>(context);

    return MaterialApp(
      title: 'Shopper',
      scaffoldMessengerKey: _scaffoldKey,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: settingsProvider.brightness,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(titles[tabIndex]),
          actions: const [SettingsButton()],
        ),
        body: screens[tabIndex],
        bottomNavigationBar:
            BottomNav(tabIndex: tabIndex, changeTab: changeTab),
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
  });

  void goToSettings(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const Settings()));
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () => goToSettings(context),
    );
  }
}
