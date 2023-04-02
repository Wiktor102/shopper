import 'package:flutter/material.dart';

class CreateRecipe extends StatelessWidget {
  const CreateRecipe({super.key});

  void save(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stwórz przepis")),
      body: const Text("Tu się będzie tworzyć przepisy"),
      floatingActionButton: FloatingActionButton(
        onPressed: () => save(context),
        child: const Icon(Icons.check),
      ),
    );
  }
}
