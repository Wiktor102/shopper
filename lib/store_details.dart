import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import "./stores_model.dart";
import "./favorite_stores_model.dart";
import "./main.dart";

class StoreDetails extends StatelessWidget {
  final String storeId;
  final bool favorites;

  const StoreDetails(this.storeId, {super.key, this.favorites = false});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoriteStoresModel>(context);
    Store? storeDetails;

    if (favorites) {
      storeDetails = favoritesProvider.getFavoriteStoreById(storeId);
    } else {
      final storesProvider = Provider.of<StoresModel>(context);

      if (storesProvider.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      storeDetails = storesProvider.getStoreById(storeId);
    }

    if (storeDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Szczegóły"),
        ),
        body: const Text("Brak danych o wybranym sklepie"),
      );
    }

    Future storeDetailsFuture = storeDetails.getDetails();

    return Scaffold(
      appBar: AppBar(
        title: Text(storeDetails.name),
        actions: [
          IconButton(
            onPressed: () {
              favoritesProvider.toggleFavorite(storeDetails as Store);
            },
            icon: const Icon(Icons.favorite),
            color: favoritesProvider.isFavorite(storeId) ? Colors.red : null,
          ),
        ],
      ),
      body: FutureBuilder(
          future: storeDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, i) => detailsBuilder(snapshot.data![i]),
              );
            } else {
              return const CircularProgressIndicator();
            }
          }),
    );
  }

  Widget detailsBuilder(Map<String, dynamic> detail) {
    if (detail["title"] == "Strona internetowa") {
      Uri uri = Uri.parse(detail["value"]);
      return ListTile(
        leading: Icon(detail["icon"]),
        title: Text(detail["title"]),
        subtitle: RichText(
          text: TextSpan(
            text: "${uri.scheme}://${uri.host}",
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()..onTap = () => launchUrl(uri),
          ),
        ),
      );
    }

    return ListTile(
      leading: Icon(detail["icon"]),
      title: Text(detail["title"]),
      subtitle: Text(detail["value"]),
      trailing: ["Telefon", "Adres"].contains(detail["title"])
          ? IconButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: detail["value"]));
                getScaffoldKey().currentState!.showSnackBar(
                      SnackBar(
                        content: const Text("Skopiowano do schowka"),
                        action: SnackBarAction(
                          label: 'Ok',
                          onPressed: () {
                            getScaffoldKey()
                                .currentState!
                                .hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
              },
              icon: const Icon(Icons.copy),
            )
          : null,
    );
  }
}
