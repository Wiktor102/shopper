import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "./position_model.dart";

class NearbyStoresList extends StatelessWidget {
  const NearbyStoresList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PositionModel>(context);

    if (provider.currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return const Icon(Icons.directions_transit);
  }
}
