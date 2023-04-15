import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  final String text;
  final String imagePath;
  const Empty(this.text, this.imagePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage(imagePath)),
              const Padding(padding: EdgeInsets.only(top: 20)),
              Text(
                text,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
