import 'package:flutter/material.dart';

Future<bool> promptForBoolean(context, String dialog,
    {String? text, String no = "Nie", String yes = "Tak"}) async {
  bool result = false;
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(dialog),
      content: text == null ? null : Text(text),
      actions: [
        TextButton(
          onPressed: () {
            result = false;
            Navigator.of(context).pop();
          },
          child: Text(no),
        ),
        TextButton(
          onPressed: () {
            result = true;
            Navigator.of(context).pop();
          },
          child: Text(yes),
        )
      ],
    ),
  );

  return result;
}
