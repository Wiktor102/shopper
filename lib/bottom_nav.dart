import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int tabIndex;
  final Function(int) changeTab;

  const BottomNav({
    super.key,
    required this.tabIndex,
    required this.changeTab,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: tabIndex,
      onDestinationSelected: (index) {
        changeTab(index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.restaurant_menu),
          label: "Przepisy",
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long),
          label: "Listy",
        ),
        NavigationDestination(
          icon: Icon(Icons.store),
          label: "Sklepy",
        ),
      ],
    );
  }
}
