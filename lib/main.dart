import 'package:flutter/material.dart';

import 'pages/home.dart';

void main() async {
  runApp(
    MaterialApp(
      home: const HomePage(),
      showSemanticsDebugger: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          snackBarTheme: const SnackBarThemeData(
            showCloseIcon: true,
            closeIconColor: Colors.white,
          )),
    ),
  );
}
