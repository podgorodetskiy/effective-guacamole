import 'package:flutter/material.dart';

mixin Dialogs<T extends StatefulWidget> on State<T> {
  @protected
  Future<void> showSimpleDialog(
      String title, String description, Map<String, Function()?> actions) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: actions.entries
              .map((e) => TextButton(
                    child: Text(e.key),
                    onPressed: () {
                      Navigator.of(context).pop();
                      e.value?.call();
                    },
                  ))
              .toList(),
        );
      },
    );
  }
}
