
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_test/screens/home.dart';

import 'common/theme.dart';
import 'models/app_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Dynamics 365',
      theme: appTheme,
      home: const MyHomePage(),
    );
  }
}
