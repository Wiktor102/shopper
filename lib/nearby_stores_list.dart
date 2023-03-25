import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "./stores_model.dart";

class NearbyStoresList extends StatelessWidget {
  const NearbyStoresList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StoresModel>(context);

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: provider.nearbyStores.length,
      itemBuilder: (BuildContext context, int index) => ListTile(
        title: Text(provider.nearbyStores[index].name),
      ),
    );
  }
}
